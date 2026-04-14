import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/data/services/home_provider.dart';
import 'package:fitcoach/data/models/meal_plan.dart';

void _showMacroAdjustSheet(BuildContext context, HomeProvider provider) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _MacroAdjustSheet(provider: provider),
  );
}

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

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
                  if (provider.planNutricion == null)
                    _buildEmptyState(context, provider)
                  else ...[
                    _buildMacrosSummary(provider),
                    _buildMealList(context, provider),
                  ],
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
          const Expanded(
            child: Text(
              'Nutrición',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (provider.planNutricion != null) ...[
            GestureDetector(
              onTap: () => _showMacroAdjustSheet(context, provider),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Macros',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: provider.cargandoNutricion
                  ? null
                  : () => provider.generarPlanNutricion(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: provider.cargandoNutricion
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh,
                              color: AppColors.textSecondary, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Regenerar',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: AppColors.textSecondary,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sin plan nutricional',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Genera tu plan de alimentación personalizado con IA',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          if (provider.cargandoNutricion)
            const CircularProgressIndicator(color: AppColors.primary)
          else
            ElevatedButton(
              onPressed: () => provider.generarPlanNutricion(),
              child: const Text('Generar plan nutricional'),
            ),
        ],
      ),
    );
  }

  Widget _buildMacrosSummary(HomeProvider provider) {
    final plan = provider.planNutricion!;
    final consumidas = plan.caloriasConsumidas;
    final objetivo = plan.caloriasObjetivo;
    final progreso = objetivo > 0 ? consumidas / objetivo : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  'Calorías hoy',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '$consumidas / $objetivo kcal',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
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
            const SizedBox(height: 16),
            Row(
              children: [
                _macroItem(
                    'Proteínas',
                    '${plan.proteinasConsumidas.round()}g',
                    '${plan.proteinasObjetivo.round()}g',
                    const Color(0xFF4FC3F7)),
                const SizedBox(width: 12),
                _macroItem(
                    'Carbos',
                    '${(plan.comidas.where((m) => m.completada).fold(0.0, (s, m) => s + m.carbohidratos)).round()}g',
                    '${plan.carbosObjetivo.round()}g',
                    const Color(0xFFFFB74D)),
                const SizedBox(width: 12),
                _macroItem(
                    'Grasas',
                    '${(plan.comidas.where((m) => m.completada).fold(0.0, (s, m) => s + m.grasas)).round()}g',
                    '${plan.grasasObjetivo.round()}g',
                    const Color(0xFFEF9A9A)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroItem(
      String label, String actual, String objetivo, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              actual,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
            Text(
              'de $objetivo',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealList(BuildContext context, HomeProvider provider) {
    final comidas = provider.comidasHoy;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
          ...comidas.map((meal) => _MealCard(
                meal: meal,
                onToggle: () =>
                    context.read<HomeProvider>().toggleComidaCompletada(meal),
              )),
          _buildTotalesCard(provider),
        ],
      ),
    );
  }

  Widget _buildTotalesCard(HomeProvider provider) {
    final plan = provider.planNutricion!;
    final completadas = plan.comidas.where((m) => m.completada).toList();
    final protTotal = completadas.fold(0.0, (s, m) => s + m.proteinas);
    final carbTotal = completadas.fold(0.0, (s, m) => s + m.carbohidratos);
    final grasTotal = completadas.fold(0.0, (s, m) => s + m.grasas);

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 24),
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
            'TOTALES DEL DÍA',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _totalMacro('Proteínas', '${protTotal.round()}g',
                  plan.proteinasObjetivo, const Color(0xFF4FC3F7)),
              const SizedBox(width: 10),
              _totalMacro('Carbos', '${carbTotal.round()}g',
                  plan.carbosObjetivo, const Color(0xFFFFB74D)),
              const SizedBox(width: 10),
              _totalMacro('Grasas', '${grasTotal.round()}g',
                  plan.grasasObjetivo, const Color(0xFFEF9A9A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalMacro(
      String label, String valor, double objetivo, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valor,
            style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: objetivo > 0
                  ? (double.tryParse(valor.replaceAll('g', '')) ?? 0) /
                      objetivo
                  : 0.0,
              backgroundColor: AppColors.backgroundElevated,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
          Text('de ${objetivo.round()}g',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onToggle;

  const _MealCard({required this.meal, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: meal.completada
            ? AppColors.primary.withAlpha(15)
            : AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: meal.completada
            ? Border.all(color: AppColors.primary.withAlpha(51))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: meal.completada
                    ? AppColors.primary
                    : AppColors.backgroundElevated,
                shape: BoxShape.circle,
              ),
              child: meal.completada
                  ? const Icon(Icons.check,
                      color: AppColors.background, size: 14)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meal.nombre,
                        style: TextStyle(
                          color: meal.completada
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: meal.completada
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    Text(
                      '${meal.calorias} kcal',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${meal.hora} · ${_capitalize(meal.tipo)} · P:${meal.proteinas.round()}g C:${meal.carbohidratos.round()}g G:${meal.grasas.round()}g',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─── Macro Adjust Sheet ─────────────────────────────────────

class _MacroAdjustSheet extends StatefulWidget {
  final HomeProvider provider;
  const _MacroAdjustSheet({required this.provider});

  @override
  State<_MacroAdjustSheet> createState() => _MacroAdjustSheetState();
}

class _MacroAdjustSheetState extends State<_MacroAdjustSheet> {
  late double _proteinas;
  late double _carbos;
  late double _grasas;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final plan = widget.provider.planNutricion;
    _proteinas = plan?.proteinasObjetivo ?? 150;
    _carbos = plan?.carbosObjetivo ?? 200;
    _grasas = plan?.grasasObjetivo ?? 65;
  }

  int get _calorias =>
      (_proteinas * 4 + _carbos * 4 + _grasas * 9).round();

  bool get _warnProtein {
    final peso = widget.provider.perfil?.peso ?? 0;
    return peso > 0 && _proteinas < peso * 1.6;
  }

  bool get _warnCalorias => _calorias < 1200;

  void _restaurar() {
    final cals = widget.provider.caloriasObjetivo;
    setState(() {
      _proteinas = ((cals * 0.30) / 4).roundToDouble();
      _carbos = ((cals * 0.45) / 4).roundToDouble();
      _grasas = ((cals * 0.25) / 9).roundToDouble();
    });
  }

  Future<void> _guardar(BuildContext ctx) async {
    setState(() => _guardando = true);
    final scaffoldMessenger = ScaffoldMessenger.of(ctx);
    Navigator.of(ctx).pop();
    await widget.provider.actualizarObjetivosMacros(
      proteinas: _proteinas.round(),
      carbos: _carbos.round(),
      grasas: _grasas.round(),
    );
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: const Text('Objetivos actualizados'),
        backgroundColor: AppColors.backgroundCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCals = _calorias;
    final protFrac = totalCals > 0 ? (_proteinas * 4) / totalCals : 0.33;
    final carbsFrac = totalCals > 0 ? (_carbos * 4) / totalCals : 0.34;
    final grasFrac = totalCals > 0 ? (_grasas * 9) / totalCals : 0.33;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Ajustar macros',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$totalCals kcal',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    width: (MediaQuery.of(context).size.width - 48) *
                        protFrac,
                    color: const Color(0xFF4FC3F7),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    width: (MediaQuery.of(context).size.width - 48) *
                        carbsFrac,
                    color: const Color(0xFFFFB74D),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    width: (MediaQuery.of(context).size.width - 48) *
                        grasFrac,
                    color: const Color(0xFFEF9A9A),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _legend(const Color(0xFF4FC3F7),
                  'P ${(_proteinas * 4 / totalCals * 100).round()}%'),
              const SizedBox(width: 12),
              _legend(const Color(0xFFFFB74D),
                  'C ${(_carbos * 4 / totalCals * 100).round()}%'),
              const SizedBox(width: 12),
              _legend(const Color(0xFFEF9A9A),
                  'G ${(_grasas * 9 / totalCals * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 20),
          _sliderRow('Proteínas', _proteinas, 50, 350, 'g',
              const Color(0xFF4FC3F7), (v) => setState(() => _proteinas = v)),
          _sliderRow('Carbohidratos', _carbos, 50, 600, 'g',
              const Color(0xFFFFB74D), (v) => setState(() => _carbos = v)),
          _sliderRow('Grasas', _grasas, 20, 200, 'g',
              const Color(0xFFEF9A9A), (v) => setState(() => _grasas = v)),
          if (_warnProtein) ...[
            const SizedBox(height: 8),
            _warning(
                'Proteínas por debajo de 1.6g/kg. Puede limitar la recuperación muscular.'),
          ],
          if (_warnCalorias) ...[
            const SizedBox(height: 8),
            _warning(
                'Total inferior a 1200 kcal. No recomendado sin supervisión médica.'),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _restaurar,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Restaurar automático',
                      style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      _guardando ? null : () => _guardar(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Guardar cambios',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sliderRow(
    String label,
    double value,
    double min,
    double max,
    String suffix,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                inactiveTrackColor: AppColors.backgroundElevated,
                thumbColor: color,
                overlayColor: color.withAlpha(40),
                trackHeight: 3,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: ((max - min) / 5).round(),
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              '${value.round()}$suffix',
              style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _warning(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x20FF7043),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFFF7043), size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  color: Color(0xFFFF7043), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
