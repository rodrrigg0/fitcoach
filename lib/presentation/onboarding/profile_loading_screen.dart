import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fitcoach/core/constants/app_constants.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/data/models/user_profile.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

class ProfileLoadingScreen extends StatefulWidget {
  final UserProfile profile;

  const ProfileLoadingScreen({required this.profile, super.key});

  @override
  State<ProfileLoadingScreen> createState() =>
      _ProfileLoadingScreenState();
}

class _ProfileLoadingScreenState extends State<ProfileLoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _progressCtrl;
  late final AnimationController _fadeOutCtrl;
  late final AnimationController _pulseCtrl;
  late final List<AnimationController> _pillCtrls;

  late final Animation<double> _progressAnim;
  late final Animation<double> _fadeOutAnim;
  late final Animation<double> _pulseAnim;
  late final List<Animation<double>> _pillAnims;

  int _phase = 0;

  static const _phase1Ms = 1500;
  static const _phase2Ms = 3000;
  static const _totalMs = 4000;

  @override
  void initState() {
    super.initState();

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
    );
    _progressAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.4), weight: 37.5),
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 0.8), weight: 37.5),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.0), weight: 25.0),
    ]).animate(_progressCtrl);

    _fadeOutCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeOutAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutCtrl, curve: Curves.easeIn),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _pillCtrls = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _pillAnims = _pillCtrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut)
            as Animation<double>)
        .toList();

    _startSequence();
  }

  void _startSequence() {
    _progressCtrl.forward();

    Future.delayed(const Duration(milliseconds: _phase1Ms), () {
      if (!mounted) return;
      setState(() => _phase = 1);
      _pulseCtrl.repeat(reverse: true);
      for (int i = 0; i < 3; i++) {
        Future.delayed(Duration(milliseconds: 300 * i), () {
          if (mounted) _pillCtrls[i].forward();
        });
      }
    });

    Future.delayed(const Duration(milliseconds: _phase2Ms), () {
      if (!mounted) return;
      setState(() => _phase = 2);
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    });

    Future.delayed(
        const Duration(milliseconds: _totalMs - 600), () {
      if (mounted) _fadeOutCtrl.forward();
    });

    Future.delayed(const Duration(milliseconds: _totalMs), () {
      if (mounted) context.go(AppConstants.routeHome);
    });
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _fadeOutCtrl.dispose();
    _pulseCtrl.dispose();
    for (final c in _pillCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  static String _prettifyObjetivo(String obj) {
    const map = {
      'perder_grasa': 'Perder grasa',
      'ganar_musculo': 'Ganar músculo',
      'recomposicion': 'Recomposición',
      'rendimiento': 'Rendimiento',
      'mantener': 'Mantener',
      'salud': 'Salud general',
    };
    return map[obj] ?? obj;
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final pills = <String>[
      if (profile.deportes.isNotEmpty) profile.deportes.first,
      if (profile.objetivo.isNotEmpty) _prettifyObjetivo(profile.objetivo),
      if (profile.diasEntrenamiento > 0)
        '${profile.diasEntrenamiento} días/sem.',
    ].take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeOutAnim,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Silueta (pulsa en fase 2) ─────────────────
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, child) => Transform.scale(
                    scale: _phase == 1 ? _pulseAnim.value : 1.0,
                    child: child,
                  ),
                  child: const _FullSilhouette(width: 120, height: 180),
                ),
                const SizedBox(height: 32),

                // ── Texto de fase ─────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: child,
                  ),
                  child: _phase == 2
                      ? Column(
                          key: const ValueKey('phase3'),
                          children: [
                            Text(
                              AppLocalizations.of(context)!.onboardingLoadingDone(profile.nombre),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.onboardingLoadingPlanReady,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          key: ValueKey('phase${_phase}txt'),
                          _phase == 0
                              ? AppLocalizations.of(context)!.onboardingLoadingPhase0
                              : AppLocalizations.of(context)!.onboardingLoadingPhase1,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                ),

                const SizedBox(height: 24),

                // ── Pills (aparecen en fase 2) ────────────────
                if (_phase >= 1) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: List.generate(
                      pills.length,
                      (i) => FadeTransition(
                        opacity: _pillAnims[i],
                        child: _Pill(label: pills[i]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Barra de progreso ─────────────────────────
                AnimatedBuilder(
                  animation: _progressCtrl,
                  builder: (context, child) => ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progressAnim.value,
                      backgroundColor: AppColors.backgroundElevated,
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Silueta completamente iluminada
// ─────────────────────────────────────────────────────────────

class _FullSilhouette extends StatelessWidget {
  final double width;
  final double height;

  const _FullSilhouette({this.width = 70, this.height = 110});

  @override
  Widget build(BuildContext context) {
    final sx = width / 70;
    final sy = height / 110;

    Widget part({
      required double left,
      required double top,
      required double pw,
      required double ph,
      required double radius,
      bool circle = false,
    }) =>
        Positioned(
          left: left * sx,
          top: top * sy,
          child: Container(
            width: pw * sx,
            height: ph * sy,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: circle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius:
                  circle ? null : BorderRadius.circular(radius * sx),
            ),
          ),
        );

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          part(left: 27, top: 0, pw: 16, ph: 16, radius: 8, circle: true),
          part(left: 32, top: 16, pw: 6, ph: 6, radius: 2),
          part(left: 21, top: 22, pw: 28, ph: 32, radius: 6),
          part(left: 7, top: 23, pw: 11, ph: 28, radius: 5),
          part(left: 52, top: 23, pw: 11, ph: 28, radius: 5),
          part(left: 20, top: 56, pw: 13, ph: 54, radius: 5),
          part(left: 37, top: 56, pw: 13, ph: 54, radius: 5),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Pill widget
// ─────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 13,
        ),
      ),
    );
  }
}
