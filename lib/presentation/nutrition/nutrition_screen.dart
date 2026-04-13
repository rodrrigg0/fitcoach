import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/data/services/home_provider.dart';
import 'package:fitcoach/data/models/meal_plan.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildHeader(context, provider),
                if (provider.planNutricion == null)
                  _buildEmptyState(context, provider)
                else ...[
                  _buildMacrosSummary(provider),
                  _buildMealList(provider),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, HomeProvider provider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Nutrición',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (provider.planNutricion != null)
              GestureDetector(
                onTap: provider.cargandoNutricion
                    ? null
                    : () => provider.generarPlanNutricion(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: provider.cargandoNutricion
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh,
                                color: AppColors.textSecondary, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Regenerar',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, HomeProvider provider) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: AppColors.textSecondary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sin plan nutricional',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Genera tu plan de alimentación personalizado con IA',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              if (provider.cargandoNutricion)
                const CircularProgressIndicator(color: AppColors.primary)
              else
                ElevatedButton(
                  onPressed: () => provider.generarPlanNutricion(),
                  child: const Text('Generar plan nutricional'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacrosSummary(HomeProvider provider) {
    final plan = provider.planNutricion!;
    final consumidas = plan.caloriasConsumidas;
    final objetivo = plan.caloriasObjetivo;
    final progreso = objetivo > 0 ? consumidas / objetivo : 0.0;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Calorías hoy',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '$consumidas / $objetivo kcal',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progreso.clamp(0.0, 1.0),
                  backgroundColor: AppColors.backgroundElevated,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _macroItem(
                      'Proteínas',
                      '${plan.proteinasConsumidas.round()}g',
                      '${plan.proteinasObjetivo.round()}g',
                      const Color(0xFF4FC3F7)),
                  const SizedBox(width: 12),
                  _macroItem(
                      'Carbos',
                      '${(plan.comidas.where((m) => m.completada).fold(0.0, (s, m) => s + m.carbohidratos)).round()}g',
                      '${plan.carbosObjetivo.round()}g',
                      const Color(0xFFFFB74D)),
                  const SizedBox(width: 12),
                  _macroItem(
                      'Grasas',
                      '${(plan.comidas.where((m) => m.completada).fold(0.0, (s, m) => s + m.grasas)).round()}g',
                      '${plan.grasasObjetivo.round()}g',
                      const Color(0xFFEF9A9A)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _macroItem(
      String label, String actual, String objetivo, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              actual,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w700,
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
            Text(
              'de $objetivo',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealList(HomeProvider provider) {
    final comidas = provider.comidasHoy;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            if (i == comidas.length) {
              return _buildTotalesCard(provider);
            }
            final meal = comidas[i];
            return _MealCard(
              meal: meal,
              onToggle: () =>
                  context.read<HomeProvider>().toggleComidaCompletada(meal),
            );
          },
          childCount: comidas.length + 1,
        ),
      ),
    );
  }

  Widget _buildTotalesCard(HomeProvider provider) {
    final plan = provider.planNutricion!;
    final completadas = plan.comidas.where((m) => m.completada).toList();
    final protTotal = completadas.fold(0.0, (s, m) => s + m.proteinas);
    final carbTotal = completadas.fold(0.0, (s, m) => s + m.carbohidratos);
    final grasTotal = completadas.fold(0.0, (s, m) => s + m.grasas);

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOTALES DEL DÍA',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _totalMacro('Proteínas', '${protTotal.round()}g',
                  plan.proteinasObjetivo, const Color(0xFF4FC3F7)),
              const SizedBox(width: 10),
              _totalMacro('Carbos', '${carbTotal.round()}g',
                  plan.carbosObjetivo, const Color(0xFFFFB74D)),
              const SizedBox(width: 10),
              _totalMacro('Grasas', '${grasTotal.round()}g',
                  plan.grasasObjetivo, const Color(0xFFEF9A9A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalMacro(
      String label, String valor, double objetivo, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valor,
            style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: objetivo > 0
                  ? (double.tryParse(valor.replaceAll('g', '')) ?? 0) /
                      objetivo
                  : 0.0,
              backgroundColor: AppColors.backgroundElevated,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
          Text('de ${objetivo.round()}g',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onToggle;

  const _MealCard({required this.meal, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: meal.completada
            ? AppColors.primary.withAlpha(15)
            : AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: meal.completada
            ? Border.all(color: AppColors.primary.withAlpha(51))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: meal.completada
                    ? AppColors.primary
                    : AppColors.backgroundElevated,
                shape: BoxShape.circle,
              ),
              child: meal.completada
                  ? const Icon(Icons.check,
                      color: AppColors.background, size: 14)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meal.nombre,
                        style: TextStyle(
                          color: meal.completada
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: meal.completada
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    Text(
                      '${meal.calorias} kcal',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${meal.hora} · ${_capitalize(meal.tipo)} · P:${meal.proteinas.round()}g C:${meal.carbohidratos.round()}g G:${meal.grasas.round()}g',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
