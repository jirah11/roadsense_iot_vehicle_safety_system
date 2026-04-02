import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

class LaunchScreen extends StatefulWidget {
  final Future<bool> Function() hasSeenOnboarding;
  final VoidCallback goToLogin;
  final VoidCallback goToOnboarding;

  const LaunchScreen({
    super.key,
    required this.hasSeenOnboarding,
    required this.goToLogin,
    required this.goToOnboarding,
  });

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen>
    with TickerProviderStateMixin {
  late final AnimationController _contentCtrl;
  late final AnimationController _particlesCtrl;
  Timer? _visibleTimer;
  Timer? _exitTimer;
  Timer? _navTimer;

  bool _exiting = false;

  @override
  void initState() {
    super.initState();
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _particlesCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _visibleTimer = Timer(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      _contentCtrl.forward();
    });
    _exitTimer = Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      setState(() => _exiting = true);
    });
    _navTimer = Timer(const Duration(milliseconds: 2900), () async {
      final hasSeen = await widget.hasSeenOnboarding();
      if (!mounted) return;
      if (hasSeen) {
        widget.goToLogin();
      } else {
        widget.goToOnboarding();
      }
    });
  }

  @override
  void dispose() {
    _visibleTimer?.cancel();
    _exitTimer?.cancel();
    _navTimer?.cancel();
    _contentCtrl.dispose();
    _particlesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fadeOut = _exiting ? 0.0 : 1.0;

    return Stack(
      children: [
        const _LaunchBackground(),
        Positioned.fill(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: fadeOut,
            child: Stack(
              children: [
                _ambientOrb(
                  top: -120,
                  right: -120,
                  size: 500,
                  colors: const [
                    Color.fromRGBO(84, 119, 146, 0.12),
                    Color(0x00000000),
                  ],
                ),
                _ambientOrb(
                  bottom: -100,
                  left: -100,
                  size: 400,
                  colors: const [
                    Color.fromRGBO(148, 180, 193, 0.08),
                    Color(0x00000000),
                  ],
                ),
                _Particles(controller: _particlesCtrl, exiting: _exiting),
                Center(
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _contentCtrl,
                      curve: Curves.easeOut,
                    ),
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.08),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _contentCtrl,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: _LaunchContent(exiting: _exiting),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 80,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: fadeOut,
                    child: const _LoadingIndicator(),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 32,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: fadeOut,
                    child: Text(
                      'v1.0.0',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _ambientOrb({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required List<Color> colors,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors, stops: const [0.0, 0.7]),
        ),
      ),
    );
  }
}

class _LaunchBackground extends StatelessWidget {
  const _LaunchBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2D40), Color(0xFF213448), Color(0xFF1E3D56)],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
    );
  }
}

class _Particles extends StatelessWidget {
  final AnimationController controller;
  final bool exiting;

  const _Particles({required this.controller, required this.exiting});

  @override
  Widget build(BuildContext context) {
    const dots = [
      _Dot(top: 0.15, left: 0.10, size: 6, delay: 0.5),
      _Dot(top: 0.20, right: 0.12, size: 4, delay: 0.7),
      _Dot(top: 0.70, left: 0.08, size: 5, delay: 0.9),
      _Dot(top: 0.75, right: 0.10, size: 4, delay: 0.6),
      _Dot(top: 0.40, left: 0.05, size: 3, delay: 1.0),
      _Dot(top: 0.55, right: 0.06, size: 5, delay: 0.8),
    ];

    return LayoutBuilder(
      builder: (context, c) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final t = controller.value;
          return Stack(
            children: [
              for (final d in dots)
                Positioned(
                  top: c.maxHeight * d.top,
                  left: d.left == null ? null : c.maxWidth * d.left!,
                  right: d.right == null ? null : c.maxWidth * d.right!,
                  child: Opacity(
                    opacity: exiting ? 0 : _dotOpacity(t, d.delay),
                    child: Transform.translate(
                      offset: Offset(0, _dotY(t, d.delay)),
                      child: Container(
                        width: d.size,
                        height: d.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(
                            0xFF94B4C1,
                          ).withValues(alpha: 0.30),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  double _dotOpacity(double t, double delay) {
    final local = (t + delay) % 1.0;
    final wave = 0.45 + 0.15 * math.sin(local * math.pi * 2);
    return wave.clamp(0.0, 0.9);
  }

  double _dotY(double t, double delay) {
    final local = (t + delay) % 1.0;
    return 6 * math.sin(local * math.pi * 2);
  }
}

class _Dot {
  final double top;
  final double? left;
  final double? right;
  final double size;
  final double delay;

  const _Dot({
    required this.top,
    this.left,
    this.right,
    required this.size,
    required this.delay,
  });
}

class _LaunchContent extends StatelessWidget {
  final bool exiting;

  const _LaunchContent({required this.exiting});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 350),
      opacity: exiting ? 0 : 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          _LogoMark(exiting: exiting),
          const SizedBox(height: 18),
          Text(
            'RoadSense',
            style: GoogleFonts.inter(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              height: 1.0,
              letterSpacing: -1,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'IoT Vehicle Safety Monitoring',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.65,
              color: const Color(0xFF94B4C1),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoMark extends StatefulWidget {
  final bool exiting;
  const _LogoMark({required this.exiting});

  @override
  State<_LogoMark> createState() => _LogoMarkState();
}

class _LogoMarkState extends State<_LogoMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final pop = Curves.elasticOut.transform(_ctrl.value);
        return Opacity(
          opacity: widget.exiting ? 0 : 1,
          child: Transform.scale(
            scale: 0.55 + (0.45 * pop),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const RadialGradient(
                      colors: [
                        Color.fromRGBO(148, 180, 193, 0.25),
                        Color(0x00000000),
                      ],
                      stops: [0.0, 0.7],
                    ),
                  ),
                ),
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF547792),
                        Color(0xFF3D6278),
                        Color(0xFF2E5068),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 28,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 8,
                        left: 8,
                        right: 32,
                        height: 32,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.18),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'RS',
                          style: GoogleFonts.inter(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LoadingIndicator extends StatefulWidget {
  const _LoadingIndicator();

  @override
  State<_LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 128,
            height: 2,
            color: Colors.white.withValues(alpha: 0.10),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                return FractionalTranslation(
                  translation: Offset(-1 + 2 * _ctrl.value, 0),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Initializing sensors...',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.30),
          ),
        ),
      ],
    );
  }
}
