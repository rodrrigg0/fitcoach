import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/core/constants/app_constants.dart';
import 'package:fitcoach/data/models/user_profile.dart';
import 'package:fitcoach/data/services/home_provider.dart';
import 'package:fitcoach/presentation/auth/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email =
        FirebaseAuth.instance.currentUser?.email ?? '';

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
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  int _diasDesdeRegistro(DateTime fecha) {
    return DateTime.now().difference(fecha).inDays;
  }
}
