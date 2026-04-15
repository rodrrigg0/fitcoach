import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/data/models/meal_plan.dart';
import 'package:fitcoach/data/models/shopping_item.dart';
import 'package:fitcoach/data/services/home_provider.dart';
import 'package:fitcoach/l10n/app_localizations.dart';
import 'package:fitcoach/shared/widgets/meal_detail_sheet.dart';

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
        final hasPlan = provider.planNutricion != null;
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, provider),
                  if (!hasPlan)
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildEmptyState(context, provider),
                      ),
                    )
                  else ...[
                    _buildTabBar(context),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildTabHoy(context, provider),
                          _buildTabSemana(context, provider),
                          _buildTabCompra(context, provider),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── HEADER ──────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, HomeProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.nutritionTitle,
              style: const TextStyle(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  AppLocalizations.of(context)!.nutritionMacros,
                  style: const TextStyle(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.refresh,
                              color: AppColors.textSecondary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            AppLocalizations.of(context)!.nutritionRegenerate,
                            style: const TextStyle(
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

  // ── TAB BAR ─────────────────────────────────────────────────

  Widget _buildTabBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: AppColors.background,
      child: TabBar(
        indicatorColor: AppColors.primary,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        dividerColor: AppColors.border,
        tabs: [
          Tab(text: l10n.nutritionTabToday),
          Tab(text: l10n.nutritionTabWeek),
          Tab(text: l10n.nutritionTabShop),
        ],
      ),
    );
  }

  // ── TAB HOY ─────────────────────────────────────────────────

  Widget _buildTabHoy(BuildContext context, HomeProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMacrosSummary(context, provider),
          _buildMealList(context, provider),
        ],
      ),
    );
  }

  // ── TAB SEMANA ───────────────────────────────────────────────

  Widget _buildTabSemana(BuildContext context, HomeProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final diasNombre = [
      l10n.nutritionDayMon,
      l10n.nutritionDayTue,
      l10n.nutritionDayWed,
      l10n.nutritionDayThu,
      l10n.nutritionDayFri,
      l10n.nutritionDaySat,
      l10n.nutritionDaySun,
    ];
    final comidas = provider.planNutricion!.comidas;
    final hoyIdx = DateTime.now().weekday - 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Column(
        children: List.generate(
          7,
          (i) => _DayMealCard(
            key: ValueKey<int>(i),
            diaSemana: diasNombre[i],
            comidas: comidas,
            isHoy: i == hoyIdx,
            onTapMeal: (meal) => showMealDetailSheet(context, meal),
          ),
        ),
      ),
    );
  }

  // ── TAB COMPRA ───────────────────────────────────────────────

  Widget _buildTabCompra(BuildContext context, HomeProvider provider) {
    final lista = provider.listaCompra;
    final generando = provider.generandoLista;

    if (lista.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                color: Color(0xFF444444),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.nutritionShopTitle,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context)!.nutritionShopEmpty,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (generando) ...[
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.nutritionShopGenerating,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14),
                ),
              ] else
                ElevatedButton(
                  onPressed: () => provider.generarListaCompra(),
                  child: Text(AppLocalizations.of(context)!.nutritionShopGenerate),
                ),
            ],
          ),
        ),
      );
    }

    // Agrupa por categoría preservando orden de aparición
    final categories = <String>[];
    final byCategory = <String, List<int>>{};
    for (int i = 0; i < lista.length; i++) {
      final cat = lista[i].categoria;
      if (!byCategory.containsKey(cat)) {
        categories.add(cat);
        byCategory[cat] = [];
      }
      byCategory[cat]!.add(i);
    }

    final completados = lista.where((i) => i.comprado).length;
    final progreso = lista.isNotEmpty ? completados / lista.length : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.nutritionShopProgress(completados, lista.length),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: generando ? null : () => provider.generarListaCompra(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  generando
                      ? AppLocalizations.of(context)!.nutritionShopGenerating
                      : AppLocalizations.of(context)!.nutritionRegenerate,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Barra progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progreso,
              backgroundColor: AppColors.backgroundElevated,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 3,
            ),
          ),
          // Categorías
          ...categories.map((cat) {
            final indices = byCategory[cat]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                  child: Text(
                    cat.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                ...indices.map(
                  (idx) => _ShoppingItemTile(
                    item: lista[idx],
                    onToggle: () => provider.toggleItemComprado(idx),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── SHARED: MACROS SUMMARY ───────────────────────────────────

  Widget _buildMacrosSummary(BuildContext context, HomeProvider provider) {
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
                Text(
                  AppLocalizations.of(context)!.homeCaloriesToday,
                  style: const TextStyle(
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
                    AppLocalizations.of(context)!.homeMacroProtein,
                    '${plan.proteinasConsumidas.round()}g',
                    '${plan.proteinasObjetivo.round()}g',
                    const Color(0xFF4FC3F7)),
                const SizedBox(width: 12),
                _macroItem(
                    AppLocalizations.of(context)!.homeMacroCarbs,
                    '${(plan.comidas.where((m) => m.completada).fold(0.0, (s, m) => s + m.carbohidratos)).round()}g',
                    '${plan.carbosObjetivo.round()}g',
                    const Color(0xFFFFB74D)),
                const SizedBox(width: 12),
                _macroItem(
                    AppLocalizations.of(context)!.homeMacroFat,
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

  // ── SHARED: MEAL LIST ────────────────────────────────────────

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
                onTap: () => showMealDetailSheet(context, meal),
              )),
          _buildTotalesCard(context, provider),
        ],
      ),
    );
  }

  Widget _buildTotalesCard(BuildContext context, HomeProvider provider) {
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
          Text(
            'TOTALES DEL DÍA',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _totalMacro(AppLocalizations.of(context)!.homeMacroProtein, '${protTotal.round()}g',
                  plan.proteinasObjetivo, const Color(0xFF4FC3F7)),
              const SizedBox(width: 10),
              _totalMacro(AppLocalizations.of(context)!.homeMacroCarbs, '${carbTotal.round()}g',
                  plan.carbosObjetivo, const Color(0xFFFFB74D)),
              const SizedBox(width: 10),
              _totalMacro(AppLocalizations.of(context)!.homeMacroFat, '${grasTotal.round()}g',
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
                color: color, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: objetivo > 0
                  ? (double.tryParse(valor.replaceAll('g', '')) ?? 0) / objetivo
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

  // ── EMPTY STATE ──────────────────────────────────────────────

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
          Text(
            AppLocalizations.of(context)!.nutritionEmptyTitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.nutritionEmptyDesc,
            style: const TextStyle(
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
              child: Text(AppLocalizations.of(context)!.nutritionGeneratePlan),
            ),
        ],
      ),
    );
  }
}

// ─── Day Meal Card (semana) ──────────────────────────────────

class _DayMealCard extends StatefulWidget {
  final String diaSemana;
  final List<Meal> comidas;
  final bool isHoy;
  final void Function(Meal) onTapMeal;

  const _DayMealCard({
    super.key,
    required this.diaSemana,
    required this.comidas,
    required this.isHoy,
    required this.onTapMeal,
  });

  @override
  State<_DayMealCard> createState() => _DayMealCardState();
}

class _DayMealCardState extends State<_DayMealCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.isHoy;
  }

  Color _tipoColorLocal(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'desayuno':
        return AppColors.primary;
      case 'almuerzo':
        return AppColors.textSecondary;
      case 'cena':
        return const Color(0xFF378ADD);
      case 'snack':
        return const Color(0xFFD85A30);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalKcal =
        widget.comidas.fold(0, (s, m) => s + m.calorias);
    final totalProt =
        widget.comidas.fold(0.0, (s, m) => s + m.proteinas);
    final totalCarb =
        widget.comidas.fold(0.0, (s, m) => s + m.carbohidratos);
    final totalGras =
        widget.comidas.fold(0.0, (s, m) => s + m.grasas);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          // Header siempre visible
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.diaSemana,
                            style: TextStyle(
                              color: widget.isHoy
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.isHoy) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(26),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.nutritionToday,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalKcal kcal',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Pills de macros
                  Text(
                    'P: ${totalProt.round()}g',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'C: ${totalCarb.round()}g',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'G: ${totalGras.round()}g',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF444444),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          // Comidas colapsables
          if (_expanded)
            ...widget.comidas.map((meal) => _buildMealRow(meal)),
        ],
      ),
    );
  }

  Widget _buildMealRow(Meal meal) {
    final color = _tipoColorLocal(meal.tipo);
    final ingredientesPreview = meal.ingredientes.take(3).join(', ') +
        (meal.ingredientes.length > 3 ? '...' : '');

    return GestureDetector(
      onTap: () => widget.onTapMeal(meal),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Info comida
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        meal.tipo.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meal.nombre,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (ingredientesPreview.isNotEmpty)
                    Text(
                      ingredientesPreview,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Kcal y macros
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${meal.calorias} kcal',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'P:${meal.proteinas.round()}g C:${meal.carbohidratos.round()}g G:${meal.grasas.round()}g',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF444444),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shopping Item Tile ──────────────────────────────────────

class _ShoppingItemTile extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onToggle;

  const _ShoppingItemTile({required this.item, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: item.comprado
                ? AppColors.primary.withAlpha(48)
                : AppColors.border,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Checkbox animado
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: item.comprado
                    ? AppColors.primary
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: item.comprado
                    ? null
                    : Border.all(color: const Color(0xFF444444), width: 1.5),
              ),
              child: item.comprado
                  ? const Icon(Icons.check,
                      color: Color(0xFF0D0D0D), size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            // Nombre y cantidad
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nombre,
                    style: TextStyle(
                      color: item.comprado
                          ? const Color(0xFF444444)
                          : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: item.comprado
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  Text(
                    item.cantidad,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Badge cantidad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.cantidad,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Meal Card (tab hoy) ──────────────────────────────────────

class _MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _MealCard({
    required this.meal,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                color: Color(0xFF444444), size: 16),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─── Macro Adjust Sheet ──────────────────────────────────────

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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCals = _calorias;
    final protFrac =
        totalCals > 0 ? (_proteinas * 4) / totalCals : 0.33;
    final carbsFrac =
        totalCals > 0 ? (_carbos * 4) / totalCals : 0.34;
    final grasFrac =
        totalCals > 0 ? (_grasas * 9) / totalCals : 0.33;

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
              const Color(0xFF4FC3F7),
              (v) => setState(() => _proteinas = v)),
          _sliderRow('Carbohidratos', _carbos, 50, 600, 'g',
              const Color(0xFFFFB74D),
              (v) => setState(() => _carbos = v)),
          _sliderRow('Grasas', _grasas, 20, 200, 'g',
              const Color(0xFFEF9A9A),
              (v) => setState(() => _grasas = v)),
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
              style:
                  const TextStyle(color: Color(0xFFFF7043), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
