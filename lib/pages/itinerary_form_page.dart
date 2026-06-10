import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../models/itinerary.dart';
import '../providers/auth_provider.dart';
import '../providers/city_provider.dart';
import '../providers/itinerary_provider.dart';
import '../theme/app_theme.dart';

/// Formulário de criação e edição de roteiro.
/// Recebe [existing] para modo de edição, null para criação.
class ItineraryFormPage extends ConsumerStatefulWidget {
  final Itinerary? existing;

  const ItineraryFormPage({super.key, this.existing});

  @override
  ConsumerState<ItineraryFormPage> createState() => _ItineraryFormPageState();
}

class _ItineraryFormPageState extends ConsumerState<ItineraryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _notesCtrl;
  late List<Place> _selectedPlaces;
  DateTime? _selectedDate;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _selectedPlaces = List.from(e?.places ?? []);
    _selectedDate = e?.date;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppColors.coral),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _togglePlace(Place place) {
    setState(() {
      if (_selectedPlaces.any((p) => p.id == place.id)) {
        _selectedPlaces.removeWhere((p) => p.id == place.id);
      } else {
        _selectedPlaces.add(place);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final city = ref.read(cityProvider);

    setState(() => _saving = true);
    try {
      final notifier = ref.read(itineraryProvider.notifier);

      if (_isEdit) {
        final updated = widget.existing!.copyWith(
          name: _nameCtrl.text.trim(),
          cityName: city.name,
          districtName: widget.existing!.districtName,
          date: _selectedDate,
          clearDate: _selectedDate == null,
          places: _selectedPlaces,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          clearNotes: _notesCtrl.text.trim().isEmpty,
        );
        await notifier.edit(updated);
        _toast('Roteiro atualizado!');
      } else {
        await notifier.add(Itinerary(
          id: '',
          userId: user.uid,
          name: _nameCtrl.text.trim(),
          cityName: city.name,
          districtName: ref.read(bestDistrictProvider)?.district ?? city.name,
          date: _selectedDate,
          places: _selectedPlaces,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        ));
        _toast('Roteiro criado!');
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      _toast('Erro ao salvar roteiro', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.destructive : AppColors.foreground,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final allPlaces = ref.watch(availablePlacesProvider);
    final city = ref.watch(cityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.foreground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEdit ? 'Editar Roteiro' : 'Novo Roteiro',
          style: const TextStyle(
              color: AppColors.foreground, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.coral)),
              ),
            )
          else
            TextButton(
              onPressed: _submit,
              child: const Text('Salvar',
                  style: TextStyle(
                      color: AppColors.coral, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // ── Cidade ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.coralLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.mapPin, size: 16, color: AppColors.coral),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      city.name,
                      style: const TextStyle(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Nome ──────────────────────────────────────────────────────
            _Label('Nome do Roteiro'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ex: Fim de semana no Centro Histórico',
                prefixIcon: Icon(LucideIcons.bookOpen,
                    size: 18, color: AppColors.mutedForeground),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Informe um nome' : null,
            ),
            const SizedBox(height: 20),

            // ── Data ──────────────────────────────────────────────────────
            _Label('Data (opcional)'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.calendar,
                        size: 18, color: AppColors.mutedForeground),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'Selecionar data'
                            : _formatDate(_selectedDate!),
                        style: TextStyle(
                          fontSize: 15,
                          color: _selectedDate == null
                              ? AppColors.mutedForeground
                              : AppColors.foreground,
                        ),
                      ),
                    ),
                    if (_selectedDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _selectedDate = null),
                        child: const Icon(LucideIcons.x,
                            size: 16, color: AppColors.mutedForeground),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Notas ─────────────────────────────────────────────────────
            _Label('Notas (opcional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Dicas, reservas, informações extras...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),

            // ── Locais ────────────────────────────────────────────────────
            Row(
              children: [
                _Label('Locais do Roteiro'),
                const Spacer(),
                if (_selectedPlaces.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.coralLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_selectedPlaces.length} selecionado${_selectedPlaces.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.coral,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (allPlaces.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Nenhum local disponível para esta cidade.',
                  style: TextStyle(color: AppColors.mutedForeground),
                ),
              )
            else
              ...allPlaces.map((place) => _PlaceCheckTile(
                    place: place,
                    selected: _selectedPlaces.any((p) => p.id == place.id),
                    onToggle: () => _togglePlace(place),
                  )),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.foreground,
        ),
      );
}

class _PlaceCheckTile extends StatelessWidget {
  final Place place;
  final bool selected;
  final VoidCallback onToggle;

  const _PlaceCheckTile({
    required this.place,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.coralLight : AppColors.secondary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.coral : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Text(place.category.emoji,
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: selected
                            ? AppColors.coral
                            : AppColors.foreground,
                      ),
                    ),
                    if (place.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        place.description,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.mutedForeground),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.muted,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            place.category.label,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.mutedForeground),
                          ),
                        ),
                        if (place.rating != null) ...[
                          const SizedBox(width: 8),
                          const Icon(LucideIcons.star,
                              size: 12, color: AppColors.warning),
                          const SizedBox(width: 2),
                          Text(
                            place.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.mutedForeground),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selected ? AppColors.coral : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.coral
                        : AppColors.mutedForeground,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
