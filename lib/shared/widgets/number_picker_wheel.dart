import 'package:flutter/material.dart';
import 'package:fitcoach/core/theme/app_theme.dart';

class NumberPickerWheel extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int initialValue;
  final int step;
  final String suffix;
  final ValueChanged<int> onChanged;

  const NumberPickerWheel({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
    this.step = 1,
    required this.suffix,
    required this.onChanged,
  });

  @override
  State<NumberPickerWheel> createState() => _NumberPickerWheelState();
}

class _NumberPickerWheelState extends State<NumberPickerWheel> {
  late final FixedExtentScrollController _ctrl;
  int _selectedIdx = 0;

  @override
  void initState() {
    super.initState();
    _selectedIdx =
        (widget.initialValue - widget.minValue) ~/ widget.step;
    _ctrl = FixedExtentScrollController(initialItem: _selectedIdx);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int get _count =>
      (widget.maxValue - widget.minValue) ~/ widget.step + 1;

  int _valueAt(int idx) => widget.minValue + idx * widget.step;

  @override
  Widget build(BuildContext context) {
    const double itemExtent = 44.0;
    const double height = 180.0;
    const double lineOffset = (height - itemExtent) / 2;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // ── Wheel ──────────────────────────────────────────
          ListWheelScrollView.useDelegate(
            controller: _ctrl,
            itemExtent: itemExtent,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (idx) {
              setState(() => _selectedIdx = idx);
              widget.onChanged(_valueAt(idx));
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: _count,
              builder: (context, idx) {
                final isSelected = idx == _selectedIdx;
                final dist = (idx - _selectedIdx).abs();
                final opacity =
                    dist == 0 ? 1.0 : dist == 1 ? 0.4 : 0.15;
                return Center(
                  child: AnimatedOpacity(
                    opacity: opacity,
                    duration: const Duration(milliseconds: 80),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 80),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSelected ? 24 : 16,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          child: Text('${_valueAt(idx)}'),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 4),
                          Text(
                            widget.suffix,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Top/bottom fade ────────────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.backgroundCard,
                      Colors.transparent,
                      Colors.transparent,
                      AppColors.backgroundCard,
                    ],
                    stops: const [0.0, 0.28, 0.72, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Center highlight lines ─────────────────────────
          Positioned(
            top: lineOffset,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Column(
                children: [
                  Container(height: 1, color: AppColors.primary),
                  const SizedBox(height: itemExtent - 2),
                  Container(height: 1, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
