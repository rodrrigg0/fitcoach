import 'package:flutter/material.dart';

class TutorialStep {
  final GlobalKey targetKey;
  final String titulo;
  final String descripcion;
  final IconData icon;

  const TutorialStep({
    required this.targetKey,
    required this.titulo,
    required this.descripcion,
    required this.icon,
  });
}

class AppTutorial extends StatefulWidget {
  final List<TutorialStep> steps;
  final VoidCallback onFinish;

  const AppTutorial({
    super.key,
    required this.steps,
    required this.onFinish,
  });

  @override
  State<AppTutorial> createState() => _AppTutorialState();
}

class _AppTutorialState extends State<AppTutorial>
    with SingleTickerProviderStateMixin {
  int _paso = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Rect _getRectOfKey(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Rect.zero;
    final pos = box.localToGlobal(Offset.zero);
    return Rect.fromLTWH(pos.dx, pos.dy, box.size.width, box.size.height);
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_paso];
    final screen = MediaQuery.of(context).size;
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    Rect rect = _getRectOfKey(step.targetKey);

    if (rect == Rect.zero) {
      rect = Rect.fromCenter(
        center: Offset(screen.width / 2, screen.height / 2),
        width: 100,
        height: 50,
      );
    }

    const tooltipHeight = 200.0;
    const tooltipMargin = 16.0;

    final spaceBelow =
        screen.height - rect.bottom - safeBottom - tooltipMargin;
    final spaceAbove = rect.top - safeTop - tooltipMargin;

    double? top;
    double? bottom;

    if (spaceBelow >= tooltipHeight) {
      top = rect.bottom + tooltipMargin;
    } else if (spaceAbove >= tooltipHeight) {
      bottom = screen.height - rect.top + tooltipMargin;
    } else {
      top = safeTop + tooltipMargin;
    }

    if (top != null) {
      top = top.clamp(
        safeTop + tooltipMargin,
        screen.height - tooltipHeight - safeBottom - tooltipMargin,
      );
    }

    if (bottom != null) {
      final maxBottom =
          screen.height - safeTop - tooltipHeight - tooltipMargin;
      bottom = bottom.clamp(safeBottom + tooltipMargin, maxBottom);
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          CustomPaint(
            size: screen,
            painter: _HolePainter(
              holeRect: rect.inflate(8),
              radius: 14,
            ),
          ),
          Positioned(
            left: rect.left - 8,
            top: rect.top - 8,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, _) => Transform.scale(
                scale: _pulseAnim.value,
                child: Container(
                  width: rect.width + 16,
                  height: rect.height + 16,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFC8F135),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: tooltipMargin,
            right: tooltipMargin,
            top: top,
            bottom: bottom,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildTooltip(step),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltip(TutorialStep step) {
    final total = widget.steps.length;
    final esUltimo = _paso == total - 1;

    return Container(
      key: ValueKey(_paso),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC8F135).withAlpha(77),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(128),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFC8F135).withAlpha(38),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(step.icon, color: const Color(0xFFC8F135), size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step.titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${_paso + 1} / $total',
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            step.descripcion,
            style: const TextStyle(
              color: Color(0xFFCCCCCC),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (!esUltimo)
                GestureDetector(
                  onTap: widget.onFinish,
                  child: const Text(
                    'Saltar',
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 13,
                    ),
                  ),
                ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  if (esUltimo) {
                    widget.onFinish();
                  } else {
                    setState(() => _paso++);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8F135),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    esUltimo ? '¡Empezar!' : 'Siguiente →',
                    style: const TextStyle(
                      color: Color(0xFF0D0D0D),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HolePainter extends CustomPainter {
  final Rect holeRect;
  final double radius;

  const _HolePainter({required this.holeRect, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withAlpha(209);
    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()
      ..addRRect(RRect.fromRectAndRadius(holeRect, Radius.circular(radius)));
    final combined = Path.combine(
      PathOperation.difference,
      fullPath,
      holePath,
    );
    canvas.drawPath(combined, paint);
  }

  @override
  bool shouldRepaint(_HolePainter old) => old.holeRect != holeRect;
}
