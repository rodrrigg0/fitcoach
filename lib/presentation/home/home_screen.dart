import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/core/constants/app_constants.dart';
import 'package:fitcoach/data/services/home_provider.dart';
import 'package:fitcoach/data/models/workout_plan.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int)? onTabChange;

  const HomeScreen({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (provider.cargando) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildHeader(provider),
                _buildHeroCard(context, provider),
                _buildMetricsGrid(context, provider),
                _buildWeeklyStreak(provider),
                _buildMacrosCard(provider),
                _buildChatAccess(context),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Header ─────────────────────────────────────────────────

  Widget _buildHeader(HomeProvider provider) {
    final nombre = provider.perfil?.nombre ?? '';
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.saludo,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nombre.isNotEmpty ? nombre : 'FitCoach',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => onTabChange?.call(3),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Hero entrenamiento ─────────────────────────────────────

  Widget _buildHeroCard(BuildContext context, HomeProvider provider) {
    final dia = provider.diaHoy;
    final esDescanso = dia.esDescanso;
    final cargando = provider.cargandoPlan;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: GestureDetector(
          onTap: esDescanso || cargando
              ? null
              : () => context.push(AppConstants.routeSessionDetail, extra: dia),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: cargando
                ? _heroLoading()
                : provider.planEntrenamiento == null
                    ? _heroEmpty(context, provider)
                    : _heroContent(dia, esDescanso),
          ),
        ),
      ),
    );
  }

  Widget _heroLoading() {
    return const SizedBox(
      height: 110,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
            SizedBox(height: 12),
            Text('Generando plan con IA...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _heroEmpty(BuildContext context, HomeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sin plan activo',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Genera tu plan de entrenamiento personalizado',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => provider.generarPlanEntrenamiento(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Generar plan',
              style: TextStyle(
                color: AppColors.background,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroContent(WorkoutDay dia, bool esDescanso) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: esDescanso
                    ? AppColors.backgroundElevated
                    : AppColors.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                esDescanso ? 'DESCANSO' : 'HOY',
                style: TextStyle(
                  color: esDescanso
                      ? AppColors.textSecondary
                      : AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
            if (dia.completado) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 16),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Text(
          dia.titulo,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          dia.descripcion,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (!esDescanso) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              _heroChip(Icons.timer_outlined, '${dia.duracion} min'),
              const SizedBox(width: 8),
              _heroChip(Icons.location_on_outlined, dia.lugar),
              if (dia.ejercicios.isNotEmpty) ...[
                const SizedBox(width: 8),
                _heroChip(Icons.fitness_center,
                    '${dia.ejercicios.length} ejerc.'),
              ],
              const Spacer(),
              const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary, size: 20),
            ],
          ),
        ],
      ],
    );
  }

  Widget _heroChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 13),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  // ─── Métricas 2×2 ───────────────────────────────────────────

  Widget _buildMetricsGrid(BuildContext context, HomeProvider provider) {
    final racha = provider.rachaActual;
    final cals = provider.planNutricion?.caloriasConsumidas ?? 0;
    final calObjetivo = provider.caloriasObjetivo;
    final sueno = provider.horasSueno;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _metricCard(
                    icon: Icons.local_fire_department,
                    color: const Color(0xFFFF7043),
                    label: 'Racha',
                    value: '$racha días',
                  ),
                  const SizedBox(height: 10),
                  _metricCard(
                    icon: Icons.bedtime_outlined,
                    color: const Color(0xFF7E57C2),
                    label: 'Sueño',
                    value: sueno > 0 ? '$sueno h' : '--',
                    onTap: () => _showSleepDialog(context, provider),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  _metricCard(
                    icon: Icons.restaurant,
                    color: const Color(0xFF66BB6A),
                    label: 'Calorías',
                    value: '$cals kcal',
                    subtitle: 'de $calObjetivo',
                    onTap: () => onTabChange?.call(2),
                  ),
                  const SizedBox(height: 10),
                  _metricCard(
                    icon: Icons.fitness_center,
                    color: AppColors.primary,
                    label: 'Plan',
                    value: provider.planEntrenamiento != null
                        ? 'Activo'
                        : 'Sin plan',
                    onTap: () => onTabChange?.call(1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSleepDialog(BuildContext context, HomeProvider provider) {
    int horas = provider.horasSueno > 0 ? provider.horasSueno : 7;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.backgroundCard,
          title: const Text('Registrar sueño',
              style: TextStyle(color: AppColors.textPrimary)),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (horas > 1) setState(() => horas--);
                },
                icon: const Icon(Icons.remove_circle_outline,
                    color: AppColors.textSecondary),
              ),
              Text(
                '$horas h',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: () {
                  if (horas < 12) setState(() => horas++);
                },
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.primary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                provider.registrarSueno(horas);
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Racha semanal ──────────────────────────────────────────

  Widget _buildWeeklyStreak(HomeProvider provider) {
    final completados = provider.completadosPorDia;
    const diasLabel = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final hoyIdx = DateTime.now().weekday - 1;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ESTA SEMANA',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (i) {
                  final done = completados[i];
                  final esHoy = i == hoyIdx;
                  return Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: done
                              ? AppColors.primary
                              : AppColors.backgroundElevated,
                          shape: BoxShape.circle,
                          border: esHoy && !done
                              ? Border.all(
                                  color: AppColors.primary, width: 1.5)
                              : null,
                        ),
                        child: done
                            ? const Icon(Icons.check,
                                color: AppColors.background, size: 16)
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        diasLabel[i],
                        style: TextStyle(
                          color: esHoy
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: esHoy
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Macros ─────────────────────────────────────────────────

  Widget _buildMacrosCard(HomeProvider provider) {
    final plan = provider.planNutricion;
    if (plan == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final consumidas = plan.caloriasConsumidas;
    final objetivo = plan.caloriasObjetivo;
    final progreso = objetivo > 0 ? consumidas / objetivo : 0.0;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                    'NUTRICIÓN HOY',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    '$consumidas / $objetivo kcal',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
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
            ],
          ),
        ),
      ),
    );
  }

  // ─── Chat access ────────────────────────────────────────────

  Widget _buildChatAccess(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: GestureDetector(
          onTap: () => onTabChange?.call(3),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.smart_toy_outlined,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pregunta a FitCoach AI',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Dudas sobre entrenamiento, nutrición...',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
