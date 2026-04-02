import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

//entry point ng onboarding flow
//require ng callbck which is [goToLoginAndMarkSeen] para sa parent app
//para if tapos na yung user tignan yung onboarding screen
class OnboardingScreen extends StatefulWidget {
  final VoidCallback goToLoginAndMarkSeen;

  const OnboardingScreen({super.key, required this.goToLoginAndMarkSeen});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

//hinahandle lahat yung animation tapos page transition
class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin { //purpose is nagpapower ng multiple AnimationController
  late final PageController _pageCtrl;
  int _index = 0;
  bool _isAnimating = false;

  late final AnimationController _ringRotateCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _float1Ctrl;
  late final AnimationController _float2Ctrl;
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _ringRotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), //rotates ring 30 sec duration
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), //central icon shrink tapos lalaki, 2.5 sec loop
    )..repeat(reverse: true);
    _float1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000), //floating tapos bobbing effect sa icons
    )..repeat(reverse: true);
    _float2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500), //floating tapos bobbing effect sa icons
    )..repeat(reverse: true);
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300), //mga stars na nagtitwinkle
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    //panglinis ng controllers para iwas memory leaks
    _pageCtrl.dispose();
    _ringRotateCtrl.dispose();
    _pulseCtrl.dispose();
    _float1Ctrl.dispose();
    _float2Ctrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  Future<void> _goTo(int next) async {
    if (_isAnimating) return;
    setState(() => _isAnimating = true);
    await _pageCtrl.animateToPage(
      next,
      duration: const Duration(milliseconds: 380),
      curve: const Cubic(0.4, 0.0, 0.2, 1.0),
    );
    if (!mounted) return;
    setState(() {
      _index = next;
      _isAnimating = false;
    });
  }

  void _onContinue() {
    if (_index < _slides.length - 1) {
      _goTo(_index + 1);
    } else {
      widget.goToLoginAndMarkSeen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];

    return GestureDetector( //swipe left/right manually para sa navigation ng screens
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v.abs() < 250) return;
        if (v < 0 && _index < _slides.length - 1) _goTo(_index + 1);
        if (v > 0 && _index > 0) _goTo(_index - 1);
      },
      child: Stack(
        children: [
          const _OnboardingBackground(),
          Positioned(
            top: -140,
            right: -140,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 440,
              height: 440,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [slide.bgDot, Colors.transparent],
                  stops: const [0.0, 0.65],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -100,
            child: Container(
              width: 360,
              height: 360,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color.fromRGBO(84, 119, 146, 0.10),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.65],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 18,
                  left: 18,
                  child: Text(
                    '${_index + 1} / ${_slides.length}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.30),
                    ),
                  ),
                ),
                if (_index < _slides.length - 1)
                  Positioned(
                    top: 10,
                    right: 12,
                    child: TextButton(
                      onPressed: widget.goToLoginAndMarkSeen,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withValues(alpha: 0.70),
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.50),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: PageView.builder(
                    controller: _pageCtrl,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) => _SlideBody(
                      slide: _slides[i],
                      ringRotateCtrl: _ringRotateCtrl,
                      pulseCtrl: _pulseCtrl,
                      float1Ctrl: _float1Ctrl,
                      float2Ctrl: _float2Ctrl,
                      glowCtrl: _glowCtrl,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 22),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _slides.length,
                            (i) => _Dot(isActive: i == _index, onTap: () => _goTo(i)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Wrap with Container to apply the outer glow shadow
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.40),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.primary, Color(0xFF3D6278)],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  height: 24,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(999),
                                    ),
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
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _index < _slides.length - 1
                                          ? 'Continue'
                                          : 'Get Started',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right, size: 22),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_index == _slides.length - 1) ...[
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: widget.goToLoginAndMarkSeen,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.40),
                            ),
                            children: [
                              const TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Sign In',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF94B4C1),
                                  decoration: TextDecoration.underline,
                                  decorationColor: const Color(0xFF94B4C1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: MediaQuery.paddingOf(context).bottom),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingBackground extends StatelessWidget {
  const _OnboardingBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2D40), Color(0xFF213448), Color(0xFF1E3D56)],
          stops: [0.0, 0.50, 1.0],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _Dot({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        width: isActive ? 24 : 7,
        height: 7,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF94B4C1)
              : const Color(0xFF94B4C1).withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _SlideBody extends StatelessWidget {
  final _Slide slide;
  final AnimationController ringRotateCtrl;
  final AnimationController pulseCtrl;
  final AnimationController float1Ctrl;
  final AnimationController float2Ctrl;
  final AnimationController glowCtrl;

  const _SlideBody({
    required this.slide,
    required this.ringRotateCtrl,
    required this.pulseCtrl,
    required this.float1Ctrl,
    required this.float2Ctrl,
    required this.glowCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _Illustration(
            slide: slide,
            ringRotateCtrl: ringRotateCtrl,
            pulseCtrl: pulseCtrl,
            float1Ctrl: float1Ctrl,
            float2Ctrl: float2Ctrl,
            glowCtrl: glowCtrl,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.20),
              border: Border.all(
                color: const Color(0xFF94B4C1).withValues(alpha: 0.20),
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              slide.highlight,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.9,
                color: const Color(0xFF94B4C1),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.15,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              slide.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.55,
                color: const Color(0xFF94B4C1).withValues(alpha: 0.80),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  final _Slide slide;
  final AnimationController ringRotateCtrl;
  final AnimationController pulseCtrl;
  final AnimationController float1Ctrl;
  final AnimationController float2Ctrl;
  final AnimationController glowCtrl;

  const _Illustration({
    required this.slide,
    required this.ringRotateCtrl,
    required this.pulseCtrl,
    required this.float1Ctrl,
    required this.float2Ctrl,
    required this.glowCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.07),
              border: Border.all(
                color: const Color(0xFF94B4C1).withValues(alpha: 0.08),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: ringRotateCtrl,
            builder: (context, _) {
              return Transform.rotate(
                angle: ringRotateCtrl.value * math.pi * 2,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.10),
                    border: Border.all(
                      color: const Color(0xFF94B4C1).withValues(alpha: 0.12),
                    ),
                  ),
                  child: Stack(
                    children: const [
                      _Tick(deg: 0),
                      _Tick(deg: 90),
                      _Tick(deg: 180),
                      _Tick(deg: 270),
                    ],
                  ),
                ),
              );
            },
          ),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.25),
                  const Color(0xFF213448).withValues(alpha: 0.40),
                ],
              ),
              border: Border.all(
                width: 1.5,
                color: const Color(0xFF94B4C1).withValues(alpha: 0.20),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 40,
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: pulseCtrl,
            builder: (context, _) {
              final s = 1 + (pulseCtrl.value * 0.04);
              return Transform.scale(
                scale: s,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        Color(0xFF3D6278),
                        Color(0xFF2E5068),
                      ],
                      stops: [0.0, 0.6, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.50),
                        blurRadius: 32,
                        offset: const Offset(0, 10),
                      ),
                      const BoxShadow(
                        color: Colors.black38,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(slide.mainIcon, color: Colors.white, size: 40),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: float1Ctrl,
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(0, -4 + 8 * float1Ctrl.value),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, right: 20),
                    child: _AccentIcon(
                      size: 44,
                      radius: 18,
                      icon: slide.accentIcon1,
                      iconSize: 20,
                      alpha: 0.60,
                      borderAlpha: 0.25,
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: float2Ctrl,
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(0, 4 - 8 * float2Ctrl.value),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24, left: 18),
                    child: _AccentIcon(
                      size: 40,
                      radius: 16,
                      icon: slide.accentIcon2,
                      iconSize: 18,
                      alpha: 0.50,
                      borderAlpha: 0.20,
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: glowCtrl,
            builder: (context, _) {
              final o = 0.3 + 0.5 * glowCtrl.value;
              final s = 1 + 0.5 * glowCtrl.value;
              return Positioned(
                top: 78,
                left: 52,
                child: Opacity(
                  opacity: o,
                  child: Transform.scale(
                    scale: s,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF94B4C1).withValues(alpha: 0.60),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: glowCtrl,
            builder: (context, _) {
              final o = 0.4 + 0.5 * (1 - glowCtrl.value);
              final s = 1 + 0.4 * (1 - glowCtrl.value);
              return Positioned(
                bottom: 76,
                right: 54,
                child: Opacity(
                  opacity: o,
                  child: Transform.scale(
                    scale: s,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF547792).withValues(alpha: 0.80),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Tick extends StatelessWidget {
  final double deg;
  const _Tick({required this.deg});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Transform.rotate(
        angle: deg * math.pi / 180,
        child: Align(
          alignment: Alignment.centerRight,
          child: Transform.translate(
            offset: const Offset(-4, 0),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF94B4C1).withValues(alpha: 0.30),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccentIcon extends StatelessWidget {
  final double size;
  final double radius;
  final IconData icon;
  final double iconSize;
  final double alpha;
  final double borderAlpha;

  const _AccentIcon({
    required this.size,
    required this.radius,
    required this.icon,
    required this.iconSize,
    required this.alpha,
    required this.borderAlpha,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: alpha),
            const Color(0xFF213448).withValues(alpha: 0.80),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF94B4C1).withValues(alpha: borderAlpha),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize, color: const Color(0xFF94B4C1)),
    );
  }
}

//data model
class _Slide {
  final IconData mainIcon;
  final IconData accentIcon1;
  final IconData accentIcon2;
  final String title;
  final String description;
  final String highlight;
  final Color bgDot;

  const _Slide({
    required this.mainIcon,
    required this.accentIcon1,
    required this.accentIcon2,
    required this.title,
    required this.description,
    required this.highlight,
    required this.bgDot,
  });
}
//actual data
const _slides = <_Slide>[
  _Slide(
    mainIcon: Icons.shield_outlined,
    accentIcon1: Icons.waves_outlined,
    accentIcon2: Icons.thermostat_outlined,
    title: 'Stay Safe on\nEvery Road',
    description:
        'RoadSense connects to IoT sensors in your vehicle to monitor flood levels and engine temperature in real-time.',
    highlight: 'REAL-TIME MONITORING',
    bgDot: Color.fromRGBO(84, 119, 146, 0.15),
  ),
  _Slide(
    mainIcon: Icons.notifications_none,
    accentIcon1: Icons.monitor_heart_outlined,
    accentIcon2: Icons.shield_outlined,
    title: 'Instant Alerts,\nZero Surprises',
    description:
        'Receive immediate hazard notifications the moment conditions become unsafe — flood, heat, or engine stress.',
    highlight: 'SMART ALERTS',
    bgDot: Color.fromRGBO(148, 180, 193, 0.12),
  ),
  _Slide(
    mainIcon: Icons.tune,
    accentIcon1: Icons.directions_car_outlined,
    accentIcon2: Icons.monitor_heart_outlined,
    title: 'Built for\nYour Vehicle',
    description:
        'Set custom safety thresholds for your vehicle type — Sedan, SUV, Hatchback, or Coupe — and drive with confidence.',
    highlight: 'CUSTOM THRESHOLDS',
    bgDot: Color.fromRGBO(84, 119, 146, 0.12),
  ),
];
