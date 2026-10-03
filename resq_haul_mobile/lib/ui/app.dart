import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/recovery_controller.dart';
import '../domain/models.dart';
import 'design.dart';
import 'batch_screen.dart';
import 'create_screen.dart';
import 'collection_screen.dart';

class ResQApp extends StatelessWidget {
  const ResQApp({super.key, required this.controller});
  final RecoveryController controller;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ResQ-Haul · Good food, better futures',
    debugShowCheckedModeBanner: false,
    theme: appTheme(),
    home: HomeShell(controller: controller),
    builder: (context, child) => LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth < 700) return child!;
        return Material(
          color: Palette.navy,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BrandLogo(width: 190),
                      gap(30),
                      const Editorial('Good food.\nBetter\nfutures.', size: 64),
                      gap(24),
                      const Text(
                        'A second chance for food.\nA better cycle for our city.',
                        style: TextStyle(
                          fontSize: 17,
                          height: 1.7,
                          color: Palette.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 440, child: ClipRect(child: child!)),
              if (box.maxWidth > 1050) const Spacer(),
            ],
          ),
        );
      },
    ),
  );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controller});
  final RecoveryController controller;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tab = 0;
  String filter = 'All', journeyFilter = 'Active', query = '';
  RecoveryController get c => widget.controller;
  void open(Batch b) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BatchScreen(controller: c, batch: b),
    ),
  );
  void create() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => CreateScreen(controller: c)),
  );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: c,
    builder: (context, _) => Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    if (c.persistenceError != null)
                      SmallNote(c.persistenceError!, warning: true),
                    ...switch (tab) {
                      0 => _home(),
                      1 => _explore(),
                      2 => _journeys(),
                      _ => _impact(),
                    },
                    gap(30),
                    Center(
                      child: Text(
                        'DEMO NETWORK  ·  SAVED ON THIS DEVICE',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.6,
                          color: Palette.muted.withValues(alpha: .7),
                        ),
                      ),
                    ),
                    gap(24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (n) => setState(() => tab = n),
        height: 74,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: 'Journeys',
          ),
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa),
            label: 'Impact',
          ),
        ],
      ),
    ),
  );
  Widget _header() => Row(
    children: [
      InkWell(
        onTap: _roles,
        borderRadius: BorderRadius.circular(30),
        child: const BrandLogo(width: 64),
      ),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RESQ-HAUL',
              style: TextStyle(
                fontSize: 11,
                color: Palette.accent,
                letterSpacing: 1.4,
              ),
            ),
            Text(
              c.role.person,
              style: const TextStyle(fontFamily: 'Editorial', fontSize: 20),
            ),
          ],
        ),
      ),
      IconButton(
        onPressed: _notifications,
        tooltip: 'Notifications',
        icon: Badge(
          isLabelVisible: c.unread > 0,
          label: Text('${c.unread}'),
          child: const Icon(Icons.notifications_none_rounded, size: 22),
        ),
      ),
      IconButton(
        onPressed: _settings,
        tooltip: 'Demo controls',
        icon: const Icon(Icons.tune_rounded, size: 21),
      ),
    ],
  );
  List<Widget> _home() {
    final urgent = c.batches
        .where((b) => b.stage == Stage.transit && !b.eligible(c.clock))
        .toList();
    return [
      gap(27),
      Row(
        children: [
          const Expanded(child: Eyebrow('Your daily act of good')),
          const SizedBox(width: 8),
          InkWell(
            onTap: _roles,
            child: Row(
              children: [
                Text(
                  c.role.label,
                  style: const TextStyle(fontSize: 11, color: Palette.muted),
                ),
                const Icon(Icons.expand_more, size: 16, color: Palette.muted),
              ],
            ),
          ),
        ],
      ),
      gap(16),
      Surface(
        color: Palette.brandSurface,
        padding: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Editorial('Good food.\nBetter futures.', size: 39),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Palette.accent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.north_east_rounded,
                    color: Palette.brandSurface,
                    size: 29,
                  ),
                ),
              ],
            ),
            gap(14),
            const Text(
              'A little extra in your kitchen could\nmean everything to someone else.',
              style: TextStyle(color: Palette.muted, fontSize: 14, height: 1.6),
            ),
            gap(22),
            fullButton(
              c.role == AppRole.kitchen
                  ? 'Give food a second chance'
                  : c.role == AppRole.driver
                  ? 'See your deliveries'
                  : c.role == AppRole.recovery
                  ? 'Open recovery queue'
                  : 'Find a community match',
              () => c.role == AppRole.kitchen
                  ? create()
                  : setState(() => tab = c.role == AppRole.recipient ? 1 : 2),
              icon: Icons.arrow_forward_rounded,
            ),
          ],
        ),
      ),
      gap(22),
      Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 15,
            color: Palette.muted,
          ),
          const SizedBox(width: 5),
          const Text(
            'Kuala Lumpur',
            style: TextStyle(fontSize: 12, color: Palette.muted),
          ),
          const Spacer(),
          Pill('+${c.clock} min', icon: Icons.schedule, color: Palette.muted),
        ],
      ),
      const SectionTitle('Make your next move'),
      Row(
        children: [
          _quick('List food', Icons.add_rounded, Palette.warning, create),
          const SizedBox(width: 10),
          _quick(
            'Needs',
            Icons.favorite_border_rounded,
            Palette.accent,
            _needs,
          ),
          const SizedBox(width: 10),
          _quick(
            'Smart bins',
            Icons.delete_outline_rounded,
            Palette.muted,
            _bins,
          ),
          const SizedBox(width: 10),
          _quick('The flow', Icons.alt_route_rounded, Palette.warning, _guide),
        ],
      ),
      if (urgent.isNotEmpty) ...[
        const SectionTitle('A little attention. A big difference.'),
        Surface(
          color: Palette.attentionSurface,
          onTap: () => open(urgent.first),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Pill(
                    'DELIVERY AT RISK',
                    color: Palette.warning,
                    icon: Icons.schedule,
                  ),
                  Spacer(),
                  Icon(Icons.north_east, color: Palette.warning),
                ],
              ),
              gap(15),
              const Editorial('There’s still\na way through.', size: 30),
              gap(12),
              Text(
                '${urgent.first.remaining(c.clock)} min left · predicted arrival ${urgent.first.eta()} min',
                style: const TextStyle(fontSize: 13, color: Palette.warning),
              ),
              gap(13),
              const Text(
                'Try another route, or a closer recipient.',
                style: TextStyle(fontSize: 13, color: Palette.muted),
              ),
            ],
          ),
        ),
      ],
      SectionTitle(
        'Three paths. One purpose.',
        action: 'Walk through',
        onTap: _guide,
      ),
      ...[
        (
          title: '01 / Share something good',
          sub: 'List → match → deliver',
          asset: 'donation',
          id: 'RH-101',
        ),
        (
          title: '02 / Find another way',
          sub: 'Detect → reroute → confirm',
          asset: 'journey',
          id: 'RH-102',
        ),
        (
          title: '03 / Close the loop',
          sub: 'Assess → collect → recover',
          asset: 'recovery',
          id: 'RH-104',
        ),
      ].map(
        (s) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Surface(
            padding: 0,
            onTap: () => open(c.batches.firstWhere((b) => b.id == s.id)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/${s.asset}.jpg',
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            gap(5),
                            Text(
                              s.sub,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Palette.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_outward,
                        size: 19,
                        color: Palette.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      SectionTitle(
        'Good adds up',
        action: 'Your impact',
        onTap: () => setState(() => tab = 3),
      ),
      Surface(
        child: Row(
          children: [
            Expanded(
              child: Metric(
                '${(c.donated + c.sold).toStringAsFixed(0)} kg',
                'Food delivered',
                color: Palette.accent,
              ),
            ),
            Expanded(
              child: Metric(
                '${c.recovered.toStringAsFixed(0)} kg',
                'Resources recovered',
                color: Palette.warning,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _quick(String label, IconData icon, Color color, VoidCallback tap) =>
      Expanded(
        child: InkWell(
          onTap: tap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              Container(
                height: 59,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Palette.panel,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              gap(9),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Palette.muted),
              ),
            ],
          ),
        ),
      );
  List<Widget> _explore() {
    final list = c.batches
        .where(
          (b) =>
              b.stage == Stage.listed &&
              (filter == 'All' ||
                  filter == 'Donate' && b.donate ||
                  filter == 'Sell' && !b.donate ||
                  filter == b.category) &&
              ('${b.name} ${b.source}').toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
    return [
      gap(28),
      const Eyebrow('The neighbourhood table'),
      gap(13),
      const Editorial('Find your\nnext good thing.', size: 40),
      gap(16),
      TextField(
        onChanged: (v) => setState(() => query = v),
        decoration: const InputDecoration(
          hintText: 'Search food or kitchen',
          prefixIcon: Icon(Icons.search),
        ),
      ),
      gap(16),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['All', 'Donate', 'Sell', 'Rice', 'Bread', 'Produce']
              .map(
                (s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: filter == s,
                    onSelected: (_) => setState(() => filter = s),
                  ),
                ),
              )
              .toList(),
        ),
      ),
      SectionTitle(
        '${list.length} chances to make a difference',
        action: 'My needs',
        onTap: _needs,
      ),
      if (list.isEmpty)
        const SmallNote(
          'No available food matches this search. Try another filter or list a new batch.',
        ),
      ...list.map(_batchCard),
      gap(12),
      fullButton('List your surplus', create, icon: Icons.add_rounded),
      const SmallNote(
        'Sample partners and prices. Reservations do not charge a card or contact a real organisation.',
      ),
    ];
  }

  Widget _batchCard(Batch b) {
    final urgent = b.stage.edible && !b.eligible(c.clock);
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Surface(
        onTap: () => open(b),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Palette.brandSurface,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(
                    b.stage.downstream
                        ? Icons.recycling
                        : b.category == 'Bread'
                        ? Icons.bakery_dining_outlined
                        : b.category == 'Produce'
                        ? Icons.eco_outlined
                        : Icons.rice_bowl_outlined,
                    color: Palette.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.source,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Palette.muted,
                        ),
                      ),
                      gap(4),
                      Text(
                        '${b.kg.toStringAsFixed(0)} kg · ${b.category}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.north_east, size: 18, color: Palette.muted),
              ],
            ),
            gap(16),
            Editorial(b.name, size: 25),
            gap(16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Pill(
                  b.stage == Stage.listed
                      ? (b.donate
                            ? 'Donation'
                            : 'RM ${b.price.toStringAsFixed(0)}')
                      : b.stage.label,
                  color: b.stage.downstream ? Palette.warning : Palette.accent,
                ),
                if (b.stage.edible)
                  Pill(
                    '${b.remaining(c.clock)} min left',
                    color: urgent ? Palette.warning : Palette.muted,
                    icon: Icons.schedule,
                  ),
              ],
            ),
            if (urgent) ...[
              gap(12),
              const Text(
                'Route needs attention',
                style: TextStyle(fontSize: 12, color: Palette.warning),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _journeys() {
    final list = c.batches
        .where(
          (b) => switch (journeyFilter) {
            'Edible' => b.stage.edible,
            'Waste' => b.stage.downstream && b.stage != Stage.completed,
            'Done' => [Stage.delivered, Stage.completed].contains(b.stage),
            _ => ![Stage.delivered, Stage.completed].contains(b.stage),
          },
        )
        .toList();
    return [
      gap(28),
      const Eyebrow('From here to something better'),
      gap(12),
      const Editorial('Every batch\nhas a journey.', size: 40),
      gap(18),
      Row(
        children: [
          Expanded(
            child: Text(
              'Follow the handover, every step of the way.',
              style: const TextStyle(
                fontSize: 14,
                color: Palette.muted,
                height: 1.5,
              ),
            ),
          ),
          IconButton.filled(
            onPressed: create,
            tooltip: 'New batch',
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      gap(18),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['Active', 'Edible', 'Waste', 'Done']
              .map(
                (s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: journeyFilter == s,
                    onSelected: (_) => setState(() => journeyFilter = s),
                  ),
                ),
              )
              .toList(),
        ),
      ),
      gap(20),
      ...list.map(_batchCard),
      if (list.isEmpty)
        const SmallNote(
          'Nothing in this queue. Completed journeys appear in Done.',
        ),
      fullButton(
        'Plan an organics collection run',
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CollectionScreen(controller: c)),
        ),
        icon: Icons.route_outlined,
      ),
      gap(12),
      fullButton(
        'Manage smart-bin collection',
        _bins,
        icon: Icons.local_shipping_outlined,
        secondary: true,
      ),
    ];
  }

  List<Widget> _impact() {
    final done = c.batches
        .where((b) => b.stage == Stage.delivered || b.stage == Stage.completed)
        .toList();
    return [
      gap(28),
      const Eyebrow('Small acts. Shared impact.'),
      gap(14),
      const Editorial('Look what\nwe kept moving.', size: 40),
      gap(23),
      Surface(
        color: Palette.brandSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('Food that reached people', color: Palette.accent),
            gap(20),
            Editorial(
              '${(c.donated + c.sold).toStringAsFixed(1)} kg',
              size: 64,
            ),
            gap(10),
            const Text(
              'Confirmed by the receiving organisation.',
              style: TextStyle(fontSize: 13, color: Palette.muted),
            ),
            gap(24),
            Row(
              children: [
                Expanded(
                  child: Metric(
                    '${c.donated.toStringAsFixed(0)} kg',
                    'Donated',
                  ),
                ),
                Expanded(
                  child: Metric('${c.sold.toStringAsFixed(0)} kg', 'Sold'),
                ),
              ],
            ),
          ],
        ),
      ),
      gap(14),
      Surface(
        child: Row(
          children: [
            Expanded(
              child: Metric(
                '${c.recovered.toStringAsFixed(0)} kg',
                'Resource recovery',
                color: Palette.warning,
              ),
            ),
            Expanded(
              child: Metric(
                'RM ${c.revenue.toStringAsFixed(0)}',
                'Demo sales value',
              ),
            ),
          ],
        ),
      ),
      const SectionTitle('The proof is in the handover'),
      if (done.isEmpty)
        const SmallNote(
          'Complete a delivery or facility process to create your first recovery record.',
        ),
      ...done.map(_batchCard),
      gap(10),
      fullButton(
        'Copy session report',
        () async {
          await Clipboard.setData(ClipboardData(text: c.report()));
          if (mounted) message(context, 'Demo report copied.');
        },
        icon: Icons.ios_share_outlined,
        secondary: true,
      ),
      const SmallNote(
        'Impact reflects completed demo actions. No assumed CO₂ savings, tax deductions, or fuel savings. Demo donation receipts are not tax receipts.',
      ),
    ];
  }

  void _roles() => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Editorial('A different perspective.', size: 29),
            gap(8),
            const Text(
              'Switch demo workspace. This is not account authentication.',
              style: TextStyle(fontSize: 13, color: Palette.muted),
            ),
            gap(16),
            ...AppRole.values.map(
              (r) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  [
                    Icons.restaurant,
                    Icons.favorite_outline,
                    Icons.local_shipping_outlined,
                    Icons.recycling,
                  ][r.index],
                  color: Palette.accent,
                ),
                title: Text(r.label),
                subtitle: Text(r.person),
                trailing: c.role == r
                    ? const Icon(Icons.check, color: Palette.accent)
                    : null,
                onTap: () {
                  c.changeRole(r);
                  Navigator.pop(ctx);
                  setState(
                    () => tab = r == AppRole.recipient
                        ? 1
                        : r == AppRole.driver || r == AppRole.recovery
                        ? 2
                        : 0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
  void _settings() => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Editorial('Make time move.', size: 32),
            gap(12),
            Text(
              'Demo clock: +${c.clock} minutes. Time only advances when you choose.',
              style: const TextStyle(color: Palette.muted, height: 1.5),
            ),
            gap(22),
            fullButton('Advance 15 minutes', () {
              c.advance();
              Navigator.pop(ctx);
              message(
                context,
                'Recovery windows updated. Expired food moved to assessment.',
              );
            }, icon: Icons.fast_forward_outlined),
            gap(10),
            fullButton(
              'Reset the demo',
              () async {
                Navigator.pop(ctx);
                if (await confirm(
                  context,
                  'Start a fresh demo?',
                  'All local demo actions will be replaced with the three sample journeys.',
                  button: 'Reset',
                )) {
                  c.reset();
                }
              },
              icon: Icons.restart_alt,
              secondary: true,
            ),
          ],
        ),
      ),
    ),
  );
  void _notifications() {
    c.markRead();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Notifications')),
          body: ListenableBuilder(
            listenable: c,
            builder: (context, _) => ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Editorial('Good things\nare happening.', size: 36),
                gap(22),
                ...c.notices.map(
                  (n) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Surface(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.notifications_outlined,
                            color: Palette.accent,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              n,
                              style: const TextStyle(fontSize: 14, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SmallNote(
                  'In-app demo notifications. Push messaging is not connected.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _needs() => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => ListenableBuilder(
      listenable: c,
      builder: (ctx, _) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Editorial('What does your\ncommunity need?', size: 32),
              gap(18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ['Rice', 'Meals', 'Bread', 'Produce']
                    .map(
                      (s) => FilterChip(
                        label: Text(s),
                        selected: c.needs.contains(s),
                        onSelected: (_) => c.toggleNeed(s),
                      ),
                    )
                    .toList(),
              ),
              gap(18),
              Text(
                '${c.batches.where((b) => b.stage == Stage.listed && c.needs.contains(b.category)).length} matching listings available now.',
                style: const TextStyle(color: Palette.muted),
              ),
              gap(20),
              fullButton('See available food', () {
                Navigator.pop(ctx);
                setState(() => tab = 1);
              }),
            ],
          ),
        ),
      ),
    ),
  );
  void _bins() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Smart-bin network')),
        body: ListenableBuilder(
          listenable: c,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Eyebrow('Only collect what is ready'),
              gap(12),
              const Editorial('Full bins.\nFewer detours.', size: 39),
              const SmallNote(
                'Simulated ultrasonic readings. Bins at 90% or above are eligible; offline sensors require verification. 100 kg per bin is a demo assumption.',
              ),
              ...c.bins.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Surface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                b.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Pill(
                              b.online ? 'Online' : 'Offline',
                              color: b.online
                                  ? Palette.accent
                                  : Palette.warning,
                            ),
                          ],
                        ),
                        gap(20),
                        Editorial('${b.fill.toStringAsFixed(0)}%', size: 44),
                        gap(12),
                        LinearProgressIndicator(
                          value: b.fill / 100,
                          color: b.fill >= 90
                              ? Palette.warning
                              : Palette.accent,
                          backgroundColor: Palette.line,
                          borderRadius: BorderRadius.circular(9),
                          minHeight: 8,
                        ),
                        gap(12),
                        Text(
                          '${b.id} · ${b.fill >= 90 ? 'Ready for collection' : 'Below collection threshold'}',
                          style: const TextStyle(
                            color: Palette.muted,
                            fontSize: 12,
                          ),
                        ),
                        gap(14),
                        Wrap(
                          spacing: 8,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  action(context, () => c.sensor(b)),
                              child: const Text('Simulate +7%'),
                            ),
                            TextButton(
                              onPressed: () => c.toggleSensor(b),
                              child: Text(
                                b.online ? 'Take offline' : 'Restore sensor',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              fullButton(
                'Empty eligible bins for assessment',
                () => action(
                  context,
                  c.collectBins,
                  success: 'Batches created in the waste assessment queue.',
                ),
                icon: Icons.local_shipping_outlined,
              ),
              const SmallNote(
                'Bin emptying creates a tracked material batch. Facility dispatch still requires assessment and acceptance.',
              ),
            ],
          ),
        ),
      ),
    ),
  );
  void _guide() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('The ResQ-Haul flow')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Editorial('Two streams.\nOne thoughtful cycle.', size: 36),
            gap(20),
            ...[
              (
                n: '01',
                title: 'A donation completed',
                body:
                    'Kitchen separates and lists edible surplus. A recipient accepts, a driver is assigned, and pickup is confirmed. The receiving organisation confirms condition and receipt.',
                asset: 'donation',
              ),
              (
                n: '02',
                title: 'A delivery rescued',
                body:
                    'A delay puts the recovery window at risk. Check an alternate route to the SAME recipient first. If needed, a closer recipient confirms capacity and acceptance before the destination changes.',
                asset: 'journey',
              ),
              (
                n: '03',
                title: 'A resource recovered',
                body:
                    'Past the deadline, edible delivery closes. The waste team assesses material and selects BSFL, compost or biogas. A hauler collects it; the facility weighs and inspects it. Only accepted loads enter processing, with residue handling recorded.',
                asset: 'recovery',
              ),
            ].map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Surface(
                  padding: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/${s.asset}.jpg',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Eyebrow('Situation ${s.n}', color: Palette.warning),
                            gap(12),
                            Editorial(s.title, size: 29),
                            gap(14),
                            Text(
                              s.body,
                              style: const TextStyle(
                                color: Palette.muted,
                                height: 1.7,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SmallNote(
              'Flow and scene stills adapted from your 107-second ResQ-Haul reference video. Delivery times and facility operations are illustrative.',
            ),
          ],
        ),
      ),
    ),
  );
}
