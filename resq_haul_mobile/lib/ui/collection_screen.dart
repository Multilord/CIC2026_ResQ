import 'package:flutter/material.dart';
import '../core/recovery_controller.dart';
import '../domain/models.dart';
import 'batch_screen.dart';
import 'design.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key, required this.controller});
  final RecoveryController controller;
  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  String destination = facilities.first.name;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final c = widget.controller, plan = c.collectionPlan(destination);
      final collected = c.batches
          .where((b) => b.stage == Stage.collected && b.facility == destination)
          .toList();
      return Scaffold(
        appBar: AppBar(title: const Text('Collection runs')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Eyebrow('Raju / organics collection'),
            gap(12),
            const Editorial('One route.\nA better return.', size: 40),
            gap(22),
            DropdownButtonFormField<String>(
              initialValue: destination,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Recovery destination',
              ),
              items: facilities
                  .map(
                    (f) => DropdownMenuItem(
                      value: f.name,
                      child: Text(
                        '${f.type} · ${f.name}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => destination = v!),
            ),
            gap(20),
            Surface(
              color: Palette.brandSurface,
              child: Row(
                children: [
                  Expanded(
                    child: Metric(
                      '${plan.length}',
                      'Pickup stops',
                      color: Palette.accent,
                    ),
                  ),
                  Expanded(
                    child: Metric(
                      '${plan.fold<double>(0, (sum, b) => sum + b.kg).toStringAsFixed(0)} kg',
                      'Of 500 kg capacity',
                    ),
                  ),
                ],
              ),
            ),
            const SmallNote(
              'Only assessed loads join a run. Stops use nearest-neighbour ordering on demo coordinates and share a facility. This is not road navigation.',
            ),
            if (plan.isEmpty)
              const SmallNote(
                'No assessed loads for this facility. Open a waste batch, complete suitability assessment, and select this destination.',
              ),
            ...plan.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Surface(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          BatchScreen(controller: c, batch: entry.value),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Palette.brandSurface,
                        foregroundColor: Palette.accent,
                        child: Text('${entry.key + 1}'),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.value.source),
                            gap(5),
                            Text(
                              '${entry.value.id} · ${entry.value.kg} kg',
                              style: const TextStyle(
                                color: Palette.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Palette.muted),
                    ],
                  ),
                ),
              ),
            ),
            if (plan.isNotEmpty) ...[
              gap(8),
              fullButton(
                'Confirm all pickups in this run',
                () async {
                  if (await confirm(
                    context,
                    'Confirm physical collection',
                    'Confirm each listed load has been collected for $destination. Facility weighing and acceptance remain separate.',
                    button: 'Confirm pickups',
                  )) {
                    if (context.mounted) {
                      action(context, () => c.collectRun(plan));
                    }
                  }
                },
                icon: Icons.local_shipping_outlined,
              ),
            ],
            if (collected.isNotEmpty) ...[
              const SectionTitle('Awaiting facility inspection'),
              ...collected.map(
                (b) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(b.name),
                  subtitle: Text('${b.kg} kg · ${b.stage.label}'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BatchScreen(controller: c, batch: b),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}
