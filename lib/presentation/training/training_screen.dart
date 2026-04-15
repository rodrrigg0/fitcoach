import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/core/constants/app_constants.dart';
import 'package:fitcoach/data/services/home_provider.dart';
import 'package:fitcoach/data/services/training_provider.dart';
import 'package:fitcoach/data/models/workout_plan.dart';
import 'package:fitcoach/data/models/exercise_log.dart';
import 'package:fitcoach/l10n/app_localizations.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, provider),
                  if (provider.planEntrenamiento == null)
                    _buildEmptyState(context, provider)
                  else
                    _buildPlanContent(context, provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, HomeProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.trainingTitle,
              style: const TextStyle(
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
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.refresh,
                              color: AppColors.textSecondary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            AppLocalizations.of(context)!.trainingRegenerate,
                            style: const TextStyle(
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
    );
  }

  Widget _buildEmptyState(BuildContext context, HomeProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 60, 32, 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          Text(
            AppLocalizations.of(context)!.trainingEmptyTitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.trainingEmptyDesc,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          if (provider.cargandoPlan)
            Column(
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.homeGeneratingAI,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            )
          else
            ElevatedButton(
              onPressed: () => provider.generarPlanEntrenamiento(),
              child: Text(AppLocalizations.of(context)!.trainingGeneratePlan),
            ),
        ],
      ),
    );
  }

  Widget _buildPlanContent(BuildContext context, HomeProvider provider) {
    final plan = provider.planEntrenamiento!;
    final hoyIdx = DateTime.now().weekday - 1;
    final l10n = AppLocalizations.of(context)!;
    final diasNombre = [
      l10n.nutritionDayMon, l10n.nutritionDayTue, l10n.nutritionDayWed,
      l10n.nutritionDayThu, l10n.nutritionDayFri, l10n.nutritionDaySat,
      l10n.nutritionDaySun,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ...plan.semana.asMap().entries.map((e) {
            final i = e.key;
            final day = e.value;
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
                        extra: {
                          'workout': day,
                          'diaNombre': diasNombre[i],
                        },
                      ),
              onToggle: () =>
                  context.read<HomeProvider>().toggleEntrenamientoCompletado(),
            );
          }),
          _buildNotaDistribucion(context, plan.notaDistribucion),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: OutlinedButton(
              onPressed: provider.cargandoPlan
                  ? null
                  : () => provider.generarPlanEntrenamiento(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                AppLocalizations.of(context)!.trainingNewPlan,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
          Consumer<TrainingProvider>(
            builder: (context, trainingProvider, _) =>
                _buildHistorial(context, trainingProvider),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHistorial(
      BuildContext context, TrainingProvider trainingProvider) {
    final sesiones = trainingProvider.historialSesiones;
    if (sesiones.isEmpty) return const SizedBox.shrink();

    const maxVisibles = 5;
    final mostrar = sesiones.take(maxVisibles).toList();
    final hayMas = sesiones.length > maxVisibles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            AppLocalizations.of(context)!.trainingPreviousSessions,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        ...mostrar.map((sesion) => GestureDetector(
              onTap: () => _showSessionDetail(context, sesion),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sesion.tituloEntrenamiento,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatFechaHistorial(sesion.fecha),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.trainingExercises(sesion.ejercicios.length),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        if (sesion.volumenTotal > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Vol: ${_formatVolumen(sesion.volumenTotal)} kg',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            )),
        if (hayMas)
          TextButton(
            onPressed: () =>
                _showAllSessions(context, trainingProvider.historialSesiones),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              AppLocalizations.of(context)!.trainingViewHistory,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  void _showSessionDetail(BuildContext context, WorkoutLog sesion) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sesion.tituloEntrenamiento,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatFechaHistorial(sesion.fecha),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (sesion.volumenTotal > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(32),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Vol: ${_formatVolumen(sesion.volumenTotal)} kg',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: sesion.ejercicios.length,
                itemBuilder: (_, i) {
                  final ej = sesion.ejercicios[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.border, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ej.ejercicioNombre,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (ej.series.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: ej.series
                                .map((s) => Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3),
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.backgroundElevated,
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${s.numero}×${s.repeticiones} ${_formatPesoStatic(s.peso)}kg',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ] else
                          Text(
                            AppLocalizations.of(context)!.trainingNoSeries,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAllSessions(
      BuildContext context, List<WorkoutLog> sesiones) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                AppLocalizations.of(context)!.trainingFullHistory,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: sesiones.length,
                itemBuilder: (ctx, i) {
                  final sesion = sesiones[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _showSessionDetail(context, sesion);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.border, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sesion.tituloEntrenamiento,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _formatFechaHistorial(sesion.fecha),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.textSecondary, size: 18),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatFechaHistorial(DateTime fecha) {
    const diasSemana = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves',
      'Viernes', 'Sábado', 'Domingo',
    ];
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre',
      'diciembre',
    ];
    final dia = diasSemana[fecha.weekday - 1];
    return '$dia ${fecha.day} de ${meses[fecha.month - 1]}';
  }

  String _formatVolumen(double v) {
    if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(1).replaceAll('.', ',')}k';
    }
    return v.toInt().toString();
  }

  static String _formatPesoStatic(double p) =>
      p == p.truncateToDouble()
          ? p.toInt().toString()
          : p.toStringAsFixed(1);

  Widget _buildNotaDistribucion(BuildContext context, String nota) {
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
                Text(
                  AppLocalizations.of(context)!.trainingWhyTitle,
                  style: const TextStyle(
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
                                    _labelTipo(context, workout.tipo),
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
                                    : Border.all(color: AppColors.border),
                              ),
                              child: workout.completado
                                  ? const Icon(Icons.check,
                                      color: AppColors.background, size: 13)
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

  String _labelTipo(BuildContext context, String tipo) {
    final l10n = AppLocalizations.of(context)!;
    switch (tipo) {
      case 'gimnasio':
        return l10n.trainingTypeGym;
      case 'deporte':
        return l10n.trainingTypeSport;
      default:
        return l10n.trainingTypeRest;
    }
  }
}
