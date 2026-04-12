import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/core/constants/app_constants.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/data/models/chat_message.dart';
import 'package:fitcoach/data/services/onboarding_provider.dart';

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
  late final AnimationController _sendIconCtrl;
  late final Animation<double> _sendRotation;

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Set<String> _recentlyUpdated = {};
  final Map<String, Timer> _statTimers = {};

  Map<String, String>? _prevStats;
  String? _selectedOption;
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
    _sendIconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _sendRotation = Tween<double>(begin: 0.0, end: -0.125).animate(
      CurvedAnimation(parent: _sendIconCtrl, curve: Curves.easeInOut),
    );
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
    final newStats = _provider!.statsVisibles;
    if (_prevStats != null) {
      for (final key in ['nombre', 'objetivo', 'deporte', 'dias', 'peso']) {
        final prev = _prevStats![key];
        final curr = newStats[key];
        if (prev != curr && curr != null && curr != '...') {
          _checkStat(key, true);
        }
      }
    }
    _prevStats = Map.from(newStats);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToBottom());
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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _enviar(String texto) async {
    final clean = texto.trim();
    if (clean.isEmpty || (_provider?.estaCargando ?? true)) return;
    _inputController.clear();
    setState(() => _selectedOption = null);
    _sendIconCtrl.forward().then((_) => _sendIconCtrl.reverse());
    try {
      await _provider!.enviarMensaje(clean);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _seleccionarOpcion(String opcion) async {
    setState(() => _selectedOption = opcion);
    await _enviar(opcion);
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChange);
    _bgCtrl.dispose();
    _fadeCtrl.dispose();
    _sendIconCtrl.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    for (final t in _statTimers.values) {
      t.cancel();
    }
    super.dispose();
  }

  // ── Pure helpers ──────────────────────────────────────────

  static ChatMessage? _lastIAMsg(List<ChatMessage> msgs) {
    for (int i = msgs.length - 1; i >= 0; i--) {
      if (!msgs[i].esUsuario && !msgs[i].estaCargando) return msgs[i];
    }
    return null;
  }

  static String _faseText(int n) {
    if (n < 3) return 'Conociéndote...';
    if (n < 6) return 'Analizando tu perfil...';
    if (n < 9) return 'Diseñando tu plan...';
    return 'Casi listo...';
  }

  static String _prettifyObjetivo(String obj) {
    const map = {
      'perder_grasa': 'Perder grasa',
      'ganar_musculo': 'Ganar músculo',
      'recomposicion': 'Recomposición',
      'rendimiento': 'Rendimiento',
      'mantener': 'Mantener',
      'salud': 'Salud general',
    };
    return map[obj] ?? obj;
  }

  static String _categoriaTag(String? msg) {
    if (msg == null) return 'PERSONAL';
    final m = msg.toLowerCase();
    if (m.contains('entrena') || m.contains('deport') ||
        m.contains('días') || m.contains('donde') ||
        m.contains('lugar') || m.contains('minutos') ||
        m.contains('sesión') || m.contains('nivel') ||
        m.contains('actividad')) {
      return 'ENTRENAMIENTO';
    }
    if (m.contains('dieta') || m.contains('alerg') ||
        m.contains('presupuesto') || m.contains('suple') ||
        m.contains('come') || m.contains('alimenta')) {
      return 'NUTRICIÓN';
    }
    if (m.contains('sueño') || m.contains('horas') ||
        m.contains('duermes') || m.contains('descanso')) {
      return 'ESTILO DE VIDA';
    }
    return 'PERSONAL';
  }

  // Bug 2: colores basados en partesIluminadas del provider
  static ({Color head, Color torso, Color arms, Color legs})
      _siluetaColoresDePartes(Set<String> partes) {
    const def = AppColors.backgroundElevated;
    const lit = AppColors.primary;
    final tieneAlgo = partes.isNotEmpty;
    return (
      head: tieneAlgo ? lit : def,
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
              if (provider.onboardingCompletado) {
                return _buildCompletionContent(provider);
              }
              return _buildMainContent(provider);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(OnboardingProvider provider) {
    final msgs = provider.mensajes;
    final preguntasRespondidas =
        msgs.where((m) => m.esUsuario).length;
    final lastIA = _lastIAMsg(msgs);
    final lastMsg = lastIA?.contenido;
    // Bug 1: opciones vienen del provider (sincronizadas)
    final opciones = provider.opcionesActuales.isEmpty
        ? null
        : provider.opcionesActuales;
    final progreso =
        (preguntasRespondidas / 12.0).clamp(0.0, 1.0);
    // Bug 2: silueta desde partesIluminadas del provider
    final colores =
        _siluetaColoresDePartes(provider.partesIluminadas);

    // Bug 3: stats visibles en tiempo real desde el provider
    final sv = provider.statsVisibles;
    final stats = [
      _StatData('Nombre', sv['nombre'] ?? '...',
          _recentlyUpdated.contains('nombre')),
      _StatData('Objetivo', sv['objetivo'] ?? '...',
          _recentlyUpdated.contains('objetivo')),
      _StatData('Deporte', sv['deporte'] ?? '...',
          _recentlyUpdated.contains('deporte')),
      _StatData('Días/sem.', sv['dias'] ?? '...',
          _recentlyUpdated.contains('dias')),
      _StatData('Peso', sv['peso'] ?? '...',
          _recentlyUpdated.contains('peso')),
    ];

    return Stack(
      children: [
        // Fondo animado sutil
        AnimatedBuilder(
          animation: _bgCtrl,
          builder: (context, child) => Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.6),
                radius: 1.1 + _bgCtrl.value * 0.3,
                colors: [
                  AppColors.primary.withValues(
                      alpha: 0.04 + _bgCtrl.value * 0.02),
                  AppColors.background,
                ],
              ),
            ),
          ),
        ),
        Column(
          children: [
            _buildHeader(preguntasRespondidas, progreso),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding:
                    const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tarjeta visual central
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.border
                              .withValues(alpha: 0.5),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _HumanSilhouette(
                            headColor: colores.head,
                            torsoColor: colores.torso,
                            armsColor: colores.arms,
                            legsColor: colores.legs,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: stats
                                  .map((s) => _StatRow(data: s))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tarjeta de pregunta
                    _buildQuestionCard(
                        lastMsg, provider.estaCargando),
                    if (opciones != null && opciones.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildQuickOptions(opciones),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            _buildInputField(provider.estaCargando),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(int preguntasRespondidas, double progreso) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primary, width: 2),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'FC',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
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
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _faseText(preguntasRespondidas),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
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
                '${(progreso * 100).round()}% completado',
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

  Widget _buildQuestionCard(String? lastMsg, bool isLoading) {
    final tag = _categoriaTag(lastMsg);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      child: SizedBox(
        key: ValueKey(lastMsg ?? '_init_'),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag con línea decorativa
            Row(
              children: [
                Container(
                  width: 40,
                  height: 2,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  tag,
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
            // Texto de la pregunta o dots animados
            isLoading
                ? const _PuntosAnimados()
                : Text(
                    lastMsg ?? '',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickOptions(List<String> opciones) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: opciones.map((opcion) {
        final selected = _selectedOption == opcion;
        return GestureDetector(
          onTap: () => _seleccionarOpcion(opcion),
          child: AnimatedScale(
            scale: selected ? 1.02 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              child: Text(
                opcion,
                style: TextStyle(
                  color: selected
                      ? AppColors.background
                      : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInputField(bool isLoading) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Separador superior
        const Divider(height: 1, thickness: 1, color: AppColors.border),
        Container(
          color: AppColors.background,
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            12,
            8 + MediaQuery.of(context).padding.bottom,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  enabled: !isLoading,
                  maxLines: 3,
                  minLines: 1,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Tu respuesta...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10),
                    filled: false,
                  ),
                  onSubmitted: (v) => _enviar(v),
                  textInputAction: TextInputAction.send,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GestureDetector(
                  onTap: isLoading
                      ? null
                      : () => _enviar(_inputController.text),
                  child: RotationTransition(
                    turns: _sendRotation,
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      color: isLoading
                          ? AppColors.border
                          : AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionContent(OnboardingProvider provider) {
    final profile = provider.perfilEnConstruccion;
    final pills = [
      if (profile.deportes.isNotEmpty) profile.deportes.first,
      if (profile.objetivo.isNotEmpty)
        _prettifyObjetivo(profile.objetivo),
      if (profile.diasEntrenamiento > 0)
        '${profile.diasEntrenamiento} días/sem.',
    ];

    return _FadeInWidget(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _HumanSilhouette(
              headColor: AppColors.primary,
              torsoColor: AppColors.primary,
              armsColor: AppColors.primary,
              legsColor: AppColors.primary,
              width: 100,
              height: 157,
            ),
            const SizedBox(height: 28),
            const Text(
              '¡Tu perfil está listo!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              profile.nombre,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: pills
                  .map((p) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          p,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () =>
                  context.go(AppConstants.routeHome),
              child: const Text('Comenzar mi plan'),
            ),
          ],
        ),
      ),
    );
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
// Human silhouette widget
// ─────────────────────────────────────────────────────────────

class _HumanSilhouette extends StatelessWidget {
  final Color headColor;
  final Color torsoColor;
  final Color armsColor;
  final Color legsColor;
  final double width;
  final double height;

  const _HumanSilhouette({
    required this.headColor,
    required this.torsoColor,
    required this.armsColor,
    required this.legsColor,
    this.width = 70,
    this.height = 110,
  });

  @override
  Widget build(BuildContext context) {
    // All positions are relative to a 70×110 base and scaled.
    final sx = width / 70;
    final sy = height / 110;

    double x(double v) => v * sx;
    double y(double v) => v * sy;
    double w(double v) => v * sx;
    double h(double v) => v * sy;
    double r(double v) => v * sx;

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
          left: x(left),
          top: y(top),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: w(pw),
            height: h(ph),
            decoration: BoxDecoration(
              color: color,
              shape: circle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius:
                  circle ? null : BorderRadius.circular(r(radius)),
            ),
          ),
        );

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Head
          part(left: 27, top: 0, pw: 16, ph: 16, radius: 8,
              color: headColor, circle: true),
          // Neck
          part(left: 32, top: 16, pw: 6, ph: 6, radius: 2,
              color: torsoColor),
          // Torso
          part(left: 21, top: 22, pw: 28, ph: 32, radius: 6,
              color: torsoColor),
          // Left arm
          part(left: 7, top: 23, pw: 11, ph: 28, radius: 5,
              color: armsColor),
          // Right arm
          part(left: 52, top: 23, pw: 11, ph: 28, radius: 5,
              color: armsColor),
          // Left leg
          part(left: 20, top: 56, pw: 13, ph: 54, radius: 5,
              color: legsColor),
          // Right leg
          part(left: 37, top: 56, pw: 13, ph: 54, radius: 5,
              color: legsColor),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Stat row widget
// ─────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    final displayValue = data.value ?? '...';
    final isDot = displayValue == '...' || displayValue.isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                // Bug 3: AnimatedSwitcher anima el cambio
                // de '...' al valor real
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: AnimatedDefaultTextStyle(
                    key: ValueKey(displayValue),
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      color: isDot
                          ? const Color(0xFF444444)
                          : (data.isRecent
                              ? AppColors.primary
                              : AppColors.textPrimary),
                      fontSize: 13,
                      fontWeight: isDot
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                    child: Text(
                      displayValue,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
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

// ─────────────────────────────────────────────────────────────
// Animated dots (loading indicator)
// ─────────────────────────────────────────────────────────────

class _PuntosAnimados extends StatefulWidget {
  const _PuntosAnimados();

  @override
  State<_PuntosAnimados> createState() => _PuntosAnimadosState();
}

class _PuntosAnimadosState extends State<_PuntosAnimados>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // delay escalonado de 200ms entre puntos (200/600 ≈ 0.333)
            final t = (_ctrl.value - i * 0.333) % 1.0;
            // escala: seno suavizado de 0.6 → 1.0 → 0.6
            final scale = 0.6 + 0.4 * (t < 0.5 ? t * 2 : (1.0 - t) * 2);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.scale(
                scale: scale.clamp(0.6, 1.0),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Fade-in wrapper for completion screen
// ─────────────────────────────────────────────────────────────

class _FadeInWidget extends StatefulWidget {
  const _FadeInWidget({required this.child});

  final Widget child;

  @override
  State<_FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<_FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _ctrl, child: widget.child);
  }
}
