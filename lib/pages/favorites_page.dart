import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../models/district_score.dart';
import '../models/favorite_city.dart';
import '../providers/app_repository_provider.dart';
import '../services/city_dataset_service.dart';
import '../theme/app_theme.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  final _searchController = TextEditingController();
  final _cityController = TextEditingController();
  List<DistrictScore> _searchResults = [];
  bool _searching = false;
  String _filterQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.destructive : AppColors.foreground,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _searchCity() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      _toast('Digite uma cidade', error: true);
      return;
    }
    setState(() {
      _searching = true;
      _searchResults = [];
    });
    try {
      final results = await cityDatasetService.rankDistrictsForCity(city);
      if (results.isEmpty) {
        _toast('Nenhum distrito encontrado para "$city"', error: true);
      }
      setState(() => _searchResults = results);
    } catch (_) {
      _toast('Erro ao buscar cidade', error: true);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _toggleFavorite(DistrictScore district) async {
    final repo = ref.read(appRepositoryProvider);
    final isFav = repo.isFavorited(district.city, district.district);
    try {
      if (isFav) {
        final existing = repo.favoriteCities.firstWhere(
          (c) => c.cityName == district.city && c.district == district.district,
        );
        await repo.removeFavoriteCity(existing.id);
        _toast('Removido dos favoritos');
      } else {
        await repo.addFavoriteCity(
          cityName: district.city,
          district: district.district,
        );
        _toast('Adicionado aos favoritos!');
      }
      setState(() {});
    } catch (_) {
      _toast('Erro ao atualizar favoritos', error: true);
    }
  }

  Future<void> _removeFavorite(FavoriteCity fav) async {
    try {
      await ref.read(appRepositoryProvider).removeFavoriteCity(fav.id);
      setState(() {});
      _toast('Removido dos favoritos');
    } catch (_) {
      _toast('Erro ao remover', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(appRepositoryProvider);
    final favorites = repo.searchFavorites(_filterQuery);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft,
              color: AppColors.foreground, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Bairros Favoritos',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              children: [
                // ── Buscar cidade ─────────────────────────────────────
                const Text('Buscar Bairros',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        onSubmitted: (_) => _searchCity(),
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Londres, Paris, Roma...',
                          prefixIcon: const Icon(LucideIcons.search,
                              size: 16, color: AppColors.mutedForeground),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _searching ? null : _searchCity,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _searching
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(LucideIcons.search, size: 18),
                    ),
                  ],
                ),

                // ── Resultados da busca ───────────────────────────────
                if (_searchResults.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    '${_searchResults.length} distritos encontrados',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.mutedForeground),
                  ),
                  const SizedBox(height: 10),
                  ..._searchResults.map((d) {
                    final isFav = repo.isFavorited(d.city, d.district);
                    return _DistrictResultCard(
                      district: d,
                      isFavorited: isFav,
                      onToggle: () => _toggleFavorite(d),
                    );
                  }),
                ],

                // ── Favoritos salvos ──────────────────────────────────
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Meus Favoritos',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground)),
                    if (favorites.isNotEmpty)
                      Text('${favorites.length}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.mutedForeground)),
                  ],
                ),
                const SizedBox(height: 10),

                if (repo.favoriteCities.isNotEmpty) ...[
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _filterQuery = v),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Filtrar favoritos...',
                      prefixIcon: const Icon(LucideIcons.filter,
                          size: 14, color: AppColors.mutedForeground),
                      suffixIcon: _filterQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(LucideIcons.x,
                                  size: 14, color: AppColors.mutedForeground),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _filterQuery = '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                if (favorites.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        'Nenhum bairro favorito ainda.\nBusque uma cidade acima!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13, color: AppColors.mutedForeground),
                      ),
                    ),
                  )
                else
                  ...favorites.map((fav) => _FavoriteCard(
                        fav: fav,
                        onRemove: () => _removeFavorite(fav),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DistrictResultCard extends StatelessWidget {
  final DistrictScore district;
  final bool isFavorited;
  final VoidCallback onToggle;

  const _DistrictResultCard({
    required this.district,
    required this.isFavorited,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.coralLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.mapPin,
                size: 18, color: AppColors.coral),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(district.district,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground)),
                Text(district.city,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.mutedForeground)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _ScoreBadge(
                        label: 'Score',
                        value: district.overallScore.toStringAsFixed(0)),
                    const SizedBox(width: 6),
                    _ScoreBadge(
                        label: 'Segurança',
                        value: district.safetyScore.toStringAsFixed(0)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              LucideIcons.heart,
              size: 20,
              color: isFavorited
                  ? AppColors.coral
                  : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteCity fav;
  final VoidCallback onRemove;

  const _FavoriteCard({required this.fav, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.coralLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.heart,
                size: 18, color: AppColors.coral),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fav.district.isEmpty ? fav.cityName : fav.district,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground),
                ),
                if (fav.district.isNotEmpty)
                  Text(fav.cityName,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.mutedForeground)),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(LucideIcons.trash2,
                size: 18, color: AppColors.mutedForeground),
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final String label;
  final String value;

  const _ScoreBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.mutedForeground),
      ),
    );
  }
}