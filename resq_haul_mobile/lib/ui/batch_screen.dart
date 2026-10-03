import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/recovery_controller.dart';
import '../domain/models.dart';
import 'design.dart';

class BatchScreen extends StatelessWidget {
  const BatchScreen({super.key, required this.controller, required this.batch});
  final RecoveryController controller;
  final Batch batch;
  RecoveryController get c => controller;
  Batch get b => batch;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: c,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: Text(b.id, style: const TextStyle(fontSize: 15)),
        actions: [
          IconButton(
            tooltip: 'Advance 15 minutes',
            onPressed: () => action(
              context,
              () => c.advance(),
              success: 'Demo clock advanced.',
            ),
            icon: const Icon(Icons.fast_forward_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
        children: [
          Row(
            children: [
              Expanded(child: Eyebrow('${b.category} / ${b.source}')),
              Pill(
                b.donate ? 'Donation' : 'RM ${b.price.toStringAsFixed(0)}',
                color: Palette.warning,
              ),
            ],
          ),
          gap(18),
          Editorial(b.name, size: 36),
          gap(17),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Pill('${b.kg.toStringAsFixed(1)} kg', icon: Icons.scale_outlined),
              Pill(
                b.stage.label,
                color: b.stage.downstream ? Palette.warning : Palette.muted,
              ),
            ],
          ),
          gap(24),
          if (b.stage.edible)
            ..._edible(context)
          else if (b.stage == Stage.delivered)
            ..._delivered(context)
          else
            ..._waste(context),
          const SectionTitle('Chain of custody'),
          ...b.history.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: e.key == b.history.length - 1
                          ? Palette.accent
                          : Palette.panel,
                    ),
                    child: Text(
                      '${e.key + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        color: e.key == b.history.length - 1
                            ? Palette.bg
                            : Palette.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.value,
                      style: const TextStyle(
                        color: Palette.muted,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SmallNote(
            'All organisations, travel predictions and confirmations in this workspace are demonstration data.',
          ),
        ],
      ),
    ),
  );
  List<Widget> _edible(BuildContext context) {
    final ok = b.eligible(c.clock);
    return [
      Surface(
        color: ok ? Palette.brandSurface : Palette.attentionSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(
              ok ? 'Room for a second chance' : 'A delivery worth rescuing',
              color: ok ? Palette.accent : Palette.warning,
            ),
            gap(20),
            Row(
              children: [
                Expanded(
                  child: Metric(
                    '${b.remaining(c.clock)} min',
                    'Window left',
                    color: Palette.text,
                  ),
                ),
                Expanded(
                  child: Metric(
                    '${b.eta()} min',
                    'Predicted recovery',
                    color: ok ? Palette.accent : Palette.warning,
                  ),
                ),
              ],
            ),
            gap(20),
            LinearProgressIndicator(
              value: (b.remaining(c.clock) / (b.deadline - b.createdAt)).clamp(
                0,
                1,
              ),
              minHeight: 5,
              color: ok ? Palette.accent : Palette.warning,
              backgroundColor: Palette.bg.withValues(alpha: .3),
              borderRadius: BorderRadius.circular(10),
            ),
            gap(15),
            Text(
              ok
                  ? '+${b.remaining(c.clock) - b.eta()} min modeled margin'
                  : '${b.eta() - b.remaining(c.clock)} min beyond the modeled window',
              style: TextStyle(
                fontSize: 13,
                color: ok ? Palette.accent : Palette.warning,
              ),
            ),
          ],
        ),
      ),
      gap(16),
      NetworkMap(
        risk: !ok,
        radius: b.radius(c.clock),
        recipient: b.recipient.isEmpty
            ? 'Recipient not yet confirmed'
            : b.recipient,
      ),
      gap(16),
      Surface(
        child: Column(
          children: [
            _line('Storage', b.storage),
            _line('Allergens', b.allergens),
            _line(
              'Recipient',
              b.recipient.isEmpty ? 'Awaiting acceptance' : b.recipient,
            ),
            _line('Driver', b.driver.isEmpty ? 'Not assigned' : b.driver),
          ],
        ),
      ),
      if (b.stage == Stage.listed) ...[
        const SectionTitle('Find the right match'),
        const Text(
          'Recipient acceptance includes food category, capacity and the recovery window.',
          style: TextStyle(fontSize: 13, color: Palette.muted, height: 1.5),
        ),
        gap(14),
        ...receivers.map((r) => _receiver(context, r, false)),
      ],
      if (b.stage == Stage.accepted) ...[
        const SectionTitle('Next: assign a driver'),
        fullButton(
          'Assign Raju · 60 kg vehicle',
          ok
              ? () => action(
                  context,
                  () => c.assign(b),
                  success: 'Driver assigned. Pickup confirmation is next.',
                )
              : null,
          icon: Icons.local_shipping_outlined,
        ),
      ],
      if (b.stage == Stage.assigned) ...[
        const SectionTitle('Ready at the pickup bay'),
        fullButton(
          'Confirm packed-food pickup',
          ok
              ? () async {
                  if (await confirm(
                    context,
                    'Confirm pickup condition',
                    'As the driver, confirm the packaging is intact, handling requirements are met, and food is in acceptable condition.',
                    button: 'Confirm pickup',
                  )) {
                    if (context.mounted) {
                      action(context, () => c.pickup(b, true));
                    }
                  }
                }
              : null,
          icon: Icons.inventory_2_outlined,
        ),
      ],
      if (b.stage == Stage.transit) ...[
        const SectionTitle('On the way to something good'),
        fullButton(
          'Confirm recipient handover',
          ok ? () => _handover(context) : null,
          icon: Icons.fact_check_outlined,
        ),
      ],
      if (!ok)
        const SmallNote(
          'Current route is blocked. First check another route to the same recipient. Otherwise seek acceptance from a closer recipient. Advancing past the deadline closes edible recovery.',
          warning: true,
        ),
      const SectionTitle('When the journey changes'),
      fullButton(
        'Adjust delay & conditions',
        () => _conditions(context),
        icon: Icons.tune_rounded,
        secondary: true,
      ),
      if (b.stage != Stage.listed) ...[
        gap(12),
        fullButton(
          'Try another route · same recipient',
          c.canReroute(b)
              ? () => action(
                  context,
                  () => c.reroute(b),
                  success:
                      'Alternate route confirmed. Recipient stays the same.',
                )
              : null,
          icon: Icons.alt_route,
          secondary: true,
        ),
        gap(16),
        const Eyebrow('Or confirm a closer recipient'),
        gap(12),
        ...receivers
            .where((r) => r.name != b.recipient)
            .map((r) => _receiver(context, r, true)),
      ],
      gap(8),
      TextButton.icon(
        onPressed: () async {
          if (await confirm(
            context,
            'Close edible recovery?',
            'Food that fails the condition check will enter waste assessment. It cannot return to the edible marketplace.',
            button: 'Send to assessment',
          )) {
            if (context.mounted) action(context, () => c.rejectFood(b));
          }
        },
        icon: const Icon(
          Icons.report_outlined,
          color: Palette.warning,
          size: 18,
        ),
        label: const Text(
          'Food condition is unsuitable',
          style: TextStyle(color: Palette.warning),
        ),
      ),
    ];
  }

  Widget _receiver(BuildContext context, Receiver r, bool switching) {
    final valid = c.canMatch(b, r);
    final available = r.capacity - c.recipientLoad(r.name);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Surface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            gap(9),
            Text(
              '${r.km} km · ${b.eta(km: r.km, fresh: true)} min · ${available.toStringAsFixed(0)} kg available',
              style: const TextStyle(fontSize: 12, color: Palette.muted),
            ),
            gap(14),
            fullButton(
              switching
                  ? 'Confirm acceptance & switch'
                  : b.donate
                  ? 'Accept donation'
                  : 'Reserve purchase (demo)',
              valid
                  ? () async {
                      if (await confirm(
                        context,
                        switching
                            ? 'Confirm new recipient?'
                            : 'Confirm recipient acceptance?',
                        switching
                            ? '${r.name} confirms capacity and availability. ${b.donate ? 'The donation will be redirected.' : 'This sale becomes a donation; no payment is charged.'}'
                            : '${r.name} confirms it can receive ${b.kg} kg of ${b.category}. ${b.donate ? '' : 'Demo purchase only; no payment is processed.'}',
                        button: switching
                            ? 'Switch recipient'
                            : 'Confirm acceptance',
                      )) {
                        if (context.mounted) {
                          action(
                            context,
                            () => c.accept(b, r, switchRecipient: switching),
                          );
                        }
                      }
                    }
                  : null,
              icon: Icons.check_rounded,
              secondary: true,
            ),
            if (!valid) ...[
              gap(8),
              const Text(
                'Unavailable: category, capacity or timing does not fit.',
                style: TextStyle(fontSize: 12, color: Palette.warning),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _line(String a, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 95,
          child: Text(
            a,
            style: const TextStyle(color: Palette.muted, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ),
  );
  List<Widget> _delivered(BuildContext context) => [
    Surface(
      color: Palette.brandSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Palette.accent,
            size: 42,
          ),
          gap(20),
          const Editorial('Right place.\nRight on time.', size: 36),
          gap(15),
          Text(
            '${b.kg} kg reached ${b.recipient}. The recipient confirmed the handover.',
            style: const TextStyle(color: Palette.muted, height: 1.6),
          ),
          gap(20),
          Pill(b.receipt),
          gap(20),
          fullButton('Copy handover record', () async {
            await Clipboard.setData(
              ClipboardData(
                text:
                    'ResQ-Haul DEMO ${b.receipt}\n${b.name} · ${b.kg} kg\n${b.source} → ${b.recipient}\nRecipient confirmed receipt. Not a tax receipt.',
              ),
            );
            if (context.mounted) message(context, 'Handover record copied.');
          }, icon: Icons.receipt_long_outlined),
        ],
      ),
    ),
  ];
  List<Widget> _waste(BuildContext context) {
    final f = b.facility.isEmpty
        ? null
        : facilities.firstWhere((f) => f.name == b.facility);
    return [
      ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset(
          'assets/images/recovery.jpg',
          height: 170,
          fit: BoxFit.cover,
        ),
      ),
      gap(18),
      Surface(
        child: Column(
          children: [
            _line(
              'Custody',
              b.stage == Stage.waste
                  ? (b.pickedUp ? 'Delivery driver' : 'Source kitchen')
                  : b.stage == Stage.assessed
                  ? 'Collection pending'
                  : 'Recovery facility / hauler',
            ),
            _line('Material', b.material),
            _line(
              'Facility',
              b.facility.isEmpty ? 'Assessment required' : b.facility,
            ),
            if (b.measuredKg > 0) _line('Measured', '${b.measuredKg} kg'),
          ],
        ),
      ),
      if (b.stage == Stage.waste || b.stage == Stage.rejected) ...[
        SmallNote(
          b.stage == Stage.rejected
              ? '${b.rejection}. Select another suitable pathway. This batch has not been counted as recovered.'
              : 'Edible recovery is closed. Separate packaging and assess material before choosing a recovery partner.',
          warning: true,
        ),
        fullButton(
          'Assess & select recovery partner',
          () => _assessment(context),
          icon: Icons.fact_check_outlined,
        ),
      ],
      if (b.stage == Stage.assessed) ...[
        const SmallNote(
          'Suitability screening is complete. Final acceptance happens after weighing and inspection at the facility.',
        ),
        fullButton(
          'Confirm hauler collection',
          () => action(context, () => c.collect(b)),
          icon: Icons.local_shipping_outlined,
        ),
      ],
      if (b.stage == Stage.collected) ...[
        const SectionTitle('At the receiving gate'),
        fullButton(
          'Weigh & inspect the load',
          () => _weigh(context),
          icon: Icons.scale_outlined,
        ),
      ],
      if (b.stage == Stage.facilityAccepted) ...[
        const SmallNote(
          'The facility accepted the measured load. Move it into controlled receiving before processing.',
        ),
        fullButton(
          'Confirm receiving & start processing',
          () => action(context, () => c.process(b)),
          icon: Icons.play_arrow_rounded,
        ),
      ],
      if (b.stage == Stage.processing) ...[
        const SectionTitle('Recovery takes its course'),
        Text(
          f!.description,
          style: const TextStyle(
            color: Palette.muted,
            fontSize: 14,
            height: 1.7,
          ),
        ),
        const SmallNote(
          'Biological processing takes real time. The button below simulates a completed facility process; it does not advance actual production.',
        ),
        fullButton('Record outputs & residue treatment', () async {
          if (await confirm(
            context,
            'Confirm completed processing',
            f.type == 'BSFL'
                ? 'Confirm larvae growth and separation are complete, larvae have entered feed processing, and residue treatment is recorded.'
                : 'Confirm ${f.type.toLowerCase()} processing and appropriate residue / digestate handling are complete.',
            button: 'Record completion',
          )) {
            if (context.mounted) action(context, () => c.complete(b, true));
          }
        }, icon: Icons.eco_outlined),
      ],
      if (b.stage == Stage.completed) ...[
        gap(18),
        Surface(
          color: Palette.brandSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('The cycle continues', color: Palette.accent),
              gap(15),
              Editorial('${b.measuredKg} kg\nwith a new purpose.', size: 35),
              gap(15),
              Text(
                f!.type == 'BSFL'
                    ? 'Larvae → feed processing\nResidue → further treatment'
                    : f.type == 'Compost'
                    ? 'Organics → cured compost\nResidue → appropriate treatment'
                    : 'Organics → biogas\nDigestate → further treatment',
                style: const TextStyle(color: Palette.muted, height: 1.8),
              ),
            ],
          ),
        ),
      ],
    ];
  }

  void _conditions(BuildContext context) {
    double delay = b.delay.toDouble(),
        traffic = b.traffic,
        temp = b.temperature.toDouble();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Editorial('Every minute matters.', size: 30),
                gap(20),
                Text('Additional delay · ${delay.toInt()} min'),
                Slider(
                  value: delay,
                  min: 0,
                  max: 90,
                  divisions: 18,
                  onChanged: (v) => set(() => delay = v),
                ),
                Text('Traffic · ${traffic.toStringAsFixed(1)}×'),
                Slider(
                  value: traffic,
                  min: 1,
                  max: 3,
                  divisions: 20,
                  onChanged: (v) => set(() => traffic = v),
                ),
                Text('Ambient temperature · ${temp.toInt()}°C'),
                Slider(
                  value: temp,
                  min: 25,
                  max: 40,
                  divisions: 15,
                  onChanged: (v) => set(() => temp = v),
                ),
                const SmallNote(
                  'Timing illustration only. Heat adds a buffer, not a validated food-safety prediction.',
                ),
                fullButton('Update recovery prediction', () {
                  action(
                    context,
                    () => c.conditions(
                      b,
                      delay: delay.toInt(),
                      traffic: traffic,
                      temperature: temp.toInt(),
                    ),
                  );
                  Navigator.pop(ctx);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handover(BuildContext context) {
    final code = TextEditingController();
    bool checked = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            10,
            24,
            24 + MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Editorial('Received with care.', size: 32),
              gap(15),
              Text(
                '${b.recipient} confirms ${b.kg} kg received.',
                style: const TextStyle(color: Palette.muted),
              ),
              gap(20),
              TextField(
                controller: code,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Recipient confirmation code',
                  helperText: 'Demo code: 2468',
                ),
              ),
              gap(12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: checked,
                onChanged: (v) => set(() => checked = v!),
                title: const Text(
                  'Condition, quantity and packaging checked.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              gap(14),
              fullButton(
                'Confirm receipt',
                checked
                    ? () {
                        if (action(
                          context,
                          () => c.deliver(b, code.text.trim(), checked),
                        )) {
                          Navigator.pop(ctx);
                        }
                      }
                    : null,
                icon: Icons.check_rounded,
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(code.dispose);
  }

  void _assessment(BuildContext context) {
    String material = 'Separated organics';
    Facility chosen = facilities.first;
    bool clean = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Editorial('Choose the right\nnext chapter.', size: 32),
                gap(20),
                DropdownButtonFormField<String>(
                  initialValue: material,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Assessed material',
                  ),
                  items:
                      [
                            'Separated organics',
                            'Plant scraps',
                            'Mixed / contaminated',
                          ]
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                  onChanged: (v) => set(() => material = v!),
                ),
                gap(16),
                RadioGroup<String>(
                  groupValue: chosen.name,
                  onChanged: (value) => set(
                    () =>
                        chosen = facilities.firstWhere((f) => f.name == value),
                  ),
                  child: Column(
                    children: facilities
                        .map(
                          (f) => RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            value: f.name,
                            title: Text(f.type),
                            subtitle: Text(
                              '${f.name}\n${(f.capacity - c.facilityLoad(f.name)).toStringAsFixed(0)} kg available · ${f.materials.join(', ')}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Palette.muted,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: clean,
                  onChanged: (v) => set(() => clean = v!),
                  title: const Text(
                    'Packaging removed; material inspected.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                if (!chosen.materials.contains(material))
                  const SmallNote(
                    'This facility does not accept the assessed material. Contaminated loads remain in assessment for specialist handling.',
                    warning: true,
                  ),
                gap(14),
                fullButton(
                  'Confirm assessment',
                  clean && chosen.materials.contains(material)
                      ? () {
                          if (action(
                            context,
                            () => c.assess(b, chosen, material, clean),
                          )) {
                            Navigator.pop(ctx);
                          }
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _weigh(BuildContext context) {
    final weight = TextEditingController(text: b.kg.toString());
    bool suitable = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            10,
            24,
            24 + MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Editorial('Inspect. Weigh. Accept.', size: 30),
              gap(20),
              TextField(
                controller: weight,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Measured net weight (kg)',
                ),
              ),
              gap(12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: suitable,
                onChanged: (v) => set(() => suitable = v!),
                title: const Text(
                  'Facility inspection passed; this material is suitable.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              gap(16),
              fullButton(
                'Accept measured load',
                suitable
                    ? () {
                        if (action(
                          context,
                          () => c.receive(
                            b,
                            double.tryParse(weight.text) ?? 0,
                            true,
                          ),
                        )) {
                          Navigator.pop(ctx);
                        }
                      }
                    : null,
                icon: Icons.check,
              ),
              gap(10),
              fullButton(
                'Reject load for reassessment',
                () {
                  if (action(
                    context,
                    () =>
                        c.receive(b, double.tryParse(weight.text) ?? 0, false),
                  )) {
                    Navigator.pop(ctx);
                  }
                },
                icon: Icons.undo,
                secondary: true,
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(weight.dispose);
  }
}
