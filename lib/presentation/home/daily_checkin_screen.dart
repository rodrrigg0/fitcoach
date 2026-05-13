import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/data/models/daily_checkin.dart';
import 'package:fitcoach/data/services/daily_checkin_provider.dart';

void mostrarCheckinDiario(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _DailyCheckinSheet(),
  );
}

Color _colorPorValor(int? v) {
  if (v == null) return const Color(0xFF888888);
  if (v <= 3) return const Color(0xFFFF4444);
  if (v <= 6) return const Color(0xFFFF8800);
  return const Color(0xFFC8F135);
}

// ─── Sheet principal ──────────────────────────────────────────

class _DailyCheckinSheet extends StatefulWidget {
  const _DailyCheckinSheet();

  @override
  State<_DailyCheckinSheet> createState() => _DailyCheckinSheetState();
}

class _DailyCheckinSheetState extends State<_DailyCheckinSheet> {
  // Entreno
  double _energia = 5;
  double _rendimiento = 5;
  double _dolor = 0;
  bool _completoEjercicios = true;
  bool _completoDesayuno = false;
  bool _completoAlmuerzo = false;
  bool _completoCena = false;
  bool _completoSnacks = false;
  int _vasos = 8;
  double _sueno = 7;
  int _calidadSueno = 3;

  // Descanso
  double _recuperacion = 5;

  final _ejerciciosModCtrl = TextEditingController();
  final _notasEntrenoCtrl = TextEditingController();
  final _preguntaCtrl = TextEditingController();
  final _dudasCtrl = TextEditingController();

  @override
  void dispose() {
    _ejerciciosModCtrl.dispose();
    _notasEntrenoCtrl.dispose();
    _preguntaCtrl.dispose();
    _dudasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      expand: false,
      builder: (_, scrollCtrl) {
        return Consumer<DailyCheckinProvider>(
          builder: (ctx, provider, _) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0D0D0D),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _buildHandle(),
                  _buildHeader(provider),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollCtrl,
                      child: provider.checkinCompletado
                          ? _buildRespuesta(ctx, provider)
                          : _buildFormulario(ctx, provider),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Handle ─────────────────────────────────────────────────

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 4),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────

  Widget _buildHeader(DailyCheckinProvider provider) {
    final now = DateTime.now();
    final fechaStr = DateFormat("EEEE d 'de' MMMM", 'es').format(now);
    final esDia = provider.esDiaEntreno;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Entrenador FitCoach',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fechaStr,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: esDia
                  ? const Color(0xFFC8F135).withAlpha(20)
                  : const Color(0xFF2A2A2A),
              border: Border.all(
                color: esDia
                    ? const Color(0xFFC8F135).withAlpha(40)
                    : Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              esDia ? 'Día de entreno' : 'Descanso',
              style: TextStyle(
                color: esDia
                    ? const Color(0xFFC8F135)
                    : const Color(0xFF888888),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Formulario ─────────────────────────────────────────────

  Widget _buildFormulario(BuildContext ctx, DailyCheckinProvider provider) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(ctx).viewInsets.bottom +
            MediaQuery.of(ctx).padding.bottom +
            24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.esDiaEntreno)
            ..._formularioEntreno()
          else
            ..._formularioDescanso(),
          const SizedBox(height: 20),
          _buildBotonEnviar(ctx, provider),
        ],
      ),
    );
  }

  List<Widget> _formularioEntreno() {
    return [
      _seccionLabel('¿CÓMO FUE EL ENTRENAMIENTO?'),
      const SizedBox(height: 12),
      _SliderCheckin(
        label: 'Nivel de energía',
        value: _energia,
        min: 1,
        max: 10,
        divisions: 9,
        color: _colorPorValor(_energia.round()),
        labelMin: 'Sin energía',
        labelMid: 'Normal',
        labelMax: 'Explosivo',
        onChanged: (v) => setState(() => _energia = v),
      ),
      _SliderCheckin(
        label: 'Rendimiento general',
        value: _rendimiento,
        min: 1,
        max: 10,
        divisions: 9,
        color: _colorPorValor(_rendimiento.round()),
        labelMin: 'Pésimo',
        labelMid: 'Normal',
        labelMax: 'Excelente',
        onChanged: (v) => setState(() => _rendimiento = v),
      ),
      _SliderCheckin(
        label: 'Dolor o molestias',
        value: _dolor,
        min: 0,
        max: 10,
        divisions: 10,
        color: _dolor > 5
            ? const Color(0xFFFF4444)
            : const Color(0xFFC8F135),
        labelMin: 'Sin dolor',
        labelMid: 'Moderado',
        labelMax: 'Intenso',
        onChanged: (v) => setState(() => _dolor = v),
      ),
      const Text(
        '¿Completaste todos los ejercicios?',
        style: TextStyle(color: Color(0xFF888888), fontSize: 13),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          _OpcionToggle(
            label: 'Sí',
            selected: _completoEjercicios,
            onTap: () => setState(() => _completoEjercicios = true),
          ),
          const SizedBox(width: 10),
          _OpcionToggle(
            label: 'No, algunos cambié',
            selected: !_completoEjercicios,
            onTap: () => setState(() => _completoEjercicios = false),
          ),
        ],
      ),
      AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: !_completoEjercicios
            ? Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _textField(
                  controller: _ejerciciosModCtrl,
                  hint: '¿Qué ejercicios modificaste y por qué?',
                  maxLines: 3,
                ),
              )
            : const SizedBox.shrink(),
      ),
      const SizedBox(height: 12),
      _textField(
        controller: _notasEntrenoCtrl,
        hint: 'Notas del entrenamiento (opcional)...',
        maxLines: 3,
      ),
      const SizedBox(height: 24),
      _seccionLabel('NUTRICIÓN Y DESCANSO'),
      const SizedBox(height: 12),
      const Text(
        'Comidas de hoy',
        style: TextStyle(color: Color(0xFF888888), fontSize: 13),
      ),
      const SizedBox(height: 8),
      _CheckItem(
        label: 'Desayuno',
        value: _completoDesayuno,
        onChanged: (v) => setState(() => _completoDesayuno = v),
      ),
      _CheckItem(
        label: 'Almuerzo',
        value: _completoAlmuerzo,
        onChanged: (v) => setState(() => _completoAlmuerzo = v),
      ),
      _CheckItem(
        label: 'Cena',
        value: _completoCena,
        onChanged: (v) => setState(() => _completoCena = v),
      ),
      _CheckItem(
        label: 'Snacks',
        value: _completoSnacks,
        onChanged: (v) => setState(() => _completoSnacks = v),
      ),
      const SizedBox(height: 16),
      const Text(
        'Vasos de agua (250ml)',
        style: TextStyle(color: Color(0xFF888888), fontSize: 13),
      ),
      const SizedBox(height: 8),
      _buildContadorVasos(),
      const SizedBox(height: 16),
      _SliderCheckin(
        label: 'Horas de sueño',
        value: _sueno,
        min: 3,
        max: 12,
        divisions: 18,
        suffix: 'h',
        color: _sueno < 6
            ? const Color(0xFFFF4444)
            : const Color(0xFFC8F135),
        labelMin: 'Poco',
        labelMid: 'Óptimo',
        labelMax: 'Mucho',
        onChanged: (v) => setState(() => _sueno = v),
      ),
      const Text(
        'Calidad del sueño',
        style: TextStyle(color: Color(0xFF888888), fontSize: 13),
      ),
      const SizedBox(height: 8),
      _buildEstrellasSueno(),
      const SizedBox(height: 24),
      _seccionLabel('PREGUNTA A TU ENTRENADOR'),
      const SizedBox(height: 4),
      const Text(
        '¿Tienes alguna duda o quieres comentar algo?',
        style: TextStyle(color: Color(0xFF888888), fontSize: 13),
      ),
      const SizedBox(height: 10),
      _textField(
        controller: _preguntaCtrl,
        hint:
            'Ej: ¿Debería aumentar el peso en sentadilla?\nMe noto más cansado de lo normal...',
        maxLines: 4,
      ),
    ];
  }

  List<Widget> _formularioDescanso() {
    return [
      _seccionLabel('¿CÓMO VA TU RECUPERACIÓN?'),
      const SizedBox(height: 12),
      _SliderCheckin(
        label: 'Nivel de recuperación',
        value: _recuperacion,
        min: 1,
        max: 10,
        divisions: 9,
        color: _colorPorValor(_recuperacion.round()),
        labelMin: 'Sin recuperar',
        labelMid: 'Normal',
        labelMax: 'Perfecto',
        onChanged: (v) => setState(() => _recuperacion = v),
      ),
      _SliderCheckin(
        label: 'Horas de sueño',
        value: _sueno,
        min: 3,
        max: 12,
        divisions: 18,
        suffix: 'h',
        color: _sueno < 6
            ? const Color(0xFFFF4444)
            : const Color(0xFFC8F135),
        labelMin: 'Poco',
        labelMid: 'Óptimo',
        labelMax: 'Mucho',
        onChanged: (v) => setState(() => _sueno = v),
      ),
      const Text(
        'Calidad del sueño',
        style: TextStyle(color: Color(0xFF888888), fontSize: 13),
      ),
      const SizedBox(height: 8),
      _buildEstrellasSueno(),
      const SizedBox(height: 24),
      _seccionLabel('PREGUNTA O COMENTARIO'),
      const SizedBox(height: 4),
      const Text(
        '¿Cómo te sientes? ¿Tienes alguna duda sobre tu plan?',
        style: TextStyle(color: Color(0xFF888888), fontSize: 13),
      ),
      const SizedBox(height: 10),
      _textField(
        controller: _dudasCtrl,
        hint:
            '¿Cómo te encuentras? ¿Tienes alguna duda sobre tu plan o tu progreso?',
        maxLines: 4,
      ),
    ];
  }

  Widget _buildContadorVasos() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (_vasos > 0) setState(() => _vasos--);
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.remove, color: Color(0xFF888888), size: 18),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '$_vasos vasos',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => setState(() => _vasos++),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Color(0xFF888888), size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildEstrellasSueno() {
    return Row(
      children: List.generate(5, (i) {
        final activo = i < _calidadSueno;
        return GestureDetector(
          onTap: () => setState(() => _calidadSueno = i + 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: activo
                  ? const Color(0xFFC8F135)
                  : const Color(0xFF2A2A2A),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  color: activo
                      ? const Color(0xFF0D0D0D)
                      : const Color(0xFF888888),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBotonEnviar(
      BuildContext ctx, DailyCheckinProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: provider.enviandoRespuesta
            ? null
            : () => _enviar(ctx, provider),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC8F135),
          foregroundColor: const Color(0xFF0D0D0D),
          disabledBackgroundColor: const Color(0xFF2A2A2A),
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: provider.enviandoRespuesta
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF888888),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Tu entrenador está analizando...',
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                provider.esDiaEntreno
                    ? 'Enviar al entrenador →'
                    : 'Hablar con mi entrenador →',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  void _enviar(BuildContext ctx, DailyCheckinProvider provider) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final ahora = DateTime.now();
    final id = DateFormat('yyyy-MM-dd').format(ahora);
    final diaSemana = _nombreDiaSemana(ahora.weekday);
    final esDia = provider.esDiaEntreno;

    final checkin = DailyCheckin(
      id: id,
      uid: uid,
      fecha: ahora,
      diaSemana: diaSemana,
      esDiaEntreno: esDia,
      nivelEnergia: esDia ? _energia.round() : null,
      nivelRendimiento: esDia ? _rendimiento.round() : null,
      nivelDolor: esDia ? _dolor.round() : null,
      completoTodosEjercicios: esDia ? _completoEjercicios : null,
      ejerciciosModificados: esDia && !_completoEjercicios
          ? _ejerciciosModCtrl.text.trim()
          : null,
      notasEntreno:
          esDia && _notasEntrenoCtrl.text.trim().isNotEmpty
              ? _notasEntrenoCtrl.text.trim()
              : null,
      completoDesayuno: esDia ? _completoDesayuno : null,
      completoAlmuerzo: esDia ? _completoAlmuerzo : null,
      completoCena: esDia ? _completoCena : null,
      completoSnacks: esDia ? _completoSnacks : null,
      vasosDe250ml: esDia ? _vasos : null,
      horasSueno: _sueno,
      calidadSueno: _calidadSueno,
      nivelRecuperacion: !esDia ? _recuperacion.round() : null,
      dudas: !esDia && _dudasCtrl.text.trim().isNotEmpty
          ? _dudasCtrl.text.trim()
          : null,
      preguntaEntrenador:
          esDia && _preguntaCtrl.text.trim().isNotEmpty
              ? _preguntaCtrl.text.trim()
              : (!esDia && _dudasCtrl.text.trim().isNotEmpty
                  ? _dudasCtrl.text.trim()
                  : null),
    );

    provider.guardarCheckinYPedirRespuesta(checkin);
  }

  // ── Respuesta del entrenador ────────────────────────────────

  Widget _buildRespuesta(BuildContext ctx, DailyCheckinProvider provider) {
    final checkin = provider.checkinHoy;

    if (checkin?.respuestaEntrenador == null) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: const [
            CircularProgressIndicator(
              color: Color(0xFFC8F135),
              strokeWidth: 2,
            ),
            SizedBox(height: 16),
            Text(
              'Tu entrenador está analizando tu día...',
              style: TextStyle(color: Color(0xFF888888), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final respuesta = checkin!.respuestaEntrenador!;
    final horaStr = checkin.fechaRespuesta != null
        ? '${checkin.fechaRespuesta!.hour.toString().padLeft(2, '0')}:${checkin.fechaRespuesta!.minute.toString().padLeft(2, '0')}'
        : '';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.of(ctx).padding.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de respuesta
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFC8F135).withAlpha(40),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D0D),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFC8F135), width: 2),
                      ),
                      child: const Icon(
                        Icons.sports_gymnastics,
                        color: Color(0xFFC8F135),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Entrenador FitCoach',
                          style: TextStyle(
                            color: Color(0xFFC8F135),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (horaStr.isNotEmpty)
                          Text(
                            horaStr,
                            style: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextoFormateado(respuesta),
              ],
            ),
          ),

          // Informe semanal si es domingo y existe
          if (provider.esFinDeSemana &&
              provider.informesSemanales.isNotEmpty &&
              provider.informesSemanales.first.informeIA != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFC8F135),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bar_chart,
                          color: Color(0xFFC8F135), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'INFORME SEMANAL',
                        style: TextStyle(
                          color: Color(0xFFC8F135),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextoFormateado(
                      provider.informesSemanales.first.informeIA!),
                ],
              ),
            ),
          ],

          // Pills resumen
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (checkin.nivelEnergia != null)
                _PillResumen(
                  icon: Icons.bolt,
                  label: 'Energía ${checkin.nivelEnergia}/10',
                  color: _colorPorValor(checkin.nivelEnergia),
                ),
              if (checkin.nivelRendimiento != null)
                _PillResumen(
                  icon: Icons.fitness_center,
                  label: 'Rendimiento ${checkin.nivelRendimiento}/10',
                  color: _colorPorValor(checkin.nivelRendimiento),
                ),
              if (checkin.nivelRecuperacion != null)
                _PillResumen(
                  icon: Icons.self_improvement,
                  label: 'Recuperación ${checkin.nivelRecuperacion}/10',
                  color: _colorPorValor(checkin.nivelRecuperacion),
                ),
              if (checkin.horasSueno != null)
                _PillResumen(
                  icon: Icons.bedtime,
                  label:
                      '${checkin.horasSueno!.toStringAsFixed(1)}h sueño',
                  color: checkin.horasSueno! >= 7
                      ? const Color(0xFFC8F135)
                      : const Color(0xFFFF8800),
                ),
            ],
          ),

          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Ver historial en perfil →',
              style: TextStyle(
                color: Color(0xFFC8F135),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  Widget _seccionLabel(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        texto,
        style: const TextStyle(
          color: Color(0xFFC8F135),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF444444), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderSide:
              const BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: Color(0xFFC8F135), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.all(14),
      ),
    );
  }

  Widget _buildTextoFormateado(String texto) {
    final lines = texto.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) return const SizedBox(height: 6);

        if (trimmed.startsWith('- ') || trimmed.startsWith('• ')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 7, right: 8),
                  child: CircleAvatar(
                    radius: 2.5,
                    backgroundColor: Color(0xFF888888),
                  ),
                ),
                Expanded(child: _richText(trimmed.substring(2))),
              ],
            ),
          );
        }

        final isHeader =
            trimmed.endsWith(':') || trimmed == trimmed.toUpperCase();
        if (isHeader && trimmed.length < 60) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 2),
            child: Text(
              trimmed,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _richText(trimmed),
        );
      }).toList(),
    );
  }

  Widget _richText(String text) {
    final pattern = RegExp(r'\*\*(.+?)\*\*');
    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFFCCCCCC),
          fontSize: 14,
          height: 1.6,
        ),
        children: spans,
      ),
    );
  }

  String _nombreDiaSemana(int weekday) {
    const dias = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves',
      'Viernes', 'Sábado', 'Domingo',
    ];
    return dias[weekday - 1];
  }
}

// ─── Widgets helper ───────────────────────────────────────────

class _SliderCheckin extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color color;
  final String labelMin;
  final String labelMid;
  final String labelMax;
  final String? suffix;
  final ValueChanged<double> onChanged;

  const _SliderCheckin({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.color,
    required this.labelMin,
    required this.labelMid,
    required this.labelMax,
    required this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = suffix != null
        ? '${value.toStringAsFixed(suffix == 'h' ? 1 : 0)}$suffix'
        : value.round().toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF888888), fontSize: 13)),
            const Spacer(),
            Text(
              displayValue,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: const Color(0xFF2A2A2A),
            thumbColor: Colors.white,
            trackHeight: 4,
            thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape:
                const RoundSliderOverlayShape(overlayRadius: 16),
            overlayColor: color.withAlpha(51),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(labelMin,
                style: const TextStyle(
                    color: Color(0xFF444444), fontSize: 10)),
            Text(labelMid,
                style: const TextStyle(
                    color: Color(0xFF444444), fontSize: 10)),
            Text(labelMax,
                style: const TextStyle(
                    color: Color(0xFF444444), fontSize: 10)),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CheckItem({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value
                        ? const Color(0xFFC8F135)
                        : Colors.transparent,
                    border: value
                        ? null
                        : Border.all(
                            color: const Color(0xFF444444),
                            width: 1.5,
                          ),
                  ),
                  child: value
                      ? const Icon(Icons.check,
                          color: Color(0xFF0D0D0D), size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
          const Divider(
            color: Color(0xFF1A1A1A),
            height: 0.5,
            thickness: 0.5,
          ),
        ],
      ),
    );
  }
}

class _OpcionToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OpcionToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFC8F135).withAlpha(32)
              : const Color(0xFF1A1A1A),
          border: Border.all(
            color: selected
                ? const Color(0xFFC8F135)
                : const Color(0xFF2A2A2A),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? const Color(0xFFC8F135)
                : const Color(0xFF888888),
            fontSize: 13,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _PillResumen extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PillResumen({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        border: Border.all(color: color.withAlpha(102), width: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
