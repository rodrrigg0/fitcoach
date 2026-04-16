import 'dart:io';
import 'dart:math' show min, max;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/core/constants/app_constants.dart';
import 'package:fitcoach/data/models/user_profile.dart';
import 'package:fitcoach/data/models/progress_photo.dart';
import 'package:fitcoach/data/models/weight_log.dart';
import 'package:fitcoach/data/services/home_provider.dart';
import 'package:fitcoach/l10n/app_localizations.dart';
import 'package:fitcoach/core/providers/locale_provider.dart';
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
      if (mounted) {
        context.read<HomeProvider>().cargarPesos();
        context.read<HomeProvider>().cargarFotos();
      }
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
                    _buildFotosSection(context, provider),
                  ],
                  _buildSettingsSection(context),
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
              Text(
                AppLocalizations.of(context)!.profileWeightSection,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _mostrarRegistrarPeso(context, provider),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: AppColors.primary, size: 16),
                    const SizedBox(width: 2),
                    Text(
                      AppLocalizations.of(context)!.profileWeightRegister,
                      style: const TextStyle(
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
                  Text(
                    AppLocalizations.of(context)!.profileWeightLastLabel,
                    style: const TextStyle(
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
              SnackBar(content: Text(AppLocalizations.of(context)!.profileWeightModalTitle)),
            );
          }
        },
      ),
    );
  }

  // ── FOTOS DE PROGRESO ────────────────────────────────────

  Widget _buildFotosSection(BuildContext context, HomeProvider provider) {
    final fotos = provider.fotosProgreso;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'FOTOS DE PROGRESO',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _mostrarOpcionesSubida(context, provider),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_a_photo_outlined,
                          color: AppColors.primary, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Añadir',
                        style: TextStyle(
                            color: AppColors.primary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          if (fotos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 32),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.photo_camera_outlined,
                        color: Color(0xFF444444), size: 36),
                    SizedBox(height: 12),
                    Text(
                      'Aún no tienes fotos de progreso',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Añade tu primera foto para\nempezar a ver tu evolución',
                      style: TextStyle(
                          color: Color(0xFF444444), fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            if (fotos.length >= 2)
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: GestureDetector(
                  onTap: () => _mostrarComparativa(context, provider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(21),
                      border: Border.all(
                          color: AppColors.primary.withAlpha(64)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.compare_arrows,
                            color: AppColors.primary, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Ver comparativa inicio vs ahora',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: fotos.length,
                itemBuilder: (ctx, i) =>
                    _photoTile(context, fotos[i], provider),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _photoTile(BuildContext context, ProgressPhoto foto,
      HomeProvider provider) {
    final dia = foto.fecha.day.toString().padLeft(2, '0');
    final mes = foto.fecha.month.toString().padLeft(2, '0');

    return GestureDetector(
      onTap: () => _mostrarDetalleFoto(context, provider, foto),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: foto.url,
              fit: BoxFit.cover,
              placeholder: (ctx, url) => Container(
                color: AppColors.backgroundCard,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 1.5,
                  ),
                ),
              ),
              errorWidget: (ctx, url, e) => Container(
                color: AppColors.backgroundCard,
                child: const Icon(Icons.broken_image_outlined,
                    color: Color(0xFF444444)),
              ),
            ),
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(153),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$dia/$mes',
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BOTTOM SHEETS — Fotos ─────────────────────────────────

  void _mostrarOpcionesSubida(
      BuildContext context, HomeProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FotoSourceSheet(
        onSelectSource: (source, notas, peso) async {
          Navigator.of(ctx).pop();
          await _seleccionarFoto(context, provider, source, notas, peso);
        },
      ),
    );
  }

  Future<void> _seleccionarFoto(
    BuildContext context,
    HomeProvider provider,
    ImageSource source,
    String? notas,
    double? peso,
  ) async {
    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (xFile == null || !context.mounted) return;
      _mostrarVistaPrevia(context, provider, xFile.path, notas, peso);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('No se pudo acceder a la cámara o galería')),
        );
      }
    }
  }

  void _mostrarVistaPrevia(
    BuildContext context,
    HomeProvider provider,
    String path,
    String? notas,
    double? peso,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FotoPreviewSheet(
        rutaLocal: path,
        onUpload: () async {
          final ok = await provider.subirFoto(
            rutaLocal: path,
            notas: notas,
            peso: peso,
          );
          if (ctx.mounted) Navigator.of(ctx).pop();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  ok ? 'Foto guardada' : 'Error al subir la foto',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _mostrarDetalleFoto(BuildContext context, HomeProvider provider,
      ProgressPhoto foto) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FotoDetailSheet(
        foto: foto,
        onDelete: () async {
          Navigator.of(ctx).pop();
          await provider.eliminarFoto(foto);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Foto eliminada')),
            );
          }
        },
      ),
    );
  }

  void _mostrarComparativa(
      BuildContext context, HomeProvider provider) {
    final fotos = provider.fotosProgreso;
    if (fotos.length < 2) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FotoComparativaSheet(
        // fotos is descending: first = newest, last = oldest
        primera: fotos.last,
        ultima: fotos.first,
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  // ── SETTINGS + LOGOUT ────────────────────────────────────

  Widget _buildSettingsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final isEs = localeProvider.locale.languageCode == 'es';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profileSectionSettings,
            style: const TextStyle(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.language,
                      color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.profileLanguage,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  _LangToggle(
                    isEs: isEs,
                    onToggle: () => localeProvider.toggleLocale(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
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
            child: Text(
              l10n.profileLogout,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
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
          ? Center(
              child: Text(
                AppLocalizations.of(context)!.profileWeightNoData,
                style: const TextStyle(
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
          Text(
            AppLocalizations.of(context)!.profileWeightModalTitle,
            style: const TextStyle(
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
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.profileWeightNotesHint,
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
                  : Text(AppLocalizations.of(context)!.save),
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

// ─── Foto Source Sheet ───────────────────────────────────────

class _FotoSourceSheet extends StatefulWidget {
  final Future<void> Function(ImageSource, String?, double?) onSelectSource;

  const _FotoSourceSheet({required this.onSelectSource});

  @override
  State<_FotoSourceSheet> createState() => _FotoSourceSheetState();
}

class _FotoSourceSheetState extends State<_FotoSourceSheet> {
  final _notasCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();

  @override
  void dispose() {
    _notasCtrl.dispose();
    _pesoCtrl.dispose();
    super.dispose();
  }

  void _onSource(ImageSource source) {
    final notas = _notasCtrl.text.trim();
    final pesoStr = _pesoCtrl.text.trim().replaceAll(',', '.');
    final peso = double.tryParse(pesoStr);
    widget.onSelectSource(source, notas.isEmpty ? null : notas, peso);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
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
              'Nueva foto de progreso',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Guarda tu evolución semana a semana',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            // Source buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onSource(ImageSource.camera),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D0D),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF2A2A2A), width: 0.5),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.camera_alt,
                              color: AppColors.primary, size: 28),
                          SizedBox(height: 8),
                          Text(
                            'Cámara',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onSource(ImageSource.gallery),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D0D),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF2A2A2A), width: 0.5),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.photo_library,
                              color: AppColors.textSecondary, size: 28),
                          SizedBox(height: 8),
                          Text(
                            'Galería',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'NOTAS (OPCIONAL)',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFF2A2A2A), width: 0.5),
              ),
              child: TextField(
                controller: _notasCtrl,
                maxLines: 2,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  hintText:
                      'Ej: Semana 4, bajé 2 kg este mes...',
                  hintStyle: TextStyle(color: Color(0xFF444444)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'PESO EN ESTE MOMENTO (OPCIONAL)',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFF2A2A2A), width: 0.5),
              ),
              child: TextField(
                controller: _pesoCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: '78.5',
                  hintStyle: TextStyle(color: Color(0xFF444444)),
                  suffixText: 'kg',
                  suffixStyle: TextStyle(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Foto Preview Sheet ───────────────────────────────────────

class _FotoPreviewSheet extends StatefulWidget {
  final String rutaLocal;
  final Future<void> Function() onUpload;

  const _FotoPreviewSheet({
    required this.rutaLocal,
    required this.onUpload,
  });

  @override
  State<_FotoPreviewSheet> createState() => _FotoPreviewSheetState();
}

class _FotoPreviewSheetState extends State<_FotoPreviewSheet> {
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          const SizedBox(height: 16),
          const Text(
            'Confirmar foto',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(widget.rutaLocal),
              height: 260,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          if (_uploading)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Subiendo foto...',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  setState(() => _uploading = true);
                  await widget.onUpload();
                  if (mounted) setState(() => _uploading = false);
                },
                child: const Text('Subir foto'),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Foto Detail Sheet ────────────────────────────────────────

class _FotoDetailSheet extends StatelessWidget {
  final ProgressPhoto foto;
  final Future<void> Function() onDelete;

  const _FotoDetailSheet({
    required this.foto,
    required this.onDelete,
  });

  String _formatFechaLarga(DateTime d) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${d.day} de ${meses[d.month - 1]} de ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: foto.url,
              width: double.infinity,
              height: 320,
              fit: BoxFit.cover,
              placeholder: (ctx, url) => Container(
                height: 320,
                color: AppColors.backgroundCard,
                child: const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2),
                ),
              ),
              errorWidget: (ctx, url, e) => Container(
                height: 320,
                color: AppColors.backgroundCard,
                child: const Icon(Icons.broken_image_outlined,
                    color: Color(0xFF444444), size: 40),
              ),
            ),
          ),
          // Metadata
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatFechaLarga(foto.fecha),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (foto.peso != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${foto.peso!.toStringAsFixed(1)} kg ese día',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13),
                            ),
                          ],
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _confirmarEliminar(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0x40FF4444), width: 0.5),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: Color(0xFFFF4444), size: 18),
                      ),
                    ),
                  ],
                ),
                if (foto.notas != null && foto.notas!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0D),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF2A2A2A), width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NOTAS',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          foto.notas!,
                          style: const TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Eliminar foto',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '¿Seguro que quieres eliminar esta foto? Esta acción no se puede deshacer.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              onDelete();
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Color(0xFFFF4444)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Foto Comparativa Sheet ───────────────────────────────────

class _FotoComparativaSheet extends StatelessWidget {
  final ProgressPhoto primera; // oldest
  final ProgressPhoto ultima;  // newest
  final VoidCallback onClose;

  const _FotoComparativaSheet({
    required this.primera,
    required this.ultima,
    required this.onClose,
  });

  String _shortDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year.toString().substring(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final hasPesoDiff =
        primera.peso != null && ultima.peso != null;
    final diff = hasPesoDiff
        ? ultima.peso! - primera.peso! // new - old (negative = lost weight)
        : 0.0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              'Comparativa de progreso',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Primera foto vs. más reciente',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Primera (oldest)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'INICIO',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: primera.url,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (ctx, url) => Container(
                            height: 300,
                            color: AppColors.backgroundCard,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 1.5),
                            ),
                          ),
                          errorWidget: (ctx, url, e) => Container(
                            height: 300,
                            color: AppColors.backgroundCard,
                            child: const Icon(
                                Icons.broken_image_outlined,
                                color: Color(0xFF444444)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _shortDate(primera.fecha),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                      if (primera.peso != null)
                        Text(
                          '${primera.peso!.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Última (newest)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(32),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: AppColors.primary.withAlpha(64),
                              width: 0.5),
                        ),
                        child: const Text(
                          'AHORA',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: ultima.url,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (ctx, url) => Container(
                            height: 300,
                            color: AppColors.backgroundCard,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 1.5),
                            ),
                          ),
                          errorWidget: (ctx, url, e) => Container(
                            height: 300,
                            color: AppColors.backgroundCard,
                            child: const Icon(
                                Icons.broken_image_outlined,
                                color: Color(0xFF444444)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _shortDate(ultima.fecha),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                      if (ultima.peso != null)
                        Text(
                          '${ultima.peso!.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasPesoDiff) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF2A2A2A), width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text('Inicio',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11)),
                        Text(
                          '${primera.peso!.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward,
                        color: Color(0xFF444444), size: 20),
                    Column(
                      children: [
                        const Text('Ahora',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11)),
                        Text(
                          '${ultima.peso!.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: const Color(0xFF2A2A2A),
                    ),
                    Column(
                      children: [
                        const Text('Diferencia',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11)),
                        Text(
                          '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            color: diff < 0
                                ? AppColors.primary
                                : const Color(0xFFFF4444),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: onClose,
                child: const Text(
                  'Cerrar',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Language Toggle ──────────────────────────────────────────

class _LangToggle extends StatelessWidget {
  final bool isEs;
  final VoidCallback onToggle;

  const _LangToggle({required this.isEs, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.backgroundElevated,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LangOption(label: 'ES', active: isEs),
            _LangOption(label: 'EN', active: !isEs),
          ],
        ),
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String label;
  final bool active;

  const _LangOption({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? const Color(0xFF0D0D0D) : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
