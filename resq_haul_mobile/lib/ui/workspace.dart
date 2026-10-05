import 'package:flutter/material.dart';
import '../data/network_service.dart';
import 'design.dart';

const roleNames = {
  'sender': 'Sender',
  'recipient': 'Recipient',
  'driver': 'Driver / Hauler',
  'recovery': 'Recovery Facility',
  'admin': 'Admin',
};
const stages = {
  'listed': 'Awaiting recipient',
  'accepted': 'Awaiting driver',
  'assigned': 'Ready for pickup',
  'transit': 'On the way',
  'delivered': 'Delivered',
  'waste': 'Needs recovery',
  'assessed': 'Awaiting hauler',
  'recoveryAssigned': 'Recovery pickup',
  'collected': 'Awaiting inspection',
  'facilityAccepted': 'Ready to process',
  'processing': 'In processing',
  'completed': 'Recovered',
  'rejected': 'Needs reassessment',
  'cancelled': 'Cancelled',
};

class PrototypeApp extends StatelessWidget {
  const PrototypeApp({super.key, required this.service});
  final NetworkService service;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ResQ-Haul',
    debugShowCheckedModeBanner: false,
    theme: appTheme(),
    home: Workspace(service: service),
  );
}

class Workspace extends StatefulWidget {
  const Workspace({super.key, required this.service});
  final NetworkService service;
  @override
  State<Workspace> createState() => _WorkspaceState();
}

class _WorkspaceState extends State<Workspace> {
  NetworkService get api => widget.service;
  int tab = 0;
  bool busy = false;
  String search = '';
  String filter = 'Active';
  String get uid => api.user['id'] ?? '';
  bool get admin => api.role == 'admin';
  Future<void> run(Future<void> Function() fn) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await fn();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: api,
    builder: (context, _) {
      if (api.state == null) return SignIn(service: api);
      final wide = MediaQuery.sizeOf(context).width >= 900;
      final destinations = [
        admin ? 'Network' : 'Workspace',
        'Recoveries',
        'Activity',
        admin ? 'Manage' : 'Account',
      ];
      const icons = [
        Icons.space_dashboard_outlined,
        Icons.route_outlined,
        Icons.notifications_outlined,
        Icons.manage_accounts_outlined,
      ];
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              if (wide)
                Container(
                  width: 210,
                  decoration: const BoxDecoration(
                    color: Palette.panel,
                    border: Border(right: BorderSide(color: Palette.line)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: DashboardLogo(width: 64),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: BrandWordmark(size: 26),
                      ),
                      gap(32),
                      for (var i = 0; i < destinations.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            selected: tab == i,
                            selectedTileColor: Palette.brandSurface,
                            selectedColor: Palette.accent,
                            leading: Icon(icons[i]),
                            title: Text(destinations[i]),
                            onTap: () => setState(() => tab = i),
                          ),
                        ),
                      const Spacer(),
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Good food.\nBetter futures.',
                          style: TextStyle(color: Palette.muted, height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: RefreshIndicator(
                      onRefresh: api.refresh,
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          Row(
                            children: [
                              const DashboardLogo(width: 56),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const BrandWordmark(size: 17),
                                    Text(
                                      roleNames[api.role] ?? '',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Refresh',
                                onPressed: api.refresh,
                                icon: const Icon(Icons.refresh),
                              ),
                              IconButton(
                                tooltip: 'Sign out',
                                onPressed: busy ? null : () => run(api.logout),
                                icon: const Icon(Icons.logout),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(height: 1, color: Palette.line),
                          ),
                          if (busy) const LinearProgressIndicator(),
                          if (api.error != null)
                            SmallNote(api.error!, warning: true),
                          if (api.user['approved'] != 1) ...[
                            const Editorial('Verification pending', size: 34),
                            gap(12),
                            const Text(
                              'An admin must verify your account before you can accept food or collections. Your account is ready; check back after verification.',
                            ),
                          ] else
                            ...switch (tab) {
                              0 => dashboard(),
                              1 => listings(),
                              2 => activity(),
                              _ => account(),
                            },
                          gap(30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: tab,
                onDestinationSelected: (v) => setState(() => tab = v),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.space_dashboard_outlined),
                    label: admin ? 'Network' : 'Workspace',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.route_outlined),
                    label: 'Recoveries',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.notifications_outlined),
                    label: 'Activity',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.manage_accounts_outlined),
                    label: admin ? 'Manage' : 'Account',
                  ),
                ],
              ),
      );
    },
  );
  List<Widget> dashboard() {
    final active = api.batches
        .where(
          (b) => !['delivered', 'completed', 'cancelled'].contains(b['stage']),
        )
        .toList();
    final issues = active
        .where((b) => b['incident'] != null && b['incident'] != '')
        .toList();
    final recovered = api.batches
        .where((b) => ['delivered', 'completed'].contains(b['stage']))
        .fold<double>(0, (a, b) => a + (b['measuredKg'] ?? b['kg']).toDouble());
    final titles = {
      'sender': 'Your surplus, in motion.',
      'recipient': 'Community collections.',
      'driver': 'Today’s collections.',
      'recovery': 'Recovery operations.',
      'admin': 'Network overview.',
    };
    final descriptions = {
      'sender':
          'List surplus from your event, home or business. Follow every handover.',
      'recipient':
          'Accept food you can use, then confirm its arrival with your handover code.',
      'driver':
          'Accept a task, confirm collection and keep arrival estimates current.',
      'recovery':
          'Review suitability, inspect incoming loads and record recovery outputs.',
      'admin':
          'Verify partners, resolve exceptions and oversee AI coordination.',
    };
    return [
      Text(
        api.user['name'].toString(),
        style: const TextStyle(color: Palette.muted),
      ),
      gap(8),
      Editorial(titles[api.role]!, size: 32),
      gap(10),
      Text(
        descriptions[api.role]!,
        style: const TextStyle(color: Palette.muted, height: 1.5),
      ),
      gap(24),
      Row(
        children: [
          Expanded(
            child: metric('${active.length}', 'In progress', highlight: true),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: metric(
              '${recovered.toStringAsFixed(1)} kg',
              'Confirmed recovery',
            ),
          ),
        ],
      ),
      gap(18),
      if (api.role == 'sender')
        FilledButton.icon(
          onPressed: busy ? null : createListing,
          icon: const Icon(Icons.add),
          label: const Text('List surplus or organic material'),
        ),
      gap(20),
      if (issues.isNotEmpty) ...[
        Surface(
          color: Palette.attentionSurface,
          padding: 16,
          child: Row(
            children: [
              const Icon(Icons.priority_high_rounded, color: Palette.warning),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${issues.length} ${issues.length == 1 ? 'journey needs' : 'journeys need'} attention',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Palette.warning,
                      ),
                    ),
                    gap(4),
                    const Text(
                      'Review timing or recovery before the next handover.',
                      style: TextStyle(
                        color: Palette.muted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        gap(24),
      ],
      Row(
        children: [
          Expanded(
            child: Text(
              'Your recovery queue',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${active.length}',
            style: const TextStyle(color: Palette.accent),
          ),
        ],
      ),
      gap(12),
      if (active.isEmpty)
        empty(
          'A fresh start',
          api.role == 'sender'
              ? 'Your listings and progress will appear here once you publish surplus.'
              : 'No tasks are available yet. New requests will appear here as the network updates.',
        ),
      journeyGrid([...issues, ...active.where((b) => !issues.contains(b))]),
      if (admin) ...[gap(16), coordinator()],
    ];
  }

  Widget metric(String value, String label, {bool highlight = false}) =>
      Surface(
        color: highlight ? Palette.accent : Palette.attentionSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                color: highlight ? Palette.bg : Palette.orangeInk,
                fontWeight: FontWeight.w600,
              ),
            ),
            gap(8),
            Text(
              label,
              style: TextStyle(
                color: highlight ? Palette.bg : Palette.warning,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
  Widget empty(String title, String body) => Surface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.eco_outlined, color: Palette.accent, size: 30),
        gap(14),
        Text(title, style: const TextStyle(fontSize: 20)),
        gap(8),
        Text(body, style: const TextStyle(color: Palette.muted, height: 1.5)),
      ],
    ),
  );
  Widget coordinator() => Surface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('AI COORDINATOR'),
        gap(12),
        Text(
          api.state!['paused']
              ? 'Paused by admin'
              : api.state!['geminiConfigured']
              ? api.state!['ai']['status']
              : 'Automated coordination active',
          style: const TextStyle(fontSize: 20),
        ),
        gap(8),
        Text(
          api.state!['geminiConfigured']
              ? 'Gemini reviews journey risk. Every route and handover is still validated by the server.'
              : 'Approved time windows, automatic expiry and role transitions work locally. Gemini is optional.',
          style: const TextStyle(color: Palette.muted, height: 1.5),
        ),
        gap(14),
        OutlinedButton(
          onPressed: busy
              ? null
              : () async {
                  final f = await fieldsDialog('Coordination control', {
                    'reason': 'Reason for this change',
                  });
                  if (f != null) {
                    run(
                      () => api.command(
                        'pause',
                        fields: {...f, 'paused': !api.state!['paused']},
                      ),
                    );
                  }
                },
          child: Text(
            api.state!['paused'] ? 'Resume coordination' : 'Pause coordination',
          ),
        ),
        gap(8),
        TextButton.icon(
          onPressed: busy ? null : restartJourneys,
          icon: const Icon(Icons.restart_alt),
          label: const Text('Restart journey timings'),
        ),
      ],
    ),
  );

  Future<void> restartJourneys() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart journey timings?'),
        content: const Text(
          'This refreshes the five prepared journeys and restarts their time windows. Other accounts and listings remain available.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restart journeys'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await run(() => api.command('resetPrepared'));
    }
  }

  List<Widget> listings() {
    final list = api.batches
        .where(
          (b) => '${b['name']} ${b['source']} ${b['id']}'
              .toLowerCase()
              .contains(search.toLowerCase()),
        )
        .where(
          (b) =>
              filter == 'All' ||
              (filter == 'Finished'
                  ? ['delivered', 'completed', 'cancelled'].contains(b['stage'])
                  : ![
                      'delivered',
                      'completed',
                      'cancelled',
                    ].contains(b['stage'])),
        )
        .toList();
    return [
      const Editorial('Every recovery.', size: 36),
      gap(20),
      TextField(
        onChanged: (v) => setState(() => search = v),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search food, sender or reference',
        ),
      ),
      gap(12),
      Wrap(
        spacing: 8,
        children: ['Active', 'Finished', 'All']
            .map(
              (v) => ChoiceChip(
                label: Text(v),
                selected: filter == v,
                onSelected: (_) => setState(() => filter = v),
              ),
            )
            .toList(),
      ),
      gap(16),
      if (list.isEmpty)
        empty(
          'Nothing here yet',
          'Try another filter or check back for new recoveries.',
        ),
      Text(
        '${list.length} ${list.length == 1 ? 'recovery' : 'recoveries'}',
        style: const TextStyle(color: Palette.muted, fontSize: 12),
      ),
      gap(12),
      journeyGrid(list),
    ];
  }

  String nameFor(dynamic id) {
    for (final u in api.state?['users'] ?? []) {
      if (u['id'] == id) return u['name'];
    }
    return 'Awaiting assignment';
  }

  Widget journeyGrid(List<Map<String, dynamic>> batches) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 680 ? 2 : 1;
      final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
      return Wrap(
        spacing: 16,
        children: [
          for (final b in batches) SizedBox(width: width, child: batchCard(b)),
        ],
      );
    },
  );

  String timeLeft(Map<String, dynamic> b) {
    final minutes = (((b['deadline'] as num) - api.now) / 60).ceil();
    return minutes > 0 ? '$minutes min remaining' : 'Food window elapsed';
  }

  Widget information(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(color: Palette.muted, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, height: 1.4)),
        ),
      ],
    ),
  );

  Widget batchCard(Map<String, dynamic> b) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Surface(
      onTap: () => details(b['id']),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  b['id'],
                  style: const TextStyle(
                    color: Palette.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${b['kg']} kg',
                style: const TextStyle(
                  color: Palette.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          gap(12),
          Text(
            b['name'],
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          gap(6),
          Text(
            '${b['source']} · ${b['category']}',
            style: const TextStyle(color: Palette.muted),
          ),
          gap(16),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Palette.muted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  b['routeOrigin'] ??
                      b['location'] ??
                      'Pickup location pending',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Palette.muted, fontSize: 12),
                ),
              ),
              if (b['eta'] != null)
                Text(
                  '${b['eta']} min ETA',
                  style: const TextStyle(color: Palette.text, fontSize: 12),
                ),
            ],
          ),
          gap(14),
          const Divider(height: 1, color: Palette.line),
          gap(14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                stages[b['stage']] ?? b['stage'],
                style: const TextStyle(
                  color: Palette.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              if ([
                'listed',
                'accepted',
                'assigned',
                'transit',
              ].contains(b['stage']))
                Text(
                  '· ${timeLeft(b)}',
                  style: const TextStyle(color: Palette.muted, fontSize: 12),
                ),
              if (b['incident'] != null && b['incident'] != '')
                const Text(
                  'Needs attention',
                  style: TextStyle(color: Palette.warning, fontSize: 12),
                ),
            ],
          ),
          gap(12),
          const Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View journey',
                  style: TextStyle(
                    color: Palette.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 18, color: Palette.accent),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  List<Widget> activity() => [
    const Editorial('The latest.', size: 36),
    gap(12),
    const Text(
      'Shared handovers, decisions and updates.',
      style: TextStyle(color: Palette.muted),
    ),
    gap(20),
    if ((api.state!['events'] as List).isEmpty)
      empty(
        'All caught up',
        'Updates will appear as recoveries move through the network.',
      ),
    ...(api.state!['events'] as List).map(
      (e) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow('${e['batchId']} · ${e['actor']}'),
              gap(8),
              Text(e['message']),
              gap(8),
              Text(
                DateTime.fromMillisecondsSinceEpoch(
                  ((e['at'] as num) * 1000).toInt(),
                ).toLocal().toString().substring(0, 16),
                style: const TextStyle(color: Palette.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ),
  ];
  List<Widget> account() => [
    Editorial(admin ? 'Network management.' : 'Your account.', size: 34),
    gap(20),
    Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(api.user['name'], style: const TextStyle(fontSize: 22)),
          gap(8),
          Text('${roleNames[api.role]} · ${api.user['location']}'),
          gap(8),
          Text('Capacity: ${api.user['capacity']} kg'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Available for new tasks'),
            value: api.user['available'] == 1,
            onChanged: busy
                ? null
                : (v) => run(
                    () => api.command('availability', fields: {'available': v}),
                  ),
          ),
        ],
      ),
    ),
    if (admin) ...[
      gap(20),
      const Eyebrow('PARTNER VERIFICATION'),
      gap(12),
      ...(api.state!['users'] as List)
          .where((u) => u['role'] != 'admin')
          .map(
            (u) => Card(
              child: ListTile(
                title: Text(u['name']),
                subtitle: Text(
                  '${roleNames[u['role']]} · ${u['location']}\n${u['approved'] == 1 ? 'Verified' : 'Pending verification'}',
                ),
                isThreeLine: true,
                trailing: IconButton(
                  tooltip: u['approved'] == 1
                      ? 'Suspend account'
                      : 'Verify account',
                  icon: Icon(
                    u['approved'] == 1 ? Icons.verified : Icons.person_add_alt,
                  ),
                  onPressed: busy
                      ? null
                      : () async {
                          final f = await fieldsDialog(
                            'Verify partner details',
                            {'reason': 'Verification or suspension reason'},
                          );
                          if (f != null) {
                            run(
                              () => api.command(
                                'approve',
                                fields: {
                                  ...f,
                                  'userId': u['id'],
                                  'approved': u['approved'] != 1,
                                },
                              ),
                            );
                          }
                        },
                ),
              ),
            ),
          ),
    ],
  ];
  Future<Map<String, dynamic>?> fieldsDialog(
    String title,
    Map<String, String> fields, {
    String? confirmation,
  }) async {
    final controllers = {
      for (final k in fields.keys) k: TextEditingController(),
    };
    bool checked = confirmation == null;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, set) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final entry in fields.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: entry.key == 'target' || entry.key == 'route'
                          ? DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: entry.key == 'target'
                                    ? 'Recipient'
                                    : 'Recovery route',
                              ),
                              items: entry.key == 'route'
                                  ? ['BSFL', 'Compost', 'Biogas']
                                        .map(
                                          (v) => DropdownMenuItem(
                                            value: v,
                                            child: Text(v),
                                          ),
                                        )
                                        .toList()
                                  : (api.state!['users'] as List)
                                        .where(
                                          (u) =>
                                              u['role'] == 'recipient' &&
                                              u['approved'] == 1,
                                        )
                                        .map(
                                          (u) => DropdownMenuItem<String>(
                                            value: u['id'],
                                            child: Text(u['name']),
                                          ),
                                        )
                                        .toList(),
                              onChanged: (v) =>
                                  controllers[entry.key]!.text = v ?? '',
                            )
                          : TextField(
                              controller: controllers[entry.key],
                              decoration: InputDecoration(
                                labelText: entry.value,
                              ),
                            ),
                    ),
                  if (confirmation != null)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: checked,
                      title: Text(confirmation),
                      onChanged: (v) => set(() => checked = v ?? false),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: checked
                  ? () => Navigator.pop(context, {
                      for (final e in controllers.entries) e.key: e.value.text,
                      'confirmed': checked,
                    })
                  : null,
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
    // Dispose after the dialog's exit animation has released its text fields.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    for (final c in controllers.values) {
      c.dispose();
    }
    return result;
  }

  Future<void> perform(
    String action,
    Map<String, dynamic> b, {
    Map<String, String> fields = const {},
    String? confirmation,
    Map<String, dynamic> extra = const {},
  }) async {
    final input = await fieldsDialog(
      actionTitles[action] ?? action,
      fields,
      confirmation:
          confirmation ?? 'I confirm this action and the details recorded.',
    );
    if (input != null) {
      await run(
        () => api.command(
          action == 'reject' ? 'receive' : action,
          batch: b,
          fields: {
            ...input,
            ...extra,
            if (action == 'reject') 'suitable': false,
          },
        ),
      );
    }
  }

  Future<void> details(String id) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .9,
        minChildSize: .4,
        maxChildSize: .95,
        builder: (context, scroll) => ListenableBuilder(
          listenable: api,
          builder: (context, _) {
            final matches = api.batches.where((b) => b['id'] == id);
            if (matches.isEmpty) {
              return const Center(
                child: Text('This listing is no longer available.'),
              );
            }
            final b = matches.first;
            final stage = b['stage'];
            final ownDriver = b['driverId'] == uid;
            final ownFacility = b['facilityId'] == uid;
            Widget button(
              String action, {
              Map<String, String> fields = const {},
              String? confirmation,
              Map<String, dynamic> extra = const {},
            }) => Padding(
              padding: const EdgeInsets.only(top: 10),
              child: FilledButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await perform(
                    action,
                    b,
                    fields: fields,
                    confirmation: confirmation,
                    extra: extra,
                  );
                },
                child: Text(actionTitles[action] ?? action),
              ),
            );
            return ListView(
              controller: scroll,
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    Expanded(child: Eyebrow(b['id'])),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Editorial(b['name'], size: 32),
                gap(14),
                Text('${stages[stage]} · ${b['kg']} kg'),
                gap(16),
                Surface(
                  padding: 16,
                  child: Column(
                    children: [
                      information('Pickup', '${b['location']}'),
                      information(
                        'Destination',
                        b['routeDestination'] ?? nameFor(b['recipientId']),
                      ),
                      information(
                        'Held by',
                        nameFor(b['custodianId'] ?? b['senderId']),
                      ),
                    ],
                  ),
                ),
                if (b['routeSummary'] != null) ...[
                  gap(14),
                  const Eyebrow('ROUTING'),
                  gap(7),
                  RouteMap(
                    origin: b['routeOrigin'] ?? b['location'],
                    destination:
                        b['routeDestination'] ?? nameFor(b['recipientId']),
                    currentEta: (b['eta'] as num).round(),
                    alternativeEta: b['alternativeEta'] == null
                        ? null
                        : (b['alternativeEta'] as num).round(),
                    expired: stage == 'waste',
                  ),
                  gap(10),
                  Text(
                    b['rerouted'] == true
                        ? (b['alternativeRouteSummary'] ?? b['routeSummary'])
                        : b['routeSummary'],
                  ),
                  if (b['alternativeRouteSummary'] != null) ...[
                    gap(6),
                    Text(
                      b['alternativeRouteSummary'],
                      style: const TextStyle(color: Palette.accent),
                    ),
                  ],
                ],
                gap(20),
                const Text(
                  'Handling & partners',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                gap(8),
                information('Sender', '${b['source']} (${b['senderType']})'),
                information('Storage', '${b['storage']}'),
                information('Allergens', '${b['allergens']}'),
                information(
                  'Offer',
                  b['donate'] ? 'Donation' : 'Sale · RM ${b['price']}',
                ),
                information('Recipient', nameFor(b['recipientId'])),
                information('Driver', nameFor(b['driverId'])),
                information('Facility', nameFor(b['facilityId'])),
                if (stage == 'waste' && b['expiredAt'] != null) ...[
                  gap(12),
                  const SmallNote(
                    'The approved food window has elapsed. This batch is now available to verified recovery facilities.',
                    warning: true,
                  ),
                ],
                if (b['recommendation'] != null) ...[
                  gap(14),
                  SmallNote(
                    'Gemini recommendation: ${nameFor(b['recommendation']['target'])}. ${b['recommendation']['reason']}',
                  ),
                ],
                if ([
                  'listed',
                  'accepted',
                  'assigned',
                  'transit',
                ].contains(stage)) ...[
                  gap(14),
                  Text(
                    '${timeLeft(b)} · Estimated journey ${b['eta']} min',
                    style: const TextStyle(color: Palette.accent),
                  ),
                ],
                if (b['handoverCode'] != null && stage != 'delivered') ...[
                  gap(20),
                  Surface(
                    child: Column(
                      children: [
                        const Eyebrow('YOUR HANDOVER CODE'),
                        gap(10),
                        SelectableText(
                          b['handoverCode'],
                          style: const TextStyle(
                            fontSize: 32,
                            letterSpacing: 6,
                            color: Palette.accent,
                          ),
                        ),
                        const Text(
                          'Share with the driver only after checking the food.',
                        ),
                      ],
                    ),
                  ),
                ],
                if (b['incident'] != null && b['incident'] != '') ...[
                  gap(14),
                  SmallNote(b['incident'], warning: true),
                ],
                if (b['receipt'] != null) ...[
                  gap(12),
                  SelectableText('Delivery receipt: ${b['receipt']}'),
                ],
                if (api.role == 'recipient' &&
                    (stage == 'listed' || b['offer']?['target'] == uid))
                  button(
                    'accept',
                    confirmation:
                        'I can receive this quantity within the approved food window.',
                  ),
                if (b['offer']?['target'] == uid) button('decline'),
                if (api.role == 'driver' &&
                    ['accepted', 'assessed'].contains(stage))
                  button('claim'),
                if (ownDriver &&
                    ['assigned', 'recoveryAssigned'].contains(stage))
                  button(
                    'pickup',
                    confirmation:
                        'I checked the packaging and condition and collected the load.',
                  ),
                if (ownDriver && stage == 'transit')
                  button(
                    'deliver',
                    fields: {'code': 'Recipient handover code'},
                    confirmation:
                        'The recipient inspected and accepted the food.',
                  ),
                if (ownDriver && ['assigned', 'transit'].contains(stage)) ...[
                  button(
                    'delay',
                    fields: {
                      'eta': 'Current arrival estimate (minutes)',
                      'alternativeEta':
                          'Same-recipient alternative route (minutes)',
                    },
                  ),
                  button('reroute'),
                ],
                if (admin &&
                    ['accepted', 'assigned', 'transit'].contains(stage))
                  button(
                    'offer',
                    fields: {
                      'target': 'Verified recipient',
                      'eta': 'Verified journey estimate (minutes)',
                      'reason': 'Reason for recipient transfer',
                    },
                  ),
                if (api.role == 'sender' &&
                    b['senderId'] == uid &&
                    stage == 'listed')
                  button('cancel', fields: {'reason': 'Cancellation reason'}),
                if ([
                      'listed',
                      'accepted',
                      'assigned',
                      'transit',
                    ].contains(stage) &&
                    (admin ||
                        ownDriver ||
                        b['senderId'] == uid ||
                        b['recipientId'] == uid))
                  button(
                    'waste',
                    fields: {
                      'reason': 'Reason food is unsuitable for redistribution',
                    },
                  ),
                if (api.role == 'recovery' &&
                    ['waste', 'rejected'].contains(stage))
                  button(
                    'assess',
                    fields: {
                      'route': 'Recovery route: BSFL, Compost or Biogas',
                    },
                    confirmation:
                        'I verified material suitability, separation from packaging and facility capacity.',
                  ),
                if (ownFacility && stage == 'collected') ...[
                  button(
                    'receive',
                    fields: {'measuredKg': 'Measured weight (kg)'},
                    confirmation:
                        'I inspected this load and accept it for controlled processing.',
                    extra: {'suitable': true},
                  ),
                  button(
                    'reject',
                    fields: {
                      'measuredKg': 'Measured weight (kg)',
                      'reason': 'Inspection rejection reason',
                    },
                  ),
                ],
                if (ownFacility && stage == 'facilityAccepted')
                  button('process'),
                if (ownFacility && stage == 'processing')
                  button(
                    'complete',
                    fields: {
                      'output': 'Recovered output and quantity',
                      'residue': 'Residue treatment record',
                    },
                    confirmation:
                        'Processing, output checks and residue treatment are complete.',
                  ),
                if (admin && b['incident'] != null && b['incident'] != '')
                  button(
                    'resolve',
                    fields: {'reason': 'Resolution and follow-up'},
                  ),
                if (admin ||
                    ownDriver ||
                    ownFacility ||
                    b['senderId'] == uid ||
                    b['recipientId'] == uid)
                  button('incident', fields: {'reason': 'Describe the issue'}),
                gap(26),
                const Eyebrow('CHAIN OF CUSTODY'),
                gap(12),
                ...(b['history'] as List).reversed.map(
                  (e) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.check_circle_outline,
                      color: Palette.accent,
                    ),
                    title: Text(e['message']),
                    subtitle: Text(e['actor']),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> createListing() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ListingForm(service: api)),
    );
  }
}

const actionTitles = {
  'accept': 'Accept food',
  'decline': 'Decline transfer',
  'claim': 'Accept collection task',
  'pickup': 'Confirm pickup',
  'deliver': 'Verify handover',
  'delay': 'Update arrival estimates',
  'reroute': 'Use alternative route',
  'offer': 'Offer to closer recipient',
  'waste': 'Divert to recovery',
  'cancel': 'Cancel listing',
  'assess': 'Accept recovery request',
  'receive': 'Record facility acceptance',
  'reject': 'Reject inspected load',
  'process': 'Start processing',
  'complete': 'Record recovery outputs',
  'incident': 'Report an issue',
  'resolve': 'Resolve incident',
};

class SignIn extends StatefulWidget {
  const SignIn({super.key, required this.service});
  final NetworkService service;
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final form = GlobalKey<FormState>();
  final values = <String, String>{};
  bool registering = false, busy = false, revealPassword = false;
  String role = 'sender';
  String? message;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: BrandLogo(width: 112)),
                  gap(10),
                  const Center(child: BrandWordmark(size: 30)),
                  gap(28),
                  const Eyebrow('GOOD FOOD. BETTER FUTURES.'),
                  gap(12),
                  Editorial(
                    registering ? 'Join the recovery.' : 'Welcome back.',
                    size: 38,
                  ),
                  gap(12),
                  Text(
                    registering
                        ? 'One account. A clear role in a better food cycle.'
                        : 'Sign in to your ResQ-Haul workspace.',
                    style: const TextStyle(color: Palette.muted),
                  ),
                  gap(24),
                  if (registering) ...[
                    input('name', 'Your name or organisation'),
                    DropdownButtonFormField<String>(
                      initialValue: role,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Your role'),
                      items: roleNames.entries
                          .where((e) => e.key != 'admin')
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => role = v!),
                    ),
                    gap(12),
                    input('location', 'Area / collection address'),
                    input('capacity', 'Daily capacity (kg)', numeric: true),
                  ],
                  input('email', 'Email address'),
                  input('password', 'Password', password: true),
                  if (message != null) ...[
                    SmallNote(message!, warning: true),
                    gap(12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: busy ? null : submit,
                      child: Text(
                        busy
                            ? 'Please wait…'
                            : registering
                            ? 'Create account'
                            : 'Sign in',
                      ),
                    ),
                  ),
                  gap(12),
                  Center(
                    child: TextButton(
                      onPressed: busy
                          ? null
                          : () => setState(() {
                              registering = !registering;
                              message = null;
                            }),
                      child: Text(
                        registering
                            ? 'Already registered? Sign in'
                            : 'New here? Create an account',
                      ),
                    ),
                  ),
                  if (registering)
                    const Text(
                      'Recipient, driver and facility accounts require admin verification.',
                      style: TextStyle(color: Palette.muted, fontSize: 12),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  Widget input(
    String key,
    String label, {
    bool password = false,
    bool numeric = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      key: ValueKey(key),
      obscureText: password && !revealPassword,
      autofillHints: key == 'email'
          ? const [AutofillHints.email]
          : password
          ? const [AutofillHints.password]
          : null,
      textInputAction: password ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: password ? (_) => busy ? null : submit() : null,
      keyboardType: numeric
          ? TextInputType.number
          : key == 'email'
          ? TextInputType.emailAddress
          : TextInputType.text,
      autocorrect: !password,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: password
            ? IconButton(
                tooltip: revealPassword ? 'Hide password' : 'Show password',
                onPressed: () =>
                    setState(() => revealPassword = !revealPassword),
                icon: Icon(
                  revealPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              )
            : null,
      ),
      onSaved: (v) => values[key] = v!.trim(),
      validator: (v) => v == null || v.trim().isEmpty
          ? 'Required'
          : password && registering && v.length < 10
          ? 'Use at least 10 characters'
          : null,
    ),
  );
  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    form.currentState!.save();
    setState(() {
      busy = true;
      message = null;
    });
    try {
      if (registering) {
        await widget.service.request('/register', {...values, 'role': role});
        if (mounted) {
          setState(() {
            registering = false;
            message = 'Account created. Sign in to continue.';
          });
        }
      } else {
        await widget.service.login(values['email']!, values['password']!);
        if (widget.service.state == null) {
          throw Exception(
            'Signed in, but the workspace could not load. Try again.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => message = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class ListingForm extends StatefulWidget {
  const ListingForm({super.key, required this.service});
  final NetworkService service;
  @override
  State<ListingForm> createState() => _ListingFormState();
}

class _ListingFormState extends State<ListingForm> {
  final form = GlobalKey<FormState>();
  final values = <String, String>{};
  bool confirmed = false, waste = false, donate = true, busy = false;
  String senderType = 'Individual / household',
      category = 'Meals',
      storage = 'Chilled';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('New listing')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Form(
          key: form,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Eyebrow('A SECOND CHANCE STARTS HERE'),
              gap(12),
              const Editorial('What can you share?', size: 34),
              gap(20),
              dropdown('Sender type', senderType, [
                'Individual / household',
                'Event host',
                'Restaurant / kitchen',
                'Retailer',
                'Other organisation',
              ], (v) => senderType = v),
              input('name', 'Food or material description'),
              input('location', 'Pickup address and access instructions'),
              dropdown('Category', category, [
                'Meals',
                'Rice',
                'Bread',
                'Produce',
                'Separated organics',
              ], (v) => category = v),
              input('kg', 'Quantity (kg)', numeric: true),
              dropdown('Storage', storage, [
                'Chilled',
                'Hot-held',
                'Frozen',
                'Ambient, packed',
              ], (v) => storage = v),
              input(
                'allergens',
                'Allergens / ingredients (use Unknown if unsure)',
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Organic recovery only'),
                subtitle: const Text(
                  'Material unsuitable for redistribution as food',
                ),
                value: waste,
                onChanged: (v) => setState(() => waste = v),
              ),
              if (!waste) ...[
                input(
                  'minutes',
                  'Approved remaining food window (minutes)',
                  numeric: true,
                ),
                input(
                  'eta',
                  'Estimated collection and delivery time (minutes)',
                  numeric: true,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Offer as a donation'),
                  value: donate,
                  onChanged: (v) => setState(() => donate = v),
                ),
                if (!donate)
                  input('price', 'Total asking price (RM)', numeric: true),
              ],
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: confirmed,
                onChanged: (v) => setState(() => confirmed = v ?? false),
                title: const Text(
                  'I checked the quantity, handling details and suitability. The food window is an approved limit, not an AI safety estimate.',
                ),
              ),
              gap(16),
              FilledButton(
                onPressed: !confirmed || busy ? null : submit,
                child: Text(busy ? 'Publishing…' : 'Publish listing'),
              ),
              gap(30),
            ],
          ),
        ),
      ),
    ),
  );
  Widget input(String key, String label, {bool numeric = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      key: ValueKey(key),
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      validator: (v) => v == null || v.trim().isEmpty
          ? 'Required'
          : numeric && double.tryParse(v) == null
          ? 'Enter a number'
          : null,
      onSaved: (v) => values[key] = v!.trim(),
    ),
  );
  Widget dropdown(
    String label,
    String value,
    List<String> choices,
    void Function(String) change,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: choices
          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
          .toList(),
      onChanged: (v) => setState(() => change(v!)),
    ),
  );
  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    form.currentState!.save();
    setState(() => busy = true);
    try {
      await widget.service.command(
        'create',
        fields: {
          ...values,
          'senderType': senderType,
          'category': category,
          'storage': storage,
          'waste': waste,
          'donate': donate,
          'confirmed': confirmed,
          'minutes': waste ? 5 : values['minutes'],
          'eta': waste ? 1 : values['eta'],
          'price': donate || waste ? 0 : values['price'],
        },
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
