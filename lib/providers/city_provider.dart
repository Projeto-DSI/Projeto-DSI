import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city_location.dart';

// City
class CityNotifier extends Notifier<CityLocation> {
  @override
  CityLocation build() => const CityLocation(
        name: 'São Paulo',
        lat: -23.5505,
        lng: -46.6333,
      );

  void setCity(CityLocation city) => state = city;
}

final cityProvider = NotifierProvider<CityNotifier, CityLocation>(
  CityNotifier.new,
);

// Tab
class ActiveTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int tab) => state = tab;
}

final activeTabProvider = NotifierProvider<ActiveTabNotifier, int>(
  ActiveTabNotifier.new,
);