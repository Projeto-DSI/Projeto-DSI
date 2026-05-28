import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/city_location.dart';

/// Geocodificação via OpenStreetMap Nominatim.
/// Nominatim pede um User-Agent identificável — use algo como nome do app + contato.
class NominatimService {
  static const String _userAgent = 'BairroMatch/0.1 (contato@exemplo.com)';

  final Map<String, String?> _reverseCache = <String, String?>{};

  Map<String, String> _headers() {
    if (kIsWeb) {
      // Browsers do not allow overriding User-Agent headers.
      return const {'Accept': 'application/json'};
    }
    return const {
      'Accept': 'application/json',
      'User-Agent': _userAgent,
    };
  }

  Future<CityLocation?> searchCity(String city) async {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?format=json&q=${Uri.encodeComponent(city)}&limit=1&addressdetails=1&accept-language=pt-BR',
    );

    final res = await http.get(uri, headers: _headers());
    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body) as List<dynamic>;
    if (data.isEmpty) return null;

    final first = data.first as Map<String, dynamic>;
    final displayName = first['display_name'] as String? ?? city;
    final shortName = displayName.split(',').first.trim();

    return CityLocation(
      name: shortName,
      lat: double.parse(first['lat'].toString()),
      lng: double.parse(first['lon'].toString()),
    );
  }

  Future<String?> reverseNeighborhoodName(double lat, double lng) async {
    final key = '${lat.toStringAsFixed(5)},${lng.toStringAsFixed(5)}';
    if (_reverseCache.containsKey(key)) {
      return _reverseCache[key];
    }

    final webCompatible = await _reverseWithBigDataCloud(lat, lng);
    if (webCompatible != null && webCompatible.isNotEmpty) {
      _reverseCache[key] = webCompatible;
      return webCompatible;
    }

    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?format=jsonv2&lat=$lat&lon=$lng&zoom=18&addressdetails=1&accept-language=pt-BR',
    );

    final res = await http.get(uri, headers: _headers());
    if (res.statusCode != 200) {
      _reverseCache[key] = null;
      return null;
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final address = (data['address'] as Map<String, dynamic>?) ?? {};

    String? firstNonEmpty(List<String?> values) {
      for (final value in values) {
        if (value != null && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
      return null;
    }

    final neighborhood = firstNonEmpty([
      address['neighbourhood']?.toString(),
      address['suburb']?.toString(),
      address['quarter']?.toString(),
      address['city_district']?.toString(),
      address['borough']?.toString(),
      address['residential']?.toString(),
      address['road']?.toString(),
    ]);

    String? fromDisplayName() {
      final display = data['display_name']?.toString();
      if (display == null || display.trim().isEmpty) return null;
      final parts = display
          .split(',')
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList();
      for (final part in parts) {
        final lower = part.toLowerCase();
        if (lower == 'london' || lower == 'england' || lower == 'united kingdom') {
          continue;
        }
        if (RegExp(r'^\d+$').hasMatch(part)) continue;
        return part;
      }
      return null;
    }

    final resolved = neighborhood ?? fromDisplayName();
    _reverseCache[key] = resolved;
    return resolved;
  }

  Future<String?> _reverseWithBigDataCloud(double lat, double lng) async {
    final uri = Uri.parse(
      'https://api.bigdatacloud.net/data/reverse-geocode-client'
      '?latitude=$lat&longitude=$lng&localityLanguage=pt',
    );

    final res = await http.get(uri, headers: const {'Accept': 'application/json'});
    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    String? pick(Map<String, dynamic> obj, String key) {
      final value = obj[key]?.toString();
      if (value == null || value.trim().isEmpty) return null;
      return value.trim();
    }

    final locality = pick(data, 'locality');
    if (locality != null && locality.toLowerCase() != 'greater london') {
      return locality;
    }

    final city = pick(data, 'city');
    if (city != null && city.toLowerCase() != 'london') {
      return city;
    }

    final admin = data['localityInfo'] is Map<String, dynamic>
        ? data['localityInfo'] as Map<String, dynamic>
        : null;
    final administrative = admin?['administrative'] is List<dynamic>
        ? admin!['administrative'] as List<dynamic>
        : const <dynamic>[];

    for (final item in administrative) {
      if (item is! Map<String, dynamic>) continue;
      final name = item['name']?.toString().trim();
      if (name == null || name.isEmpty) continue;
      final lower = name.toLowerCase();
      if (lower == 'greater london' ||
          lower == 'london' ||
          lower == 'england' ||
          lower.contains('united kingdom')) {
        continue;
      }
      return name;
    }

    return null;
  }
}
