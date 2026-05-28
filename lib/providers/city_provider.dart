import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/city_location.dart';
import '../models/district_score.dart';
import '../services/city_dataset_service.dart';

/// Cidade atualmente selecionada no app. Começa com Londres, igual ao React.
final cityProvider = StateProvider<CityLocation>((ref) => CityLocation.london);

final _cityDatasetService = CityDatasetService();

final rankingPreferencesProvider = StateProvider<RankingPreferences>(
  (ref) => RankingPreferences.balanced,
);

/// Provider que busca distritos por lat/lng da cidade selecionada
final districtRankingProvider =
    FutureProvider<List<DistrictScore>>((ref) async {
  final city = ref.watch(cityProvider);
  final preferences = ref.watch(rankingPreferencesProvider);
  if (city.lat == 0 && city.lng == 0) {
    return const <DistrictScore>[];
  }
  return _cityDatasetService.rankDistrictsByLocation(
    city.lat,
    city.lng,
    radiusKm: 25.0,
    preferences: preferences,
  );
});

final bestDistrictProvider = Provider<DistrictScore?>((ref) {
  final ranking = ref.watch(districtRankingProvider);
  return ranking.when(
    data: (ranked) => ranked.isEmpty ? null : ranked.first,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Aba ativa na navegação inferior (0..3).
final activeTabProvider = StateProvider<int>((ref) => 0);
