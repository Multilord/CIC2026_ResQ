import json
from pathlib import Path
import tempfile
import time
import unittest
from unittest.mock import patch
import app


class WorkflowTests(unittest.TestCase):
    def setUp(self):
        (app.ROOT / 'data').mkdir(exist_ok=True)
        self.temp = tempfile.TemporaryDirectory(dir=app.ROOT / 'data')
        app.DB = Path(self.temp.name) / 'test.sqlite3'
        app.initialize(seed_prepared_data=False)
        self.db = app.connect()
        self.people = {}
        for role in app.ROLES:
            uid = role if role != 'admin' else 'test-admin'
            self.db.execute('INSERT INTO users VALUES(?,?,?,?,?,?,?,?,?,?)', (uid, role+'@test.local', role.title(), role, '00'*16, '', 1, 100, 'Test area', 1))
            self.people[role] = dict(self.db.execute('SELECT * FROM users WHERE id=?', (uid,)).fetchone())
        self.db.commit()

    def tearDown(self):
        self.db.close()
        self.temp.cleanup()

    def cmd(self, role, action, **data):
        s = app.state(self.db)
        if action != 'create' and s['batches']:
            b = s['batches'][0]
            data = {'id': b['id'], 'version': b['version'], **data}
        app.command(self.db, self.people[role], {'action': action, **data})
        self.db.commit()
        return app.state(self.db)['batches'][0] if app.state(self.db)['batches'] else None

    def create(self, **extra):
        return self.cmd('sender', 'create', name='Event surplus rice', senderType='Event host', location='Collection gate', category='Rice', kg=10, storage='Chilled', allergens='None declared', minutes=90, eta=20, price=0, confirmed=True, **extra)

    def transit(self):
        self.create()
        self.cmd('recipient', 'accept')
        self.cmd('driver', 'claim')
        return self.cmd('driver', 'pickup', confirmed=True)

    def test_delivery_requires_recipient_code_and_records_receipt(self):
        b = self.transit()
        with self.assertRaises(app.Problem):
            self.cmd('driver', 'deliver', code='2468', confirmed=True)
        self.assertNotIn('handoverCode', app.load_for(self.db, self.people['driver'])['batches'][0])
        recipient = app.load_for(self.db, self.people['recipient'])['batches'][0]
        self.assertEqual(b['handoverCode'], recipient['handoverCode'])
        b = self.cmd('driver', 'deliver', code=b['handoverCode'], confirmed=True)
        self.assertEqual(b['stage'], 'delivered')
        self.assertTrue(b['receipt'].startswith('RCPT-'))

    def test_roles_and_stale_versions_are_enforced(self):
        b = self.create()
        with self.assertRaises(app.Problem):
            self.cmd('sender', 'accept')
        self.cmd('recipient', 'accept')
        with self.assertRaises(app.Problem) as error:
            self.cmd('driver', 'claim', version=b['version'])
        self.assertEqual(error.exception.status, 409)

    def test_expiry_preserves_custody(self):
        self.transit()
        s = app.state(self.db)
        s['batches'][0]['deadline'] = time.time()-1
        app.save(self.db, s)
        b = app.load_for(self.db, self.people['driver'])['batches'][0]
        self.assertEqual(b['stage'], 'waste')
        self.assertEqual(b['driverId'], 'driver')

    def test_recovery_requires_inspection_and_residue_record(self):
        self.create(waste=True)
        self.cmd('recovery', 'assess', route='BSFL', confirmed=True)
        self.cmd('driver', 'claim')
        self.cmd('driver', 'pickup', confirmed=True)
        with self.assertRaises(app.Problem):
            self.cmd('recovery', 'process')
        self.cmd('recovery', 'receive', measuredKg=9, suitable=True, confirmed=True)
        self.cmd('recovery', 'process')
        with self.assertRaises(app.Problem):
            self.cmd('recovery', 'complete', output='Feed', residue='', confirmed=True)
        b = self.cmd('recovery', 'complete', output='1 kg dried larvae', residue='8 kg residue transferred to compost', confirmed=True)
        self.assertEqual(b['stage'], 'completed')
        self.assertEqual(b['measuredKg'], 9)

    def test_rejected_load_not_counted_as_recovered(self):
        self.create(waste=True)
        self.cmd('recovery', 'assess', route='Compost', confirmed=True)
        self.cmd('driver', 'claim')
        self.cmd('driver', 'pickup', confirmed=True)
        b = self.cmd('recovery', 'receive', measuredKg=10, suitable=False, confirmed=True, reason='Packaging contamination')
        self.assertEqual(b['stage'], 'rejected')
        self.assertNotIn('completedAt', b)

    def test_capacity_and_verification(self):
        self.create()
        self.people['recipient']['approved'] = 0
        with self.assertRaises(app.Problem): self.cmd('recipient', 'accept')
        self.people['recipient']['approved'] = 1
        self.people['recipient']['capacity'] = 5
        with self.assertRaises(app.Problem): self.cmd('recipient', 'accept')

    def test_same_recipient_route_first_and_transfer_acceptance(self):
        self.transit()
        self.db.execute("INSERT INTO users SELECT 'closer','closer@test.local','Closer','recipient',salt,password,1,100,location,1 FROM users WHERE id='recipient'")
        self.cmd('driver', 'delay', eta=100, alternativeEta=10)
        with self.assertRaises(app.Problem):
            self.cmd('admin', 'offer', target='closer', eta=5, reason='Closer recipient available')
        b = self.cmd('driver', 'reroute')
        self.assertEqual(b['recipientId'], 'recipient')
        self.cmd('driver', 'delay', eta=100, alternativeEta=100)
        b = self.cmd('admin', 'offer', target='closer', eta=5, reason='Closer recipient available')
        self.assertEqual(b['recipientId'], 'recipient')
        self.people['closer'] = dict(self.db.execute("SELECT * FROM users WHERE id='closer'").fetchone())
        b = self.cmd('closer', 'accept')
        self.assertEqual(b['recipientId'], 'closer')
        self.assertEqual(b['driverId'], 'driver')
        self.assertEqual(b['stage'], 'transit')

    def test_admin_pause_and_audit(self):
        self.cmd('admin', 'pause', paused=True, reason='Review policy update')
        s = app.state(self.db)
        self.assertTrue(s['paused'])
        self.assertIn('Review policy update', s['events'][0]['message'])

    def test_gemini_cannot_invent_valid_route(self):
        self.transit()
        self.cmd('driver', 'delay', eta=100, alternativeEta=100)
        b = app.state(self.db)['batches'][0]
        reply = {'candidates': [{'content': {'parts': [{'text': json.dumps({'decisions': [{'id': b['id'], 'action': 'reroute', 'reason': 'Model suggests a route'}]})}]}}]}
        from io import BytesIO
        with patch.dict('os.environ', {'GEMINI_API_KEY': 'test-key', 'GEMINI_MODEL': 'test-model'}), patch('urllib.request.urlopen', return_value=BytesIO(json.dumps(reply).encode())):
            app.coordinate()
        self.db.close()
        self.db = app.connect()
        b = app.state(self.db)['batches'][0]
        self.assertEqual(b['eta'], 100)
        self.assertTrue(b['incident'])

    def test_http_registration_login_verification_and_logout(self):
        import threading
        import urllib.request
        from urllib.error import HTTPError
        server = app.ThreadingHTTPServer(('127.0.0.1', 0), app.Handler)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        base = f'http://127.0.0.1:{server.server_port}'
        def request(path, data=None, token=None):
            headers = {'Content-Type': 'application/json'}
            if token: headers['Authorization'] = 'Bearer ' + token
            req = urllib.request.Request(base+path, headers=headers, data=json.dumps(data).encode() if data is not None else None)
            with urllib.request.urlopen(req) as response:
                return json.load(response)
        try:
            request('/register', {'role': 'recipient', 'email': 'new@test.local', 'password': 'test-password-123', 'name': 'New recipient', 'location': 'Test location', 'capacity': 20})
            token = request('/login', {'email': 'new@test.local', 'password': 'test-password-123'})['token']
            data = request('/state', token=token)
            self.assertEqual(data['user']['approved'], 0)
            self.assertNotIn('password', data['user'])
            with self.assertRaises(HTTPError) as denied:
                request('/command', {'action': 'availability', 'available': True}, token)
            self.assertEqual(denied.exception.code, 403)
            denied.exception.close()
            request('/logout', {}, token)
            with self.assertRaises(HTTPError) as expired:
                request('/state', token=token)
            self.assertEqual(expired.exception.code, 401)
            expired.exception.close()
        finally:
            server.shutdown()
            server.server_close()
            thread.join(timeout=2)

    def test_prepared_data_has_roles_routes_timings_and_expiry_recovery(self):
        app.seed_prepared(self.db, replace=True)
        self.db.commit()
        s = app.state(self.db)
        prepared = {b['id']: b for b in s['batches'] if b['id'] in {'RH-201', 'RH-202', 'RH-203', 'RH-204', 'RH-205'}}
        self.assertEqual(len(prepared), 5)
        self.assertEqual(prepared['RH-202']['stage'], 'transit')
        self.assertLess(prepared['RH-202']['alternativeEta'], prepared['RH-202']['eta'])
        self.assertIn('alternativeRouteSummary', prepared['RH-202'])
        self.assertEqual(prepared['RH-204']['stage'], 'waste')
        self.assertEqual(prepared['RH-205']['stage'], 'completed')
        self.assertGreater(prepared['RH-203']['deadline'], time.time())

        prepared['RH-203']['deadline'] = time.time() - 1
        app.save(self.db, s)
        driver = dict(self.db.execute("SELECT * FROM users WHERE id='role-driver'").fetchone())
        visible = app.load_for(self.db, driver)
        expired = next(b for b in visible['batches'] if b['id'] == 'RH-203')
        self.assertEqual(expired['stage'], 'waste')
        self.assertIn('expiredAt', expired)
        self.assertEqual(expired['custodianId'], 'role-driver')


if __name__ == '__main__':
    unittest.main()
