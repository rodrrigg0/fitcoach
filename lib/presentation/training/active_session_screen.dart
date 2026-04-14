import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/data/models/exercise_log.dart';
import 'package:fitcoach/data/models/workout_plan.dart';
import 'package:fitcoach/data/services/training_provider.dart';

class ActiveSessionScreen extends StatefulWidget {
  final WorkoutDay workout;
  final String diaNombre;

  const ActiveSessionScreen({
    super.key,
    required this.workout,
    required this.diaNombre,
  });

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  final _notasController = TextEditingController();

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainingProvider>(
      builder: (context, provider, _) {
        final sesion = provider.sesionActual;

        if (sesion == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: AppColors.textPrimary),
              onPressed: () => context.pop(),
            ),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sesion.tituloEntrenamiento,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatFecha(sesion.fecha),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: provider.guardando
                    ? null
                    : () async {
                        await provider.guardarSesion();
                        if (context.mounted) context.pop();
                      },
                child: const Text(
                  'Finalizar',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSesion(sesion),
                ...sesion.ejercicios.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final ejercicio = entry.value;
                  final planEjercicio =
                      idx < widget.workout.ejercicios.length
                          ? widget.workout.ejercicios[idx]
                          : null;
                  return _ExerciseLogCard(
                    key: ValueKey(ejercicio.id),
                    ejercicio: ejercicio,
                    planDetalle: planEjercicio?.series,
                    provider: provider,
                  );
                }),
                _buildNotasSesion(provider),
                _buildBotonGuardar(context, provider),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSesion(WorkoutLog sesion) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${sesion.diaSemana} · ${_formatFecha(sesion.fecha)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(32),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'En curso',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotasSesion(TrainingProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
            'NOTAS DE LA SESIÓN',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notasController,
            maxLines: 4,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14),
            decoration: const InputDecoration(
              hintText:
                  '¿Cómo te has sentido hoy? ¿Algo que destacar?...',
              hintStyle: TextStyle(color: Color(0xFF444444)),
              border: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) => provider.actualizarNotasSesion(v),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonGuardar(
      BuildContext context, TrainingProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ElevatedButton(
        onPressed: provider.guardando
            ? null
            : () async {
                await provider.guardarSesion();
                if (context.mounted) context.pop();
              },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        child: provider.guardando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.background,
                  strokeWidth: 2,
                ),
              )
            : const Text('Guardar sesión'),
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre',
      'diciembre',
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]}';
  }
}

// ─── Exercise Log Card ──────────────────────────────────────

class _ExerciseLogCard extends StatefulWidget {
  final ExerciseLog ejercicio;
  final String? planDetalle;
  final TrainingProvider provider;

  const _ExerciseLogCard({
    super.key,
    required this.ejercicio,
    required this.planDetalle,
    required this.provider,
  });

  @override
  State<_ExerciseLogCard> createState() => _ExerciseLogCardState();
}

class _ExerciseLogCardState extends State<_ExerciseLogCard> {
  bool _expanded = false;
  late List<SerieLog> _series;
  late TextEditingController _notasController;

  @override
  void initState() {
    super.initState();
    _series = List.from(widget.ejercicio.series);
    _notasController =
        TextEditingController(text: widget.ejercicio.notas);
  }

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }

  void _addSerie() {
    final nuevaSerie = SerieLog(
      numero: _series.length + 1,
      peso: _series.isNotEmpty ? _series.last.peso : 0,
      repeticiones:
          _series.isNotEmpty ? _series.last.repeticiones : 0,
    );
    setState(() => _series = [..._series, nuevaSerie]);
    widget.provider.actualizarSeriesEjercicio(
        widget.ejercicio.id, _series);
  }

  void _updateSerie(int idx, SerieLog updated) {
    final nuevas = List<SerieLog>.from(_series)..[idx] = updated;
    setState(() => _series = nuevas);
    widget.provider.actualizarSeriesEjercicio(
        widget.ejercicio.id, _series);
  }

  void _deleteSerie(int idx) {
    final nuevas = List<SerieLog>.from(_series)..removeAt(idx);
    // Re-numerar
    final renumeradas = nuevas
        .asMap()
        .entries
        .map((e) => e.value.copyWith(numero: e.key + 1))
        .toList();
    setState(() => _series = renumeradas);
    widget.provider.actualizarSeriesEjercicio(
        widget.ejercicio.id, _series);
  }

  @override
  Widget build(BuildContext context) {
    final ultimoReg = widget.provider
        .ultimoRegistro(widget.ejercicio.ejercicioNombre);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ejercicio.ejercicioNombre,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.planDetalle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.planDetalle!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (_series.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _resumenSeries(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ultimoReg != null &&
                        ultimoReg.pesoMaximo > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundElevated,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Último: ${_formatPeso(ultimoReg.pesoMaximo)}kg',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    GestureDetector(
                      onTap: () =>
                          setState(() => _expanded = !_expanded),
                      child: Icon(
                        _expanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ── Expandido ──
            if (_expanded) ...[
              // Último registro
              if (ultimoReg != null &&
                  ultimoReg.series.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ÚLTIMA VEZ',
                        style: TextStyle(
                          color: Color(0xFF444444),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        children: ultimoReg.series
                            .map((s) => Text(
                                  '${s.numero}×${s.repeticiones} ${_formatPeso(s.peso)}kg',
                                  style: const TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 12,
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],

              // Series de hoy
              const SizedBox(height: 12),
              const Text(
                'SERIES DE HOY',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),

              ..._series.asMap().entries.map((entry) => _SerieRow(
                    serie: entry.value,
                    onChanged: (updated) =>
                        _updateSerie(entry.key, updated),
                    onDelete: () => _deleteSerie(entry.key),
                  )),

              // Añadir serie
              TextButton.icon(
                onPressed: _addSerie,
                icon: const Icon(Icons.add,
                    color: AppColors.primary, size: 18),
                label: const Text(
                  'Añadir serie',
                  style: TextStyle(
                      color: AppColors.primary, fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),

              // Notas del ejercicio
              const SizedBox(height: 8),
              TextField(
                controller: _notasController,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Notas del ejercicio...',
                  hintStyle: TextStyle(color: Color(0xFF444444)),
                  border: InputBorder.none,
                  filled: false,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) => widget.provider
                    .actualizarNotasEjercicio(widget.ejercicio.id, v),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _resumenSeries() =>
      _series.map((s) => '${s.numero}×${s.repeticiones} ${_formatPeso(s.peso)}kg').join(' · ');

  String _formatPeso(double p) =>
      p == p.truncateToDouble() ? p.toInt().toString() : p.toStringAsFixed(1);
}

// ─── Serie Row ──────────────────────────────────────────────

class _SerieRow extends StatefulWidget {
  final SerieLog serie;
  final ValueChanged<SerieLog> onChanged;
  final VoidCallback onDelete;

  const _SerieRow({
    required this.serie,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_SerieRow> createState() => _SerieRowState();
}

class _SerieRowState extends State<_SerieRow> {
  late TextEditingController _pesoController;
  late int _reps;

  @override
  void initState() {
    super.initState();
    _reps = widget.serie.repeticiones;
    final p = widget.serie.peso;
    _pesoController = TextEditingController(
      text: p > 0
          ? (p == p.truncateToDouble()
              ? p.toInt().toString()
              : p.toStringAsFixed(1))
          : '',
    );
  }

  @override
  void dispose() {
    _pesoController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    final peso = double.tryParse(_pesoController.text) ?? 0;
    widget.onChanged(
        widget.serie.copyWith(peso: peso, repeticiones: _reps));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          // Número de serie
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.backgroundElevated,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${widget.serie.numero}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Campo PESO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'PESO',
                  style: TextStyle(
                    color: Color(0xFF444444),
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pesoController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*')),
                        ],
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0',
                          hintStyle:
                              TextStyle(color: Color(0xFF444444)),
                          border: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        textAlign: TextAlign.center,
                        onChanged: (_) => _notifyChange(),
                      ),
                    ),
                    const Text(
                      'kg',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divisor
          Container(
            width: 1,
            height: 30,
            color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),

          // Campo REPS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'REPS',
                  style: TextStyle(
                    color: Color(0xFF444444),
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_reps > 0) {
                          setState(() => _reps--);
                          _notifyChange();
                        }
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.backgroundElevated,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.remove,
                            color: AppColors.textSecondary, size: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '$_reps',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() => _reps++);
                        _notifyChange();
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.backgroundElevated,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add,
                            color: AppColors.textSecondary, size: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Eliminar serie
          GestureDetector(
            onTap: widget.onDelete,
            child: const Icon(Icons.close,
                color: Color(0xFF444444), size: 16),
          ),
        ],
      ),
    );
  }
}
