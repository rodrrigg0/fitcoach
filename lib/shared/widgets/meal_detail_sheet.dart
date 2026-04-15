import 'package:flutter/material.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/data/models/meal_plan.dart';
import 'package:fitcoach/data/services/home_provider.dart';
import 'package:provider/provider.dart';

void showMealDetailSheet(BuildContext context, Meal meal) {
  final provider = context.read<HomeProvider>();
  final plan = provider.planNutricion;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _MealDetailSheet(
      meal: meal,
      calObj: plan?.caloriasObjetivo ?? 2000,
      protObj: plan?.proteinasObjetivo ?? 150.0,
      carbObj: plan?.carbosObjetivo ?? 200.0,
      grasObj: plan?.grasasObjetivo ?? 65.0,
      onToggle: () => provider.toggleComidaCompletada(meal),
    ),
  );
}

Color _tipoColor(String tipo) {
  switch (tipo.toLowerCase()) {
    case 'desayuno':
      return AppColors.primary;
    case 'almuerzo':
      return AppColors.textSecondary;
    case 'cena':
      return const Color(0xFF378ADD);
    case 'snack':
      return const Color(0xFFD85A30);
    default:
      return AppColors.primary;
  }
}

class _MealDetailSheet extends StatefulWidget {
  final Meal meal;
  final int calObj;
  final double protObj;
  final double carbObj;
  final double grasObj;
  final VoidCallback onToggle;

  const _MealDetailSheet({
    required this.meal,
    required this.calObj,
    required this.protObj,
    required this.carbObj,
    required this.grasObj,
    required this.onToggle,
  });

  @override
  State<_MealDetailSheet> createState() => _MealDetailSheetState();
}

class _MealDetailSheetState extends State<_MealDetailSheet> {
  late bool _completada;

  @override
  void initState() {
    super.initState();
    _completada = widget.meal.completada;
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final color = _tipoColor(meal.tipo);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── HEADER ──────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            meal.tipo.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF0D0D0D),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          meal.nombre,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.backgroundElevated,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),

              // ── MACROS ──────────────────────────────────────────
              const SizedBox(height: 16),
              Row(
                children: [
                  _macroColumn(
                    label: 'Kcal',
                    value: '${meal.calorias}',
                    fraction: meal.calorias / widget.calObj,
                    barColor: AppColors.primary,
                    valueColor: AppColors.primary,
                  ),
                  _macroColumn(
                    label: 'Prot',
                    value: '${meal.proteinas.round()}g',
                    fraction: meal.proteinas / widget.protObj,
                    barColor: AppColors.primary,
                    valueColor: AppColors.textPrimary,
                  ),
                  _macroColumn(
                    label: 'Carbos',
                    value: '${meal.carbohidratos.round()}g',
                    fraction: meal.carbohidratos / widget.carbObj,
                    barColor: AppColors.textSecondary,
                    valueColor: AppColors.textPrimary,
                  ),
                  _macroColumn(
                    label: 'Grasas',
                    value: '${meal.grasas.round()}g',
                    fraction: meal.grasas / widget.grasObj,
                    barColor: const Color(0xFF444444),
                    valueColor: AppColors.textPrimary,
                  ),
                ],
              ),

              // ── INGREDIENTES ─────────────────────────────────────
              const SizedBox(height: 20),
              const Text(
                'INGREDIENTES',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              ...meal.ingredientes.map(
                (ing) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              ing,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                        color: AppColors.border, height: 1, thickness: 0.5),
                  ],
                ),
              ),

              // ── PREPARACIÓN ──────────────────────────────────────
              if (meal.preparacion.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'PREPARACIÓN',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  meal.preparacion,
                  style: const TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],

              // ── BOTÓN ────────────────────────────────────────────
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _completada = !_completada);
                    widget.onToggle();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _completada
                        ? AppColors.primary.withAlpha(48)
                        : AppColors.primary,
                    foregroundColor: _completada
                        ? AppColors.primary
                        : const Color(0xFF0D0D0D),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _completada ? 'Completada ✓' : 'Marcar como completada',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _macroColumn({
    required String label,
    required String value,
    required double fraction,
    required Color barColor,
    required Color valueColor,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (_, constraints) {
              return Container(
                height: 3,
                width: constraints.maxWidth * fraction.clamp(0.0, 1.0),
                color: barColor,
              );
            },
          ),
        ],
      ),
    );
  }
}
