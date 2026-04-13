import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/core/constants/app_constants.dart';
import 'package:fitcoach/data/services/home_provider.dart';
import 'package:fitcoach/data/models/workout_plan.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  // Colores por tipo
  static const Color _colorDeporte = Color(0xFF378ADD);
  static const Color _colorGimnasio = AppColors.primary;
  static const Color _colorDescanso = AppColors.border;

  static Color _colorForTipo(String tipo) {
    switch (tipo) {
      case 'deporte':
        return _colorDeporte;
      case 'gimnasio':
        return _colorGimnasio;
      default:
        return _colorDescanso;
    }
  }

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
              // Silueta deportiva
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.directions_run,
                  color: AppColors.textSecondary,
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tu plan está siendo preparado',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Genera tu primer plan de entrenamiento\npersonalizado con IA',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              if (provider.cargandoPlan)
                const Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 12),
                    Text(
                      'Generando plan con IA...',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () => provider.generarPlanEntrenamiento(),
                  child: const Text('Generar mi plan'),
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
    const diasNombre = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            // Nota de distribución
            if (i == plan.semana.length) {
              return _buildNotaDistribucion(plan.notaDistribucion);
            }
            // Botón regenerar
            if (i == plan.semana.length + 1) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: OutlinedButton(
                  onPressed: provider.cargandoPlan
                      ? null
                      : () => provider.generarPlanEntrenamiento(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text(
                    'Generar nuevo plan',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              );
            }

            final day = plan.semana[i];
            final esHoy = i == hoyIdx;
            return _WorkoutDayCard(
              diaNombre: diasNombre[i],
              workout: day,
              esHoy: esHoy,
              accentColor: _colorForTipo(day.tipo),
              onTap: day.esDescanso
                  ? null
                  : () => context.push(
                        AppConstants.routeSessionDetail,
                        extra: day,
                      ),
              onToggle: () =>
                  context.read<HomeProvider>().toggleEntrenamientoCompletado(),
            );
          },
          childCount: plan.semana.length + 2,
        ),
      ),
    );
  }

  Widget _buildNotaDistribucion(String nota) {
    if (nota.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'POR QUÉ ESTA DISTRIBUCIÓN',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  nota,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutDayCard extends StatelessWidget {
  final String diaNombre;
  final WorkoutDay workout;
  final bool esHoy;
  final Color accentColor;
  final VoidCallback? onTap;
  final VoidCallback onToggle;

  const _WorkoutDayCard({
    required this.diaNombre,
    required this.workout,
    required this.esHoy,
    required this.accentColor,
    this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: esHoy
              ? AppColors.primary.withAlpha(13)
              : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: esHoy
                ? AppColors.primary.withAlpha(60)
                : AppColors.border,
            width: 0.5,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Borde lateral de color
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  diaNombre,
                                  style: TextStyle(
                                    color: esHoy
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: accentColor.withAlpha(30),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _labelTipo(workout.tipo),
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Checkbox
                          GestureDetector(
                            onTap: workout.esDescanso ? null : onToggle,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: workout.completado
                                    ? AppColors.primary
                                    : AppColors.backgroundElevated,
                                shape: BoxShape.circle,
                                border: workout.completado
                                    ? null
                                    : Border.all(
                                        color: AppColors.border),
                              ),
                              child: workout.completado
                                  ? const Icon(Icons.check,
                                      color: AppColors.background,
                                      size: 13)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
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
                        if (workout.caracteristicas.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: workout.caracteristicas.map((c) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundElevated,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  c,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              if (!workout.esDescanso)
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Center(
                    child: Icon(Icons.chevron_right,
                        color: AppColors.textSecondary, size: 18),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _labelTipo(String tipo) {
    switch (tipo) {
      case 'gimnasio':
        return 'GIMNASIO';
      case 'deporte':
        return 'DEPORTE';
      default:
        return 'DESCANSO';
    }
  }
}
