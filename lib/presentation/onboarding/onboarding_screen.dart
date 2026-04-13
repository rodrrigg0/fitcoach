import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/core/constants/app_constants.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/data/services/onboarding_provider.dart';
import 'package:fitcoach/shared/widgets/number_picker_wheel.dart';
import 'package:fitcoach/shared/widgets/sport_selector.dart';

// ─────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _fadeCtrl;

  final TextEditingController _textoCtrl = TextEditingController();
  final TextEditingController _siNoCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  // Estado de inputs
  int _wheelValue = 25;
  Set<String> _selectedMulti = {};
  bool _mostrandoSiNoInput = false;
  String _siNoOpcionSeleccionada = '';

  // Animación de stats
  final Set<String> _recentlyUpdated = {};
  final Map<String, Timer> _statTimers = {};
  Map<String, String>? _prevStats;

  OnboardingProvider? _provider;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<OnboardingProvider>();
    if (_provider != provider) {
      _provider?.removeListener(_onProviderChange);
      _provider = provider;
      _provider!.addListener(_onProviderChange);
      if (!_initialized) {
        _initialized = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) provider.iniciarOnboarding();
        });
      }
    }
  }

  void _onProviderChange() {
    if (!mounted) return;

    if (_provider!.onboardingCompletado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(
            AppConstants.routeProfileLoading,
            extra: _provider!.perfilEnConstruccion,
          );
        }
      });
      return;
    }

    final step = _provider!.stepActual;

    // Actualizar animaciones de stats
    final newStats = _provider!.statsVisibles;
    if (_prevStats != null) {
      for (final key in [
        'nombre', 'objetivo', 'deporte', 'lugar',
        'dias', 'peso', 'altura', 'edad'
      ]) {
        final prev = _prevStats![key];
        final curr = newStats[key];
        if (prev != curr && curr != null && curr != '...') {
          _checkStat(key, true);
        }
      }
    }
    _prevStats = Map.from(newStats);

    setState(() {
      _mostrandoSiNoInput = false;
      _siNoOpcionSeleccionada = '';
      _selectedMulti = {};
      _textoCtrl.clear();
      _siNoCtrl.clear();
      if (step.tipo == TipoPregunta.ruedaNumerica) {
        _wheelValue = _defaultWheelValue(step);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _checkStat(String key, bool condition) {
    if (!condition) return;
    _statTimers[key]?.cancel();
    if (!_recentlyUpdated.contains(key)) {
      setState(() => _recentlyUpdated.add(key));
    }
    _statTimers[key] = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _recentlyUpdated.remove(key));
    });
  }

  int _defaultWheelValue(OnboardingStep step) {
    return switch (step.sufijo) {
      'años' => 25,
      'kg' => 70,
      'cm' => 170,
      '€' => 80,
      'h' => 7,
      _ => step.minValor ?? 0,
    };
  }

  void _avanzar(String valor) {
    if (valor.trim().isEmpty) return;
    _provider?.avanzarPaso(valor.trim());
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChange);
    _bgCtrl.dispose();
    _fadeCtrl.dispose();
    _textoCtrl.dispose();
    _siNoCtrl.dispose();
    _scrollCtrl.dispose();
    for (final t in _statTimers.values) {
      t.cancel();
    }
    super.dispose();
  }

  // ── Helpers estáticos ─────────────────────────────────────

  static String _faseText(int paso) {
    if (paso < 3) return 'Conociéndote...';
    if (paso < 6) return 'Analizando tu perfil...';
    if (paso < 11) return 'Diseñando tu plan...';
    return 'Casi listo...';
  }

  static ({Color head, Color torso, Color arms, Color legs})
      _siluetaColores(Set<String> partes) {
    const def = AppColors.backgroundElevated;
    const lit = AppColors.primary;
    final hay = partes.isNotEmpty;
    return (
      head: hay ? lit : def,
      torso: partes.contains('torso') ? lit : def,
      arms: partes.contains('brazos') ? lit : def,
      legs: partes.contains('piernas') ? lit : def,
    );
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeCtrl,
          child: Consumer<OnboardingProvider>(
            builder: (context, provider, _) {
              return Column(
                children: [
                  _buildHeader(provider),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollCtrl,
                      padding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatsCard(provider),
                          const SizedBox(height: 16),
                          AnimatedSwitcher(
                            duration:
                                const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) =>
                                FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.06),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: anim,
                                  curve: Curves.easeOut,
                                )),
                                child: child,
                              ),
                            ),
                            child: _buildStepContent(
                              provider,
                              key: ValueKey(provider.pasoActual),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────

  Widget _buildHeader(OnboardingProvider provider) {
    final progreso =
        ((provider.pasoActual) / OnboardingProvider.pasos.length)
            .clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: AppColors.primary, width: 2),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'FC',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Entrenador FitCoach',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _faseText(provider.pasoActual),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progreso,
                    backgroundColor: AppColors.backgroundCard,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary),
                    minHeight: 3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(progreso * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── Tarjeta visual ────────────────────────────────────────

  Widget _buildStatsCard(OnboardingProvider provider) {
    final colores = _siluetaColores(provider.partesIluminadas);
    final sv = provider.statsVisibles;
    final stats = [
      _StatData('Nombre', sv['nombre'] ?? '...',
          _recentlyUpdated.contains('nombre')),
      _StatData('Objetivo', sv['objetivo'] ?? '...',
          _recentlyUpdated.contains('objetivo')),
      _StatData('Deporte', sv['deporte'] ?? '...',
          _recentlyUpdated.contains('deporte')),
      _StatData('Lugar', sv['lugar'] ?? '...',
          _recentlyUpdated.contains('lugar')),
      _StatData('Días/sem.', sv['dias'] ?? '...',
          _recentlyUpdated.contains('dias')),
      _StatData('Peso', sv['peso'] ?? '...',
          _recentlyUpdated.contains('peso')),
      _StatData('Altura', sv['altura'] ?? '...',
          _recentlyUpdated.contains('altura')),
      _StatData('Edad', sv['edad'] ?? '...',
          _recentlyUpdated.contains('edad')),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HumanSilhouette(
            headColor: colores.head,
            torsoColor: colores.torso,
            armsColor: colores.arms,
            legsColor: colores.legs,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  stats.map((s) => _StatRow(data: s)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Contenido del paso actual ─────────────────────────────

  Widget _buildStepContent(OnboardingProvider provider,
      {required Key key}) {
    final step = provider.stepActual;
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categoría + Pregunta
        Row(
          children: [
            Container(width: 40, height: 2, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(
              step.categoria,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          step.pregunta,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 24),

        // Input según tipo
        _buildInputArea(step, provider.pasoActual),
      ],
    );
  }

  // ── Input según tipo ──────────────────────────────────────

  Widget _buildInputArea(OnboardingStep step, int pasoIdx) {
    return switch (step.tipo) {
      TipoPregunta.textoLibre => _buildTextoLibre(),
      TipoPregunta.opcionUnica => _buildOpcionUnica(step),
      TipoPregunta.opcionMultiple => _buildOpcionMultiple(step),
      TipoPregunta.ruedaNumerica =>
        _buildRuedaNumerica(step, pasoIdx),
      TipoPregunta.deportes => _buildDeportes(),
      TipoPregunta.siNo => _buildSiNo(step),
    };
  }

  // ── textoLibre ────────────────────────────────────────────

  Widget _buildTextoLibre() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textoCtrl,
              autofocus: true,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Escribe tu respuesta...',
                hintStyle: TextStyle(
                    color: AppColors.textSecondary, fontSize: 16),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) _avanzar(v.trim());
              },
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              final v = _textoCtrl.text.trim();
              if (v.isNotEmpty) _avanzar(v);
            },
            child: const Icon(
              Icons.arrow_upward_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  // ── opcionUnica ───────────────────────────────────────────

  Widget _buildOpcionUnica(OnboardingStep step) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: step.opciones!.map((opcion) {
        return GestureDetector(
          onTap: () => _avanzar(opcion),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              opcion,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── opcionMultiple ────────────────────────────────────────

  Widget _buildOpcionMultiple(OnboardingStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: step.opciones!.map((opcion) {
            final isNinguno = opcion == 'Ninguno';
            final sel = _selectedMulti.contains(opcion);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isNinguno) {
                    _selectedMulti = {'Ninguno'};
                  } else {
                    _selectedMulti.remove('Ninguno');
                    if (sel) {
                      _selectedMulti.remove(opcion);
                    } else {
                      _selectedMulti.add(opcion);
                    }
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color:
                        sel ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  opcion,
                  style: TextStyle(
                    color: sel
                        ? AppColors.background
                        : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: sel
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedMulti.isNotEmpty) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _avanzar(_selectedMulti.join(', '));
              },
              child: const Text('Confirmar selección'),
            ),
          ),
        ],
      ],
    );
  }

  // ── ruedaNumerica ─────────────────────────────────────────

  Widget _buildRuedaNumerica(OnboardingStep step, int pasoIdx) {
    return Column(
      children: [
        NumberPickerWheel(
          key: ValueKey('wheel_$pasoIdx'),
          minValue: step.minValor!,
          maxValue: step.maxValor!,
          initialValue: _wheelValue,
          step: step.stepValor ?? 1,
          suffix: step.sufijo ?? '',
          onChanged: (val) => _wheelValue = val,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _avanzar(_wheelValue.toString()),
            child: Text('Confirmar ${step.sufijo ?? ''}'),
          ),
        ),
      ],
    );
  }

  // ── deportes ──────────────────────────────────────────────

  Widget _buildDeportes() {
    return SportSelector(
      onConfirmar: (deportes) => _avanzar(deportes.join(', ')),
    );
  }

  // ── siNo ──────────────────────────────────────────────────

  Widget _buildSiNo(OnboardingStep step) {
    final opNo = step.opciones![0];
    final opSi = step.opciones![1];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botón "No..."
        GestureDetector(
          onTap: () => _avanzar(opNo),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              opNo,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Botón "Sí..."
        GestureDetector(
          onTap: () {
            setState(() {
              _mostrandoSiNoInput = true;
              _siNoOpcionSeleccionada = opSi;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _mostrandoSiNoInput
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _mostrandoSiNoInput
                    ? AppColors.primary
                    : AppColors.border,
                width: _mostrandoSiNoInput ? 1.5 : 1.0,
              ),
            ),
            child: Text(
              opSi,
              style: TextStyle(
                color: _mostrandoSiNoInput
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontSize: 15,
                fontWeight: _mostrandoSiNoInput
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Campo de texto condicional
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _mostrandoSiNoInput
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color:
                            AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _siNoCtrl,
                          autofocus: true,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15),
                          decoration: InputDecoration(
                            hintText: _hintSiNo(step),
                            hintStyle: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(
                                    vertical: 10),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (v) => _enviarSiNo(v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _enviarSiNo(_siNoCtrl.text),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _enviarSiNo(String descripcion) {
    final clean = descripcion.trim();
    final valor = clean.isEmpty
        ? _siNoOpcionSeleccionada
        : '$_siNoOpcionSeleccionada: $clean';
    _avanzar(valor);
  }

  static String _hintSiNo(OnboardingStep step) {
    if (step.numero == 11) return 'Describe tu lesión...';
    if (step.numero == 13) return 'Describe tus alergias...';
    return 'Cuéntame más...';
  }
}

// ─────────────────────────────────────────────────────────────
// Data class
// ─────────────────────────────────────────────────────────────

class _StatData {
  final String label;
  final String? value;
  final bool isRecent;
  const _StatData(this.label, this.value, this.isRecent);
}

// ─────────────────────────────────────────────────────────────
// Human silhouette
// ─────────────────────────────────────────────────────────────

class _HumanSilhouette extends StatelessWidget {
  final Color headColor;
  final Color torsoColor;
  final Color armsColor;
  final Color legsColor;

  const _HumanSilhouette({
    required this.headColor,
    required this.torsoColor,
    required this.armsColor,
    required this.legsColor,
  });

  @override
  Widget build(BuildContext context) {
    const double width = 70;
    const double height = 110;
    const double sx = 1.0;
    const double sy = 1.0;

    Widget part({
      required double left,
      required double top,
      required double pw,
      required double ph,
      required double radius,
      required Color color,
      bool circle = false,
    }) =>
        Positioned(
          left: left * sx,
          top: top * sy,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: pw * sx,
            height: ph * sy,
            decoration: BoxDecoration(
              color: color,
              shape: circle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius:
                  circle ? null : BorderRadius.circular(radius * sx),
            ),
          ),
        );

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          part(left: 27, top: 0, pw: 16, ph: 16, radius: 8,
              color: headColor, circle: true),
          part(left: 32, top: 16, pw: 6, ph: 6, radius: 2,
              color: torsoColor),
          part(left: 21, top: 22, pw: 28, ph: 32, radius: 6,
              color: torsoColor),
          part(left: 7, top: 23, pw: 11, ph: 28, radius: 5,
              color: armsColor),
          part(left: 52, top: 23, pw: 11, ph: 28, radius: 5,
              color: armsColor),
          part(left: 20, top: 56, pw: 13, ph: 54, radius: 5,
              color: legsColor),
          part(left: 37, top: 56, pw: 13, ph: 54, radius: 5,
              color: legsColor),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Stat row
// ─────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow({required this.data});
  final _StatData data;

  @override
  Widget build(BuildContext context) {
    final display = data.value ?? '...';
    final isDot = display == '...' || display.isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: AnimatedDefaultTextStyle(
                    key: ValueKey(display),
                    duration: const Duration(milliseconds: 250),
                    style: TextStyle(
                      color: isDot
                          ? const Color(0xFF444444)
                          : (data.isRecent
                              ? AppColors.primary
                              : AppColors.textPrimary),
                      fontSize: 12,
                      fontWeight: isDot
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                    child: Text(
                      display,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          LinearProgressIndicator(
            value: isDot ? 0.0 : 1.0,
            backgroundColor: AppColors.backgroundElevated,
            valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary),
            minHeight: 2,
            borderRadius: BorderRadius.circular(1),
          ),
        ],
      ),
    );
  }
}
