import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitcoach/core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────
// Datos de deportes
// ─────────────────────────────────────────────────────────────

const List<({String nombre, String svg})> _kDeportes = [
  (
    nombre: 'Gimnasio',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><path d="M4 16h4M24 16h4M8 16V10M24 16V10M8 10h4M20 10h4M12 10v12M20 10v12M12 22h8" stroke="white" stroke-width="1.5" stroke-linecap="round" fill="none"/></svg>',
  ),
  (
    nombre: 'Running',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><circle cx="19" cy="5" r="2.5" stroke="white" stroke-width="1.5" fill="none"/><path d="M17 9l-4 5 3 3-3 8M17 9l4 2 3-3M13 14l-4 2" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/></svg>',
  ),
  (
    nombre: 'Natación',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><circle cx="22" cy="6" r="2.5" stroke="white" stroke-width="1.5" fill="none"/><path d="M4 16c3-4 6-4 8 0s5 4 8 0M4 21c3-4 6-4 8 0s5 4 8 0M18 9l-6 4 4 3" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/></svg>',
  ),
  (
    nombre: 'Ciclismo',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><circle cx="8" cy="22" r="5" stroke="white" stroke-width="1.5" fill="none"/><circle cx="24" cy="22" r="5" stroke="white" stroke-width="1.5" fill="none"/><path d="M8 22l8-10h5M16 12l8 10M16 12l-2-4h4" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/></svg>',
  ),
  (
    nombre: 'Fútbol',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><circle cx="16" cy="16" r="11" stroke="white" stroke-width="1.5" fill="none"/><path d="M16 5l4 3-2 5h-4l-2-5zM27 13l-3 2-4-2M5 13l3 2 4-2M8 25l2-4h4M24 25l-2-4h-4M12 21l4 4 4-4" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/></svg>',
  ),
  (
    nombre: 'Baloncesto',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><circle cx="16" cy="16" r="11" stroke="white" stroke-width="1.5" fill="none"/><path d="M5 16h22M16 5v22M9 8c2 3 2 6 0 9M23 8c-2 3-2 6 0 9" stroke="white" stroke-width="1.5" stroke-linecap="round" fill="none"/></svg>',
  ),
  (
    nombre: 'Tenis',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><path d="M8 24L24 8" stroke="white" stroke-width="4" stroke-linecap="round" fill="none"/><ellipse cx="22" cy="10" rx="6" ry="4" transform="rotate(-45 22 10)" stroke="white" stroke-width="1.5" fill="none"/><path d="M20 12c1-2 3-2 4 0M22 9c2 1 2 3 0 4" stroke="white" stroke-width="1" fill="none"/></svg>',
  ),
  (
    nombre: 'Pádel',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><rect x="10" y="4" width="14" height="16" rx="7" stroke="white" stroke-width="1.5" fill="none"/><path d="M13 20l-5 8M21 20l5 8M14 10h6M14 13h6M14 16h6" stroke="white" stroke-width="1.5" stroke-linecap="round" fill="none"/></svg>',
  ),
  (
    nombre: 'Boxeo',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><path d="M8 20c0-6 4-12 10-12h4c2 0 4 1 4 3s-2 3-4 3h-2c2 0 4 1 4 3s-2 3-5 3H8z" stroke="white" stroke-width="1.5" stroke-linejoin="round" fill="none"/><path d="M8 20v4c0 1 1 2 2 2h2M8 12V8c0-1 1-2 2-2h2" stroke="white" stroke-width="1.5" stroke-linecap="round" fill="none"/></svg>',
  ),
  (
    nombre: 'Artes marciales',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><circle cx="16" cy="5" r="2.5" stroke="white" stroke-width="1.5" fill="none"/><path d="M16 8v8M16 16l-6 8M16 16l6 8M10 12l-4 2M22 12l4 2" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/></svg>',
  ),
  (
    nombre: 'Yoga',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><circle cx="16" cy="5" r="2.5" stroke="white" stroke-width="1.5" fill="none"/><path d="M16 8v8M10 24c2-4 4-6 6-8 2 2 4 4 6 8M7 16c3 2 6 3 9 0 3 3 6 2 9 0" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/></svg>',
  ),
  (
    nombre: 'Pilates',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><circle cx="8" cy="10" r="2.5" stroke="white" stroke-width="1.5" fill="none"/><path d="M4 16h8l4-6 4 4h8M10 16l2 8" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/></svg>',
  ),
  (
    nombre: 'CrossFit',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><path d="M8 24l8-12 8 12M10 20h12" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/><circle cx="16" cy="8" r="3" stroke="white" stroke-width="1.5" fill="none"/></svg>',
  ),
  (
    nombre: 'Escalada',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><path d="M20 28V8M20 8l-8 6M20 14l6-4M14 20l-6 4" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/><circle cx="20" cy="6" r="2" stroke="white" stroke-width="1.5" fill="none"/></svg>',
  ),
  (
    nombre: 'Senderismo',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><path d="M6 26l8-16 4 6 4-8 4 6" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/><path d="M4 26h24" stroke="white" stroke-width="1.5" stroke-linecap="round" fill="none"/></svg>',
  ),
  (
    nombre: 'Esquí',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><circle cx="22" cy="6" r="2.5" stroke="white" stroke-width="1.5" fill="none"/><path d="M20 9l-4 8-8 4M16 17l2 7M8 28h16" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/><path d="M24 12l4 4" stroke="white" stroke-width="1.5" stroke-linecap="round" fill="none"/></svg>',
  ),
  (
    nombre: 'Surf',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><path d="M6 24c4-2 8-10 14-12" stroke="white" stroke-width="3" stroke-linecap="round" fill="none"/><circle cx="22" cy="10" r="2.5" stroke="white" stroke-width="1.5" fill="none"/><path d="M20 13l-6 4 2 4" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/></svg>',
  ),
  (
    nombre: 'Rugby',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><ellipse cx="16" cy="16" rx="10" ry="6" transform="rotate(-30 16 16)" stroke="white" stroke-width="1.5" fill="none"/><path d="M10 21l12-10M13 24l6-16" stroke="white" stroke-width="1" stroke-linecap="round" fill="none"/></svg>',
  ),
  (
    nombre: 'Volleyball',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><circle cx="16" cy="16" r="11" stroke="white" stroke-width="1.5" fill="none"/><path d="M5 16c4-6 10-6 14 0M13 5c2 6 6 10 13 8M19 27c-4-6-10-8-13-4" stroke="white" stroke-width="1.5" stroke-linecap="round" fill="none"/></svg>',
  ),
  (
    nombre: 'Golf',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><path d="M16 6v18" stroke="white" stroke-width="1.5" stroke-linecap="round" fill="none"/><path d="M16 6l8 4-8 4z" stroke="white" stroke-width="1.5" stroke-linejoin="round" fill="none"/><path d="M10 28c0-2 2-4 6-4s6 2 6 4" stroke="white" stroke-width="1.5" stroke-linecap="round" fill="none"/></svg>',
  ),
  (
    nombre: 'Atletismo',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><circle cx="20" cy="5" r="2.5" stroke="white" stroke-width="1.5" fill="none"/><path d="M18 8l-6 4 3 4-4 8M18 8l2 6M12 12l-5 1" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/></svg>',
  ),
  (
    nombre: 'Otro',
    svg:
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg"><circle cx="16" cy="16" r="11" stroke="white" stroke-width="1.5" fill="none"/><path d="M16 10v12M10 16h12" stroke="white" stroke-width="1.5" stroke-linecap="round" fill="none"/></svg>',
  ),
];

// ─────────────────────────────────────────────────────────────
// Widget público
// ─────────────────────────────────────────────────────────────

class SportSelector extends StatefulWidget {
  final void Function(List<String> deportes) onConfirmar;

  const SportSelector({required this.onConfirmar, super.key});

  @override
  State<SportSelector> createState() => _SportSelectorState();
}

class _SportSelectorState extends State<SportSelector> {
  final Set<String> _seleccionados = {};
  final TextEditingController _customCtrl = TextEditingController();
  final List<({String nombre, String svg})> _extras = [];

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  void _toggleDeporte(String nombre) {
    setState(() {
      if (_seleccionados.contains(nombre)) {
        _seleccionados.remove(nombre);
      } else {
        _seleccionados.add(nombre);
      }
    });
  }

  void _agregarCustom() {
    final texto = _customCtrl.text.trim();
    if (texto.isEmpty) return;
    final svgOtro = _kDeportes.last.svg;
    setState(() {
      _extras.add((nombre: texto, svg: svgOtro));
      _seleccionados.add(texto);
      _customCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final todos = [..._kDeportes, ..._extras];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Grid de deportes ───────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 16) / 3;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: todos.map((d) {
                final sel = _seleccionados.contains(d.nombre);
                return _SportCard(
                  nombre: d.nombre,
                  svg: d.svg,
                  selected: sel,
                  width: cardWidth,
                  onTap: () => _toggleDeporte(d.nombre),
                );
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 12),

        // ── Deporte personalizado ──────────────────────────
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customCtrl,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Otro deporte...',
                  hintStyle: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14),
                  filled: true,
                  fillColor: AppColors.backgroundCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _agregarCustom(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _agregarCustom,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),

        // ── Botón Continuar ────────────────────────────────
        if (_seleccionados.isNotEmpty) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  widget.onConfirmar(_seleccionados.toList()),
              child: const Text('Continuar'),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Card individual de deporte
// ─────────────────────────────────────────────────────────────

class _SportCard extends StatelessWidget {
  final String nombre;
  final String svg;
  final bool selected;
  final double width;
  final VoidCallback onTap;

  const _SportCard({
    required this.nombre,
    required this.svg,
    required this.selected,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.border.withValues(alpha: 0.5),
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.string(
              svg,
              width: 32,
              height: 32,
              colorFilter: ColorFilter.mode(
                selected
                    ? AppColors.primary
                    : const Color(0xFF888888),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              nombre,
              style: TextStyle(
                color: selected
                    ? AppColors.primary
                    : const Color(0xFF888888),
                fontSize: 10,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
