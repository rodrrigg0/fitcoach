import 'dart:math' show min, max;

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/core/constants/app_constants.dart';
import 'package:fitcoach/data/models/user_profile.dart';
import 'package:fitcoach/data/models/weight_log.dart';
import 'package:fitcoach/data/services/home_provider.dart';
import 'package:fitcoach/presentation/auth/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<HomeProvider>().cargarPesos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final perfil = provider.perfil;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatarHeader(perfil, email),
                  if (perfil != null) ...[
                    _buildStatsRow(provider),
                    _buildPerfilSection(perfil),
                    _buildEstadisticasSection(provider),
                    _buildPesoSection(context, provider),
                  ],
                  _buildLogoutButton(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── AVATAR HEADER ─────────────────────────────────────────

  Widget _buildAvatarHeader(UserProfile? perfil, String email) {
    final nombre = perfil?.nombre ?? 'Usuario';
    final iniciales = nombre.isNotEmpty
        ? nombre.split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : 'U';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Center(
              child: Text(
                iniciales,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            nombre,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
          if (perfil != null && perfil.objetivo.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x20C8F135),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                perfil.objetivo,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── STATS ROW ─────────────────────────────────────────────

  Widget _buildStatsRow(HomeProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statCard(
              '${provider.rachaActual}',
              'Racha\nactual',
              Icons.local_fire_department,
              const Color(0xFFFF7043)),
          const SizedBox(width: 10),
          _statCard(
              '${provider.completadosPorDia.where((d) => d).length}',
              'Días esta\nsemana',
              Icons.fitness_center,
              AppColors.primary),
          const SizedBox(width: 10),
          _statCard(
              provider.perfil != null
                  ? '${_diasDesdeRegistro(provider.perfil!.fechaRegistro)}'
                  : '0',
              'Días en\nFitCoach',
              Icons.calendar_today,
              const Color(0xFF7E57C2)),
        ],
      ),
    );
  }

  Widget _statCard(
      String valor, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              valor,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── PERFIL SECTION ────────────────────────────────────────

  Widget _buildPerfilSection(UserProfile perfil) {
    final items = [
      (Icons.sports, 'Deporte',
          perfil.deportes.isEmpty ? '—' : perfil.deportes.join(', ')),
      (Icons.location_on_outlined, 'Lugar', perfil.lugarEntrenamiento),
      (Icons.calendar_today, 'Días/semana',
          '${perfil.diasEntrenamiento} días'),
      (Icons.timer_outlined, 'Duración sesión',
          '${perfil.minutosSesion} min'),
      (Icons.restaurant_menu, 'Dieta', perfil.tipoDieta),
      (Icons.bedtime_outlined, 'Sueño habitual',
          '${perfil.horasSueno} horas'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MI PERFIL',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: items.asMap().entries.map((e) {
                final isLast = e.key == items.length - 1;
                final item = e.value;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : const Border(
                            bottom: BorderSide(
                                color: AppColors.border, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(item.$1,
                          color: AppColors.textSecondary, size: 16),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.$2,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        item.$3,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── ESTADÍSTICAS ──────────────────────────────────────────

  Widget _buildEstadisticasSection(HomeProvider provider) {
    final perfil = provider.perfil;
    final racha = provider.rachaActual;
    final diasEntrenados =
        provider.completadosPorDia.where((d) => d).length;
    final fechaInicio = perfil?.fechaRegistro;
    final fechaStr = fechaInicio != null
        ? '${fechaInicio.day.toString().padLeft(2, '0')}/${fechaInicio.month.toString().padLeft(2, '0')}/${fechaInicio.year}'
        : '—';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ESTADÍSTICAS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _statsRow('Racha actual', '$racha días', false),
                _statsRow(
                    'Días entrenados esta semana',
                    '$diasEntrenados días',
                    false),
                _statsRow('Miembro desde', fechaStr, true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(String label, String valor, bool isLast) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom:
                    BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          Text(
            valor,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── SECCIÓN PESO ─────────────────────────────────────────

  Widget _buildPesoSection(
      BuildContext context, HomeProvider provider) {
    final registros = provider.registrosPeso;
    final cargando = provider.cargandoPesos;

    WeightLog? ultimo;
    WeightLog? primero;
    double? variacion;

    if (registros.isNotEmpty) {
      ultimo = registros.last;
      primero = registros.first;
      if (registros.length > 1) {
        variacion = ultimo.peso - primero.peso;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'EVOLUCIÓN DE PESO',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _mostrarRegistrarPeso(context, provider),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: AppColors.primary, size: 16),
                    SizedBox(width: 2),
                    Text(
                      'Registrar',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Gráfica
          if (cargando)
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2),
            )
          else
            _WeightChart(registros: registros),

          // Último registro + variación
          if (ultimo != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text(
                    'Peso actual',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${ultimo.peso.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (variacion != null) ...[
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${variacion < 0 ? '↓' : '↑'} ${variacion.abs().toStringAsFixed(1)} kg',
                          style: TextStyle(
                            color: variacion < 0
                                ? AppColors.primary
                                : AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          'vs inicio',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _mostrarRegistrarPeso(
      BuildContext context, HomeProvider provider) {
    final lastPeso = provider.registrosPeso.isNotEmpty
        ? provider.registrosPeso.last.peso
        : (provider.perfil?.peso ?? 70.0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _WeightRegModal(
        initialPeso: lastPeso,
        onSave: (peso, notas) async {
          Navigator.of(ctx).pop();
          await provider.registrarPeso(peso, notas);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Peso registrado')),
            );
          }
        },
      ),
    );
  }

  // ── LOGOUT ────────────────────────────────────────────────

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: OutlinedButton(
        onPressed: () async {
          final authProvider = context.read<AuthProvider>();
          await authProvider.logout();
          if (context.mounted) {
            context.go(AppConstants.routeLogin);
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error.withAlpha(100)),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text(
          'Cerrar sesión',
          style: TextStyle(
            color: AppColors.error,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────

  int _diasDesdeRegistro(DateTime fecha) {
    return DateTime.now().difference(fecha).inDays;
  }
}

// ─── Weight Chart ─────────────────────────────────────────────

class _WeightChart extends StatelessWidget {
  final List<WeightLog> registros;

  const _WeightChart({required this.registros});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.hardEdge,
      child: registros.length < 2
          ? const Center(
              child: Text(
                'Registra tu peso para ver tu evolución',
                style: TextStyle(
                  color: Color(0xFF444444),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : CustomPaint(
              painter: _WeightChartPainter(registros),
              size: const Size(double.infinity, 160),
              child: Container(),
            ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<WeightLog> registros;

  _WeightChartPainter(this.registros);

  @override
  void paint(Canvas canvas, Size size) {
    if (registros.length < 2) return;

    const double padLeft = 44.0;
    const double padRight = 12.0;
    const double padTop = 14.0;
    const double padBottom = 20.0;
    final chartW = size.width - padLeft - padRight;
    final chartH = size.height - padTop - padBottom;

    final pesos = registros.map((r) => r.peso).toList();
    final rawMin =
        pesos.fold(double.infinity, (m, p) => p < m ? p : m);
    final rawMax =
        pesos.fold(double.negativeInfinity, (m, p) => p > m ? p : m);
    final minP = rawMin - 1.0;
    final maxP = rawMax + 1.0;
    final range = maxP - minP;

    // Puntos
    final points = <Offset>[];
    for (int i = 0; i < registros.length; i++) {
      final x = padLeft + (i / (registros.length - 1)) * chartW;
      final y = padTop +
          chartH -
          ((registros[i].peso - minP) / range) * chartH;
      points.add(Offset(x, y));
    }

    // Líneas guía
    final guidePaint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 3; i++) {
      final y = padTop + (i / 2) * chartH;
      canvas.drawLine(
          Offset(padLeft, y), Offset(size.width - padRight, y), guidePaint);

      // Label
      final pesoVal = maxP - (i / 2) * range;
      final tp = TextPainter(
        text: TextSpan(
          text: pesoVal.toStringAsFixed(0),
          style: const TextStyle(
            color: Color(0xFF444444),
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - 6));
    }

    // Curva bezier (Catmull-Rom → cúbica)
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : points[i + 1];

      final cp1x = p1.dx + (p2.dx - p0.dx) / 6;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 6;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6;

      linePath.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    // Área rellena
    final fillPath = Path.from(linePath);
    fillPath.lineTo(points.last.dx, padTop + chartH);
    fillPath.lineTo(points.first.dx, padTop + chartH);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()..color = const Color(0x20C8F135),
    );

    // Línea
    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xFFC8F135)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Puntos
    final dotPaint = Paint()..color = const Color(0xFFC8F135);
    for (int i = 0; i < points.length; i++) {
      final isLast = i == points.length - 1;
      if (isLast) {
        canvas.drawCircle(points[i], 8,
            Paint()..color = Colors.white);
        canvas.drawCircle(points[i], 6, dotPaint);
      } else {
        canvas.drawCircle(points[i], 4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_WeightChartPainter old) =>
      old.registros != registros;
}

// ─── Weight Registration Modal ───────────────────────────────

class _WeightRegModal extends StatefulWidget {
  final double initialPeso;
  final Future<void> Function(double, String) onSave;

  const _WeightRegModal({
    required this.initialPeso,
    required this.onSave,
  });

  @override
  State<_WeightRegModal> createState() => _WeightRegModalState();
}

class _WeightRegModalState extends State<_WeightRegModal> {
  late double _peso;
  final _notasCtrl = TextEditingController();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _peso = (widget.initialPeso * 10).round() / 10;
  }

  @override
  void dispose() {
    _notasCtrl.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      final v = (_peso * 10).round() + 1;
      _peso = min(v / 10, 200.0);
    });
  }

  void _decrement() {
    setState(() {
      final v = (_peso * 10).round() - 1;
      _peso = max(v / 10, 30.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Registrar peso de hoy',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 28),
          // Selector de peso
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pickerButton(Icons.remove, _decrement),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _peso.toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'kg',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _pickerButton(Icons.add, _increment),
            ],
          ),
          const SizedBox(height: 20),
          // Notas
          TextField(
            controller: _notasCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: '¿Cómo te encuentras hoy? (opcional)',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _guardando
                  ? null
                  : () async {
                      setState(() => _guardando = true);
                      await widget.onSave(_peso, _notasCtrl.text);
                    },
              child: _guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.background,
                      ),
                    )
                  : const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pickerButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: AppColors.backgroundElevated,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 22),
      ),
    );
  }
}
