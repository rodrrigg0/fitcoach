import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/core/constants/app_constants.dart';
import 'package:fitcoach/data/services/home_provider.dart';
import 'package:fitcoach/shared/widgets/number_picker_wheel.dart';

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(context, provider),
                  const SizedBox(height: 20),
                  _buildHeroCard(context, provider),
                  const SizedBox(height: 16),
                  _buildMetricsGrid(context, provider),
                  const SizedBox(height: 16),
                  _buildRachaSemanal(provider),
                  const SizedBox(height: 16),
                  _buildMacros(provider),
                  const SizedBox(height: 16),
                  _buildChatAccess(context, provider),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── HEADER ────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, HomeProvider provider) {
    final nombre = provider.perfil?.nombre ?? '';
    final racha = provider.rachaActual;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Saludo izquierda
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.saludo,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Hola, $nombre',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        // Derecha: racha + avatar
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (racha > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x20C8F135),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🔥 $racha días',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Avatar — siempre a la derecha
            GestureDetector(
              onTap: () => context.push(AppConstants.routeProfile),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primary, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    _iniciales(nombre),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _iniciales(String nombre) {
    final partes = nombre.trim().split(' ');
    if (partes.length >= 2 && partes[0].isNotEmpty && partes[1].isNotEmpty) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    if (nombre.isEmpty) return 'U';
    return nombre.substring(0, nombre.length >= 2 ? 2 : 1).toUpperCase();
  }

  // ─── HERO CARD ─────────────────────────────────────────────

  Widget _buildHeroCard(BuildContext context, HomeProvider provider) {
    final cargando = provider.cargandoPlan;

    if (cargando) {
      return _heroCardShell(
        child: const SizedBox(
          height: 100,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2),
                SizedBox(height: 12),
                Text(
                  'Generando plan con IA...',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (provider.planEntrenamiento == null) {
      return _heroCardShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sin plan activo',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Genera tu plan de entrenamiento personalizado con IA',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.generarPlanEntrenamiento(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
              child: const Text('Generar mi plan'),
            ),
          ],
        ),
      );
    }

    final dia = provider.diaHoy;
    final esDescanso = dia.esDescanso;
    final categoria = _labelCategoria(dia.tipo);

    return _heroCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag HOY · CATEGORIA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: esDescanso
                  ? AppColors.backgroundElevated
                  : const Color(0x20C8F135),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'HOY · $categoria',
              style: TextStyle(
                color: esDescanso
                    ? AppColors.textSecondary
                    : AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            dia.titulo,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            esDescanso
                ? 'El descanso es parte del entrenamiento'
                : '${dia.duracion} min · ${dia.lugar}',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12),
          ),
          if (!esDescanso && dia.caracteristicas.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: dia.caracteristicas.asMap().entries.map((e) {
                final isFirst = e.key == 0;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isFirst
                        ? const Color(0x20C8F135)
                        : AppColors.backgroundElevated,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    e.value,
                    style: TextStyle(
                      color: isFirst
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (esDescanso) ...[
            const SizedBox(height: 10),
            Text(
              dia.porQueHoy,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (!esDescanso) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      const diasNombre = [
                        'Lunes', 'Martes', 'Miércoles', 'Jueves',
                        'Viernes', 'Sábado', 'Domingo',
                      ];
                      context.push(
                        AppConstants.routeSessionDetail,
                        extra: {
                          'workout': dia,
                          'diaNombre':
                              diasNombre[DateTime.now().weekday - 1],
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 42),
                    ),
                    child: const Text('Iniciar sesión'),
                  ),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: () => onTabChange?.call(1),
                  child: const Text(
                    'Ver plan completo',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _heroCardShell({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: child,
    );
  }

  String _labelCategoria(String tipo) {
    switch (tipo) {
      case 'gimnasio':
        return 'GIMNASIO';
      case 'deporte':
        return 'DEPORTE';
      default:
        return 'DESCANSO';
    }
  }

  // ─── MÉTRICAS 2x2 ─────────────────────────────────────────

  Widget _buildMetricsGrid(BuildContext context, HomeProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _metricCalorias(provider),
              const SizedBox(height: 8),
              _metricPeso(provider),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              _metricProximaComida(provider),
              const SizedBox(height: 8),
              _metricSueno(context, provider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: child,
    );
  }

  Widget _metricCalorias(HomeProvider provider) {
    final consumidas = provider.caloriasConsumidas;
    final objetivo = provider.caloriasObjetivo;
    final pct = provider.porcentajeCalorias;

    return _metricCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Calorías hoy',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 6),
          Text(
            '$consumidas kcal',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.backgroundElevated,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$consumidas de $objetivo kcal',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _metricProximaComida(HomeProvider provider) {
    final proxima = provider.proximaComida;
    final todasCompletadas = provider.comidasHoy.isNotEmpty &&
        provider.comidasHoy.every((m) => m.completada);

    return _metricCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Próxima comida',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 6),
          if (todasCompletadas)
            const Text(
              'Plan completado',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            )
          else if (proxima != null) ...[
            Text(
              proxima.hora,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${proxima.nombre} · ${proxima.calorias} kcal',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ] else
            const Text(
              'Sin plan',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 15),
            ),
        ],
      ),
    );
  }

  Widget _metricPeso(HomeProvider provider) {
    final peso = provider.perfil?.peso ?? 0.0;

    return _metricCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Peso actual',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 6),
          Text(
            '$peso kg',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'desde el perfil',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _metricSueno(BuildContext context, HomeProvider provider) {
    final registrado = provider.suenoRegistradoHoy;
    final horas = provider.horasSueno;

    return GestureDetector(
      onTap: registrado
          ? null
          : () => _showSuenoModal(context, provider),
      child: _metricCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              registrado ? 'Sueño anoche' : '¿Cuánto dormiste?',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 6),
            if (registrado) ...[
              Text(
                '$horas h',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: (horas / 8.0).clamp(0.0, 1.0),
                  backgroundColor: AppColors.backgroundElevated,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 3,
                ),
              ),
            ] else
              const Text(
                'Registrar',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSuenoModal(BuildContext context, HomeProvider provider) {
    int horasSeleccionadas = 7;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.backgroundElevated,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Horas de sueño',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 140,
                child: NumberPickerWheel(
                  minValue: 4,
                  maxValue: 12,
                  initialValue: horasSeleccionadas,
                  suffix: 'h',
                  onChanged: (v) => setModalState(() => horasSeleccionadas = v),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  provider.registrarSueno(horasSeleccionadas);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── RACHA SEMANAL ─────────────────────────────────────────

  Widget _buildRachaSemanal(HomeProvider provider) {
    final completados = provider.completadosPorDia;
    final hoyIdx = DateTime.now().weekday - 1;
    const letras = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    // Determinar qué días son descanso según el plan
    final plan = provider.planEntrenamiento;
    final esDescansoPerDia = List.generate(7, (i) {
      if (plan == null) return false;
      return plan.semana[i].esDescanso;
    });

    return Container(
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
            'SEMANA ACTUAL',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
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
              final esDescanso = esDescansoPerDia[i];
              final esFuturo = i > hoyIdx;

              Color fondoCirculo;
              Color? borderColor;
              Widget? iconoCirculo;

              if (done) {
                fondoCirculo = AppColors.primary;
                iconoCirculo = const Icon(Icons.check,
                    color: AppColors.background, size: 14);
              } else if (esHoy) {
                fondoCirculo = Colors.transparent;
                borderColor = AppColors.primary;
              } else if (esDescanso) {
                fondoCirculo = AppColors.backgroundCard;
                borderColor = AppColors.border;
              } else if (esFuturo) {
                fondoCirculo = AppColors.backgroundElevated;
              } else {
                fondoCirculo = AppColors.backgroundElevated;
              }

              return Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: fondoCirculo,
                      shape: BoxShape.circle,
                      border: borderColor != null
                          ? Border.all(color: borderColor, width: 1.5)
                          : null,
                    ),
                    child: iconoCirculo != null
                        ? Center(child: iconoCirculo)
                        : null,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    letras[i],
                    style: TextStyle(
                      color: esHoy
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 10,
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
    );
  }

  // ─── MACROS DEL DÍA ────────────────────────────────────────

  Widget _buildMacros(HomeProvider provider) {
    final plan = provider.planNutricion;
    if (plan == null) return const SizedBox.shrink();

    final comidasHechas =
        plan.comidas.where((m) => m.completada).toList();
    final protConsumidas =
        comidasHechas.fold(0.0, (s, m) => s + m.proteinas);
    final carbConsumidos =
        comidasHechas.fold(0.0, (s, m) => s + m.carbohidratos);
    final grasConsumidas =
        comidasHechas.fold(0.0, (s, m) => s + m.grasas);

    final consumed = provider.caloriasConsumidas;
    final objetivo = plan.caloriasObjetivo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'MACROS DE HOY',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                '$consumed / $objetivo kcal',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _macroColumn(
                label: 'Proteína',
                valor: '${protConsumidas.round()}g',
                progreso: plan.proteinasObjetivo > 0
                    ? (protConsumidas / plan.proteinasObjetivo)
                        .clamp(0.0, 1.0)
                    : 0.0,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              _macroColumn(
                label: 'Carbos',
                valor: '${carbConsumidos.round()}g',
                progreso: plan.carbosObjetivo > 0
                    ? (carbConsumidos / plan.carbosObjetivo)
                        .clamp(0.0, 1.0)
                    : 0.0,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              _macroColumn(
                label: 'Grasas',
                valor: '${grasConsumidas.round()}g',
                progreso: plan.grasasObjetivo > 0
                    ? (grasConsumidas / plan.grasasObjetivo)
                        .clamp(0.0, 1.0)
                    : 0.0,
                color: const Color(0xFF444444),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroColumn({
    required String label,
    required String valor,
    required double progreso,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valor,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progreso,
              backgroundColor: AppColors.backgroundElevated,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ─── ACCESO RÁPIDO CHAT ─────────────────────────────────────

  Widget _buildChatAccess(BuildContext context, HomeProvider provider) {
    final dia = provider.planEntrenamiento != null ? provider.diaHoy : null;
    final String pregunta;

    if (dia == null) {
      pregunta = '¿Tienes alguna duda sobre tu plan?';
    } else if (dia.esDescanso) {
      pregunta = '¿Cómo te has recuperado hoy?';
    } else {
      final deporte = provider.perfil?.deportes.isNotEmpty == true
          ? provider.perfil!.deportes.first
          : dia.tipo;
      pregunta = '¿Listo para tu sesión de $deporte?';
    }

    return GestureDetector(
      onTap: () => onTabChange?.call(3),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x30C8F135), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: const Center(
                child: Text(
                  'FC',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Entrenador FitCoach',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    pregunta,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}
