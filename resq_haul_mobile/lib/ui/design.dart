import 'dart:math';
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

class RouteMap extends StatefulWidget {
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
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> with TickerProviderStateMixin {
  late final AnimationController _drawController;
  late final AnimationController _vehicleController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _vehicleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _drawController.dispose();
    _vehicleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.arrived
        ? 'Arrival confirmed at ${widget.destination}.'
        : 'Route from ${widget.origin} to ${widget.destination}. Current estimate ${widget.currentEta} minutes${widget.alternativeEta == null ? '' : ', alternative ${widget.alternativeEta} minutes'}.',
    child: ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 260,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _drawController,
                  _vehicleController,
                  _pulseController,
                ]),
                builder: (context, _) => CustomPaint(
                  painter: _AnimatedRoutePainter(
                    drawProgress: _drawController.value,
                    vehicleProgress: _vehicleController.value,
                    pulseProgress: _pulseController.value,
                    showAlternative:
                        !widget.arrived &&
                        widget.alternativeEta != null &&
                        widget.alternativeEta! < widget.currentEta,
                    expired: widget.expired,
                    arrived: widget.arrived,
                  ),
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
                    widget.arrived
                        ? 'Arrival confirmed'
                        : widget.expired
                        ? 'Food window elapsed'
                        : 'Current · ${widget.currentEta} min',
                    color: widget.expired ? Palette.warning : Palette.text,
                    icon: widget.expired
                        ? Icons.timer_off_outlined
                        : widget.arrived
                        ? Icons.check_circle
                        : Icons.traffic,
                  ),
                  if (!widget.arrived &&
                      widget.alternativeEta != null &&
                      widget.alternativeEta! < widget.currentEta)
                    Pill(
                      'Faster route · ${widget.alternativeEta} min',
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
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Palette.bg.withValues(alpha: .92),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Palette.line),
                  boxShadow: [
                    BoxShadow(
                      color: Palette.text.withValues(alpha: .06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Palette.text,
                        border: Border.all(color: Palette.bg, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Palette.text.withValues(alpha: .2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.origin,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Palette.muted.withValues(alpha: .3),
                                  Palette.accent.withValues(alpha: .6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: Palette.accent,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Palette.accent,
                        border: Border.all(color: Palette.bg, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Palette.accent.withValues(alpha: .3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.destination,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
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

class _AnimatedRoutePainter extends CustomPainter {
  const _AnimatedRoutePainter({
    required this.drawProgress,
    required this.vehicleProgress,
    required this.pulseProgress,
    required this.showAlternative,
    required this.expired,
    required this.arrived,
  });

  final double drawProgress;
  final double vehicleProgress;
  final double pulseProgress;
  final bool showAlternative;
  final bool expired;
  final bool arrived;

  // Calculate a point on a cubic Bezier at parameter t.
  Offset _bezier(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final u = 1 - t;
    return p0 * (u * u * u) +
        p1 * (3 * u * u * t) +
        p2 * (3 * u * t * t) +
        p3 * (t * t * t);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // --- Background ---
    final bgRect = Offset.zero & size;
    canvas.drawRect(
      bgRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF6F9F2), Color(0xFFEEF3E8), Color(0xFFF0F5EC)],
        ).createShader(bgRect),
    );

    // --- Grid / Street Pattern ---
    final gridPaint = Paint()
      ..color = Palette.line.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    final gridSpacingH = size.width / 12;
    final gridSpacingV = size.height / 8;
    for (double x = gridSpacingH; x < size.width; x += gridSpacingH) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = gridSpacingV; y < size.height; y += gridSpacingV) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // --- "City block" fills for visual richness ---
    final blockPaint = Paint()..color = const Color(0xFFE3ECD8).withValues(alpha: 0.5);
    for (int i = 0; i < 4; i++) {
      final bx = gridSpacingH * (2 + i * 3) + 3;
      final by = gridSpacingV * (1 + (i % 3) * 2) + 3;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, by, gridSpacingH * 2 - 6, gridSpacingV - 6),
          const Radius.circular(4),
        ),
        blockPaint,
      );
    }

    // --- Major roads (wider) ---
    final majorRoad = Paint()
      ..color = const Color(0xFFD4DFCA)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    // Horizontal major road
    canvas.drawPath(
      Path()
        ..moveTo(-10, size.height * .45)
        ..cubicTo(
          size.width * .2, size.height * .40,
          size.width * .7, size.height * .50,
          size.width + 10, size.height * .35,
        ),
      majorRoad,
    );
    // Diagonal major road
    canvas.drawPath(
      Path()
        ..moveTo(-10, size.height * .85)
        ..cubicTo(
          size.width * .30, size.height * .30,
          size.width * .60, size.height * .80,
          size.width + 10, size.height * .15,
        ),
      majorRoad,
    );

    // --- Route geometry ---
    final startPt = Offset(size.width * .14, size.height * .62);
    final endPt = Offset(size.width * .86, size.height * .38);
    final cp1Main = Offset(size.width * .32, size.height * .22);
    final cp2Main = Offset(size.width * .60, size.height * .82);

    // --- Draw alternative route (dashed, animated) ---
    if (showAlternative) {
      final cp1Alt = Offset(size.width * .36, size.height * .72);
      final cp2Alt = Offset(size.width * .60, size.height * .30);
      final altPath = Path()
        ..moveTo(startPt.dx, startPt.dy)
        ..cubicTo(cp1Alt.dx, cp1Alt.dy, cp2Alt.dx, cp2Alt.dy, endPt.dx, endPt.dy);

      // Animated dashes
      final dashPaint = Paint()
        ..color = Palette.accent.withValues(alpha: .6)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final altMetrics = altPath.computeMetrics().first;
      final totalLen = altMetrics.length;
      const dashLen = 10.0;
      const gapLen = 8.0;
      final offset = (vehicleProgress * (dashLen + gapLen)) % (dashLen + gapLen);
      double dist = -offset;
      while (dist < totalLen) {
        final s = dist.clamp(0.0, totalLen);
        final e = (dist + dashLen).clamp(0.0, totalLen);
        if (e > s) {
          final segment = altMetrics.extractPath(s, e);
          canvas.drawPath(segment, dashPaint);
        }
        dist += dashLen + gapLen;
      }

      // Draw a subtle glow under the alternative route
      canvas.drawPath(
        altPath,
        Paint()
          ..color = Palette.accent.withValues(alpha: .08)
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // --- Draw main route (animated drawing) ---
    final mainPath = Path()
      ..moveTo(startPt.dx, startPt.dy)
      ..cubicTo(
        cp1Main.dx, cp1Main.dy,
        cp2Main.dx, cp2Main.dy,
        endPt.dx, endPt.dy,
      );
    final mainMetrics = mainPath.computeMetrics().first;
    final drawnLength = mainMetrics.length * drawProgress.clamp(0.0, 1.0);
    final drawnPath = mainMetrics.extractPath(0, drawnLength);

    // Glow under main route
    canvas.drawPath(
      drawnPath,
      Paint()
        ..color = (expired ? Palette.muted : Palette.warning).withValues(alpha: .10)
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Main route line with rounded caps
    final routeColor = expired ? Palette.muted : Palette.warning;
    canvas.drawPath(
      drawnPath,
      Paint()
        ..color = routeColor.withValues(alpha: .3)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      drawnPath,
      Paint()
        ..color = routeColor
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // --- Vehicle position ---
    final double vehicleT;
    if (arrived) {
      vehicleT = 1.0;
    } else {
      // Smooth oscillation between ~0.3 and ~0.7 to simulate motion
      vehicleT = 0.3 + 0.4 * (0.5 + 0.5 * _smoothCycle(vehicleProgress));
    }
    final vehiclePos = _bezier(startPt, cp1Main, cp2Main, endPt, vehicleT);

    // Vehicle shadow
    canvas.drawCircle(
      vehiclePos + const Offset(1, 2),
      14,
      Paint()
        ..color = Palette.text.withValues(alpha: .08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Vehicle outer ring (animated pulse)
    final vPulseR = 14.0 + 3.0 * pulseProgress;
    canvas.drawCircle(
      vehiclePos,
      vPulseR,
      Paint()..color = (expired ? Palette.muted : Palette.warning).withValues(alpha: .15 * (1 - pulseProgress)),
    );

    // Vehicle body
    canvas.drawCircle(vehiclePos, 13, Paint()..color = Palette.bg);
    canvas.drawCircle(
      vehiclePos,
      8,
      Paint()..color = expired ? Palette.muted : Palette.warning,
    );
    // Vehicle inner dot
    canvas.drawCircle(vehiclePos, 3.5, Paint()..color = Palette.bg);

    // --- Origin marker ---
    // Pulse ring
    final oPulseR = 16.0 + 4.0 * pulseProgress;
    canvas.drawCircle(
      startPt,
      oPulseR,
      Paint()..color = Palette.text.withValues(alpha: .06 * (1 - pulseProgress)),
    );
    // Shadow
    canvas.drawCircle(
      startPt + const Offset(1, 2),
      13,
      Paint()
        ..color = Palette.text.withValues(alpha: .08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(startPt, 13, Paint()..color = Palette.bg);
    canvas.drawCircle(startPt, 7, Paint()..color = Palette.text);
    canvas.drawCircle(startPt, 3, Paint()..color = Palette.bg);

    // --- Destination marker ---
    // Pulse ring
    final dPulseR = 16.0 + 5.0 * pulseProgress;
    canvas.drawCircle(
      endPt,
      dPulseR,
      Paint()..color = Palette.accent.withValues(alpha: .10 * (1 - pulseProgress)),
    );
    // Shadow
    canvas.drawCircle(
      endPt + const Offset(1, 2),
      13,
      Paint()
        ..color = Palette.accent.withValues(alpha: .12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(endPt, 13, Paint()..color = Palette.bg);
    canvas.drawCircle(endPt, 7, Paint()..color = Palette.accent);
    canvas.drawCircle(endPt, 3, Paint()..color = Palette.bg);

    // --- Arrival celebration rings ---
    if (arrived) {
      for (var i = 0; i < 3; i++) {
        final r = 20.0 + (i * 12.0) + 6.0 * pulseProgress;
        canvas.drawCircle(
          endPt,
          r,
          Paint()
            ..color = Palette.accent.withValues(alpha: .08 * (1 - pulseProgress * .7))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  double _smoothCycle(double t) {
    return sin(t * 2 * pi);
  }

  @override
  bool shouldRepaint(covariant _AnimatedRoutePainter oldDelegate) => true;
}
