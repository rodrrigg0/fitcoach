import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

enum PlanType { training, nutrition }

/// Wraps [child] and replaces it with [PlanLoadingBar] while [isLoading] is
/// true. Waits for the bar's completion animation before revealing [child].
class PlanGeneratorView extends StatefulWidget {
  final bool isLoading;
  final PlanType type;
  final Widget child;
  final bool compact;

  const PlanGeneratorView({
    super.key,
    required this.isLoading,
    required this.type,
    required this.child,
    this.compact = false,
  });

  @override
  State<PlanGeneratorView> createState() => _PlanGeneratorViewState();
}

class _PlanGeneratorViewState extends State<PlanGeneratorView> {
  bool _showBar = false;

  @override
  void initState() {
    super.initState();
    _showBar = widget.isLoading;
  }

  @override
  void didUpdateWidget(PlanGeneratorView old) {
    super.didUpdateWidget(old);
    if (widget.isLoading && !_showBar) {
      setState(() => _showBar = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showBar) {
      return PlanLoadingBar(
        isLoading: widget.isLoading,
        type: widget.type,
        compact: widget.compact,
        onComplete: () {
          if (mounted) setState(() => _showBar = false);
        },
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: KeyedSubtree(
        key: ValueKey(widget.child.runtimeType),
        child: widget.child,
      ),
    );
  }
}

/// Animated loading bar for AI plan generation.
///
/// Simulates progress from 0 → 90% via a timer:
///  • 0–30 % in the first 3 s  (fast start)
///  • 30–70 % over the next 7 s (medium)
///  • 70–90 % over the next 8 s (slow)
///  • Holds at 90 % until [isLoading] becomes false
///
/// When [isLoading] flips to false the bar races to 100 % in 500 ms,
/// pulses a glow for 600 ms, then calls [onComplete].
class PlanLoadingBar extends StatefulWidget {
  final bool isLoading;
  final PlanType type;
  final VoidCallback? onComplete;

  /// Compact mode — used inside small containers (e.g. hero card).
  /// Hides the large icon and uses a denser layout.
  final bool compact;

  const PlanLoadingBar({
    super.key,
    required this.isLoading,
    required this.type,
    this.onComplete,
    this.compact = false,
  });

  @override
  State<PlanLoadingBar> createState() => _PlanLoadingBarState();
}

class _PlanLoadingBarState extends State<PlanLoadingBar>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  int _elapsedMs = 0;
  Timer? _simTimer;
  Timer? _completeTimer;
  bool _completing = false;
  bool _done = false;

  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _startSimulation();
  }

  @override
  void didUpdateWidget(PlanLoadingBar old) {
    super.didUpdateWidget(old);
    if (old.isLoading && !widget.isLoading && !_completing) {
      _doComplete();
    }
  }

  // ── Simulated progress timer ────────────────────────────────

  void _startSimulation() {
    _simTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted || _completing) {
        t.cancel();
        return;
      }
      _elapsedMs += 100;
      final np = _simulatedProgress(_elapsedMs);
      setState(() => _progress = np);
      if (_elapsedMs >= 18000) t.cancel(); // Settled at 90 %
    });
  }

  static double _simulatedProgress(int ms) {
    if (ms <= 3000) return (ms / 3000) * 0.30;
    if (ms <= 10000) return 0.30 + ((ms - 3000) / 7000) * 0.40;
    if (ms <= 18000) return 0.70 + ((ms - 10000) / 8000) * 0.20;
    return 0.90;
  }

  // ── Completion animation ────────────────────────────────────

  void _doComplete() {
    _simTimer?.cancel();
    _completing = true;
    final start = _progress;
    const steps = 20; // 25 ms × 20 = 500 ms total
    int step = 0;

    _completeTimer = Timer.periodic(const Duration(milliseconds: 25), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      step++;
      setState(() {
        _progress = (start + (1.0 - start) * (step / steps)).clamp(0.0, 1.0);
      });
      if (step >= steps) {
        t.cancel();
        if (!mounted) return;
        setState(() => _done = true);
        _glowCtrl.repeat(reverse: true);
        Future.delayed(const Duration(milliseconds: 600), () {
          _glowCtrl.stop();
          widget.onComplete?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _completeTimer?.cancel();
    _glowCtrl.dispose();
    super.dispose();
  }

  // ── Message helpers ─────────────────────────────────────────

  String _message(AppLocalizations l10n) {
    if (_done) return l10n.planLoadingReady;
    final pct = (_progress * 100).round();
    if (widget.type == PlanType.training) {
      if (pct < 20) return l10n.trainingLoadPhase0;
      if (pct < 40) return l10n.trainingLoadPhase1;
      if (pct < 60) return l10n.trainingLoadPhase2;
      if (pct < 80) return l10n.trainingLoadPhase3;
      return l10n.loadingLastAdjustments;
    } else {
      if (pct < 20) return l10n.nutritionLoadPhase0;
      if (pct < 40) return l10n.nutritionLoadPhase1;
      if (pct < 60) return l10n.nutritionLoadPhase2;
      if (pct < 80) return l10n.nutritionLoadPhase3;
      return l10n.loadingLastAdjustments;
    }
  }

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final msg = _message(l10n);
    final pct = (_progress * 100).round();

    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (ctx, _) {
        final glow = _done
            ? Curves.easeInOut.transform(_glowCtrl.value)
            : 0.0;
        return widget.compact
            ? _compact(ctx, pct, msg, glow)
            : _full(ctx, pct, msg, glow);
      },
    );
  }

  // ── Full layout (training / nutrition screens) ──────────────

  Widget _full(BuildContext context, int pct, String msg, double glow) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: _done ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                widget.type == PlanType.training
                    ? Icons.fitness_center
                    : Icons.restaurant_menu,
                color: AppColors.primary,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: Text(
                msg,
                key: ValueKey(msg),
                style: TextStyle(
                  color: _done ? AppColors.primary : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            _barWithPct(pct, glow),
          ],
        ),
      ),
    );
  }

  // ── Compact layout (hero card) ──────────────────────────────

  Widget _compact(BuildContext context, int pct, String msg, double glow) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.type == PlanType.training
                    ? Icons.fitness_center
                    : Icons.restaurant_menu,
                color: AppColors.primary,
                size: 15,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    msg,
                    key: ValueKey(msg),
                    style: TextStyle(
                      color: _done
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$pct%',
                style: TextStyle(
                  color: _done ? AppColors.primary : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _bar(glow),
        ],
      ),
    );
  }

  // ── Progress bar widgets ────────────────────────────────────

  Widget _barWithPct(int pct, double glow) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _bar(glow)),
        const SizedBox(width: 12),
        SizedBox(
          width: 46,
          child: Text(
            '$pct%',
            textAlign: TextAlign.end,
            style: TextStyle(
              color: _done ? AppColors.primary : AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _bar(double glow) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final fillW =
            (constraints.maxWidth * _progress).clamp(0.0, constraints.maxWidth);
        return Stack(
          children: [
            // Track
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Fill
            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              height: 8,
              width: fillW,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
                boxShadow: (_completing || _done) && glow > 0
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.6 * glow),
                          blurRadius: 12.0 * glow,
                          spreadRadius: 2.0 * glow,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}
