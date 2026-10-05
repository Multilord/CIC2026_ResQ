import 'package:flutter/material.dart';

class Palette {
  static const bg = Color(0xFFFCFAEE),
      panel = Color(0xFFFFFFFF),
      brandSurface = Color(0xFFE7F0D9),
      text = Color(0xFF073D2A),
      muted = Color(0xFF5C7063),
      warning = Color(0xFF914900),
      accent = Color(0xFF007A3D),
      line = Color(0xFFD7E1D2),
      navy = Color(0xFF064C32),
      attentionSurface = Color(0xFFFFF0CF),
      orange = Color(0xFFFF9500),
      orangeInk = Color(0xFFB85B00),
      lime = Color(0xFF77BD24),
      yellow = Color(0xFFFFBE00);
}

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.width = 72});
  final double width;
  @override
  Widget build(BuildContext context) => ClipOval(
    child: Image.asset(
      'assets/images/resq-haul-logo.png',
      width: width,
      height: width,
      fit: BoxFit.contain,
      semanticLabel: 'ResQ-Haul logo',
    ),
  );
}

class DashboardLogo extends StatelessWidget {
  const DashboardLogo({super.key, this.width = 56});
  final double width;
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/resq-haul-dashboard-logo.png',
    width: width,
    height: width,
    fit: BoxFit.contain,
    semanticLabel: 'ResQ-Haul dashboard logo',
  );
}

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.size = 26});
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'ResQ-Haul',
    image: true,
    child: SizedBox(
      width: size * 6,
      height: size * 6 * 116 / 480,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Display the original sprite pixels, preserving its custom lettering.
          final scale = constraints.maxWidth / 480;
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: -1158 * scale,
                top: -460 * scale,
                width: 1672 * scale,
                height: 941 * scale,
                child: Image.asset(
                  'assets/images/resq-haul-brand-sheet.png',
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                  excludeFromSemantics: true,
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Palette.bg,
  colorScheme: const ColorScheme.light(
    primary: Palette.accent,
    onPrimary: Palette.bg,
    surface: Palette.panel,
    onSurface: Palette.text,
    secondary: Palette.orange,
    primaryContainer: Palette.brandSurface,
    onPrimaryContainer: Palette.accent,
    secondaryContainer: Palette.brandSurface,
    onSecondaryContainer: Palette.text,
    error: Color(0xFFB3261E),
  ),
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Palette.text,
    displayColor: Palette.text,
    fontFamily: 'Roboto',
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Palette.bg,
    foregroundColor: Palette.text,
    surfaceTintColor: Colors.transparent,
    centerTitle: false,
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: Palette.bg,
    surfaceTintColor: Colors.transparent,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Palette.bg,
    surfaceTintColor: Colors.transparent,
  ),
  dividerColor: Palette.line,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Palette.panel,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Palette.line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Palette.line),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Palette.text,
      minimumSize: const Size(0, 50),
      side: const BorderSide(color: Palette.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Palette.bg,
    indicatorColor: Palette.brandSurface,
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => IconThemeData(
        color: states.contains(WidgetState.selected)
            ? Palette.accent
            : Palette.muted,
      ),
    ),
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Palette.text,
      ),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Palette.text,
    contentTextStyle: TextStyle(color: Palette.bg, fontSize: 14),
  ),
);

class Editorial extends StatelessWidget {
  const Editorial(
    this.text, {
    super.key,
    this.size = 36,
    this.color = Palette.text,
    this.italic = false,
  });
  final String text;
  final double size;
  final Color color;
  final bool italic;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontFamily: 'Editorial',
      fontSize: size,
      color: color,
      height: 1.08,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      letterSpacing: -.7,
    ),
  );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color = Palette.muted});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      fontSize: 11,
      letterSpacing: 2,
      fontWeight: FontWeight.w600,
      color: color,
    ),
  );
}

class Surface extends StatelessWidget {
  const Surface({
    super.key,
    required this.child,
    this.color = Palette.panel,
    this.padding = 20,
    this.onTap,
  });
  final Widget child;
  final Color color;
  final double padding;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: color,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Palette.line),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(padding: EdgeInsets.all(padding), child: child),
    ),
  );
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.color = Palette.accent, this.icon});
  final String text;
  final Color color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      border: Border.all(color: color.withValues(alpha: .24)),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action, this.onTap});
  final String title;
  final String? action;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 28, bottom: 15),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onTap,
            child: Text(
              action!,
              style: const TextStyle(fontSize: 12, color: Palette.muted),
            ),
          ),
      ],
    ),
  );
}

class SmallNote extends StatelessWidget {
  const SmallNote(this.text, {super.key, this.warning = false});
  final String text;
  final bool warning;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 12),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: (warning ? Palette.warning : Palette.brandSurface).withValues(
        alpha: .16,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          warning ? Icons.info_outline_rounded : Icons.verified_outlined,
          size: 18,
          color: warning ? Palette.warning : Palette.muted,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: warning ? Palette.warning : Palette.muted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}

class Metric extends StatelessWidget {
  const Metric(this.value, this.label, {super.key, this.color = Palette.text});
  final String value, label;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: TextStyle(
          fontFamily: 'Editorial',
          fontSize: 32,
          color: color,
          height: 1.1,
        ),
      ),
      const SizedBox(height: 7),
      Text(label, style: const TextStyle(fontSize: 12, color: Palette.muted)),
    ],
  );
}

Widget gap([double h = 16]) => SizedBox(height: h);
Widget fullButton(
  String text,
  VoidCallback? onTap, {
  IconData icon = Icons.arrow_forward_rounded,
  bool secondary = false,
}) => SizedBox(
  width: double.infinity,
  child: secondary
      ? OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(text),
        )
      : FilledButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(text),
        ),
);
void message(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
bool action(BuildContext context, VoidCallback callback, {String? success}) {
  try {
    callback();
    if (success != null) message(context, success);
    return true;
  } catch (e) {
    message(context, e.toString().replaceFirst('Bad state: ', ''));
    return false;
  }
}

Future<bool> confirm(
  BuildContext context,
  String title,
  String body, {
  String button = 'Confirm',
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(button),
          ),
        ],
      ),
    ) ??
    false;

class NetworkMap extends StatelessWidget {
  const NetworkMap({
    super.key,
    this.risk = false,
    this.radius = 5,
    this.recipient = 'Community Kitchen',
  });
  final bool risk;
  final double radius;
  final String recipient;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(22),
    child: SizedBox(
      height: 210,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _NetworkPainter(risk, radius)),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: Pill(
              '${radius.toStringAsFixed(1)} km modeled radius',
              color: risk ? Palette.warning : Palette.accent,
            ),
          ),
          Positioned(
            bottom: 14,
            left: 14,
            right: 14,
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 15, color: Palette.accent),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(recipient, style: const TextStyle(fontSize: 12)),
                ),
                const Text(
                  'SCHEMATIC',
                  style: TextStyle(
                    fontSize: 9,
                    color: Palette.muted,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _NetworkPainter extends CustomPainter {
  _NetworkPainter(this.risk, this.radius);
  final bool risk;
  final double radius;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Palette.panel);
    final road = Paint()
      ..color = Palette.line
      ..strokeWidth = 9;
    for (double x = -100; x < size.width + 100; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x + 110, size.height), road);
    }
    for (double y = 0; y < size.height + 100; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 70), road);
    }
    final a = Offset(size.width * .28, size.height * .58),
        b = Offset(size.width * .75, size.height * .43);
    canvas.drawCircle(
      a,
      (radius * 8).clamp(10, 85),
      Paint()..color = Palette.accent.withValues(alpha: .07),
    );
    canvas.drawCircle(
      a,
      (radius * 8).clamp(10, 85),
      Paint()
        ..color = Palette.accent.withValues(alpha: .3)
        ..style = PaintingStyle.stroke,
    );
    final route = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(size.width * .43, size.height * .52)
      ..lineTo(size.width * .56, size.height * .7)
      ..lineTo(b.dx, b.dy);
    canvas.drawPath(
      route,
      Paint()
        ..color = risk ? Palette.warning : Palette.accent
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
    for (final p in [a, b]) {
      canvas.drawCircle(p, 11, Paint()..color = Palette.bg);
      canvas.drawCircle(
        p,
        6,
        Paint()..color = risk ? Palette.warning : Palette.accent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NetworkPainter old) =>
      old.risk != risk || old.radius != radius;
}

class RouteMap extends StatelessWidget {
  const RouteMap({
    super.key,
    required this.origin,
    required this.destination,
    required this.currentEta,
    this.alternativeEta,
    this.expired = false,
    this.arrived = false,
  });

  final String origin;
  final String destination;
  final int currentEta;
  final int? alternativeEta;
  final bool expired;
  final bool arrived;

  @override
  Widget build(BuildContext context) => Semantics(
    label: arrived
        ? 'Arrival confirmed at $destination.'
        : 'Route from $origin to $destination. Current estimate $currentEta minutes${alternativeEta == null ? '' : ', alternative $alternativeEta minutes'}.',
    child: ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 236,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _RoutePainter(
                  showAlternative:
                      !arrived &&
                      alternativeEta != null &&
                      alternativeEta! < currentEta,
                  expired: expired,
                  arrived: arrived,
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Pill(
                    arrived
                        ? 'Arrival confirmed'
                        : expired
                        ? 'Food window elapsed'
                        : 'Current · $currentEta min',
                    color: expired ? Palette.warning : Palette.text,
                    icon: expired ? Icons.timer_off_outlined : Icons.traffic,
                  ),
                  if (!arrived &&
                      alternativeEta != null &&
                      alternativeEta! < currentEta)
                    Pill(
                      'Faster route · $alternativeEta min',
                      icon: Icons.alt_route,
                    ),
                ],
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 13,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Palette.bg.withValues(alpha: .9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Palette.line),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trip_origin,
                      size: 15,
                      color: Palette.text,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        origin,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Palette.muted,
                      ),
                    ),
                    const Icon(
                      Icons.location_on,
                      size: 15,
                      color: Palette.accent,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        destination,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter({
    required this.showAlternative,
    required this.expired,
    required this.arrived,
  });
  final bool showAlternative;
  final bool expired;
  final bool arrived;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Palette.panel);
    final minorRoad = Paint()
      ..color = Palette.line.withValues(alpha: .65)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final majorRoad = Paint()
      ..color = Palette.brandSurface
      ..strokeWidth = 11
      ..style = PaintingStyle.stroke;
    for (double x = -80; x < size.width + 80; x += 72) {
      canvas.drawLine(Offset(x, 0), Offset(x + 105, size.height), minorRoad);
    }
    for (double y = 70; y < size.height + 70; y += 58) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 48), minorRoad);
    }
    canvas.drawPath(
      Path()
        ..moveTo(-10, size.height * .72)
        ..cubicTo(
          size.width * .26,
          size.height * .36,
          size.width * .62,
          size.height * .84,
          size.width + 10,
          size.height * .24,
        ),
      majorRoad,
    );

    final start = Offset(size.width * .16, size.height * .65);
    final end = Offset(size.width * .84, size.height * .43);
    final current = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        size.width * .34,
        size.height * .30,
        size.width * .58,
        size.height * .82,
        end.dx,
        end.dy,
      );
    canvas.drawPath(
      current,
      Paint()
        ..color = expired ? Palette.muted : Palette.warning
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    if (showAlternative) {
      final alternative = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          size.width * .35,
          size.height * .70,
          size.width * .58,
          size.height * .36,
          end.dx,
          end.dy,
        );
      canvas.drawPath(
        alternative,
        Paint()
          ..color = Palette.accent
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }

    for (final point in [start, end]) {
      canvas.drawCircle(point, 12, Paint()..color = Palette.bg);
      canvas.drawCircle(
        point,
        7,
        Paint()..color = point == end ? Palette.accent : Palette.text,
      );
    }
    final vehicle = arrived ? end : Offset(size.width * .53, size.height * .54);
    canvas.drawCircle(vehicle, 13, Paint()..color = Palette.bg);
    canvas.drawCircle(
      vehicle,
      8,
      Paint()..color = expired ? Palette.muted : Palette.warning,
    );
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.showAlternative != showAlternative ||
      oldDelegate.expired != expired ||
      oldDelegate.arrived != arrived;
}
