import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/core/constants/app_constants.dart';
import 'package:fitcoach/data/services/home_provider.dart';
import 'package:fitcoach/data/models/workout_plan.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

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
                if (provider.planEntrenamiento == null)
                  _buildEmptyState(context, provider)
                else
                  _buildPlanList(context, provider),
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
                'Entrenamiento',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (provider.planEntrenamiento != null)
              GestureDetector(
                onTap: provider.cargandoPlan
                    ? null
                    : () => provider.generarPlanEntrenamiento(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: provider.cargandoPlan
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
                  Icons.fitness_center,
                  color: AppColors.textSecondary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sin plan de entrenamiento',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Genera tu plan semanal personalizado con IA',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              if (provider.cargandoPlan)
                const CircularProgressIndicator(color: AppColors.primary)
              else
                ElevatedButton(
                  onPressed: () => provider.generarPlanEntrenamiento(),
                  child: const Text('Generar plan con IA'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanList(BuildContext context, HomeProvider provider) {
    final plan = provider.planEntrenamiento!;
    final hoyIdx = DateTime.now().weekday - 1;
    const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            if (i == plan.semana.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 20),
                child: Text(
                  plan.notaDistribucion,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              );
            }
            final day = plan.semana[i];
            final esHoy = i == hoyIdx;
            return _WorkoutDayCard(
              dia: dias[i],
              workout: day,
              esHoy: esHoy,
              onTap: day.esDescanso
                  ? null
                  : () => context.push(
                        AppConstants.routeSessionDetail,
                        extra: day,
                      ),
            );
          },
          childCount: plan.semana.length + 1,
        ),
      ),
    );
  }
}

class _WorkoutDayCard extends StatelessWidget {
  final String dia;
  final WorkoutDay workout;
  final bool esHoy;
  final VoidCallback? onTap;

  const _WorkoutDayCard({
    required this.dia,
    required this.workout,
    required this.esHoy,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: esHoy
              ? AppColors.primary.withAlpha(20)
              : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(14),
          border: esHoy
              ? Border.all(color: AppColors.primary.withAlpha(77))
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Column(
                children: [
                  Text(
                    dia,
                    style: TextStyle(
                      color: esHoy
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (esHoy)
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: workout.esDescanso
                    ? AppColors.backgroundElevated
                    : AppColors.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                workout.esDescanso
                    ? Icons.self_improvement
                    : _iconForTipo(workout.tipo),
                color: workout.esDescanso
                    ? AppColors.textSecondary
                    : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.titulo,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!workout.esDescanso) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${workout.duracion} min · ${workout.lugar}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (workout.completado)
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 20)
            else if (!workout.esDescanso)
              const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  IconData _iconForTipo(String tipo) {
    switch (tipo) {
      case 'gimnasio':
        return Icons.fitness_center;
      case 'deporte':
        return Icons.directions_run;
      default:
        return Icons.self_improvement;
    }
  }
}
