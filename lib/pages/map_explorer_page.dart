import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/city_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/photo_gallery.dart';

const _photos = [
  'assets/images/neighborhood-1.jpg',
  'assets/images/neighborhood-2.jpg',
  'assets/images/neighborhood-3.jpg',
  'assets/images/neighborhood-4.jpg',
];

class MapExplorerPage extends ConsumerStatefulWidget {
  const MapExplorerPage({super.key});

  @override
  ConsumerState<MapExplorerPage> createState() => _MapExplorerPageState();
}

class _MapExplorerPageState extends ConsumerState<MapExplorerPage> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers(double lat, double lng) {
    final center = LatLng(lat, lng);
    final neighborhoods = [
      _Neighborhood('Bairro A', LatLng(lat + 0.012, lng - 0.015)),
      _Neighborhood('Bairro B', LatLng(lat - 0.008, lng + 0.018)),
      _Neighborhood('Bairro C', LatLng(lat + 0.015, lng + 0.010)),
    ];

    return {
      Marker(
        markerId: const MarkerId('center'),
        position: center,
        icon: BitmapDescriptor.defaultMarkerWithHue(8.0),
      ),
      for (final n in neighborhoods)
        Marker(
          markerId: MarkerId(n.name),
          position: n.pos,
          infoWindow: InfoWindow(title: n.name),
          icon: BitmapDescriptor.defaultMarkerWithHue(8.0),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final city = ref.watch(cityProvider);
    final center = LatLng(city.lat, city.lng);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: center,
                          zoom: 13,
                        ),
                        markers: _buildMarkers(city.lat, city.lng),
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        mapToolbarEnabled: false,
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Chip(text: city.name, background: Colors.white),
                            const _Chip(
                              text: '4 locais',
                              background: AppColors.coral,
                              foreground: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      border: Border(top: BorderSide(color: AppColors.border)),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                city.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.foreground,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.coralLight,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                '85% Match',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.coralDark),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Row(
                          children: [
                            Icon(LucideIcons.star,
                                size: 14, color: AppColors.warning),
                            SizedBox(width: 6),
                            Text('4.7 · Vibrante & Criativo · Seguro',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.mutedForeground)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Expanded(child: _Stat('Média/Noite', r'$50')),
                            SizedBox(width: 12),
                            Expanded(child: _Stat('Caminhabilidade', '88')),
                            SizedBox(width: 12),
                            Expanded(child: _Stat('Cafés', '90+')),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Fotos da Comunidade',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.foreground)),
                            TextButton(
                              onPressed: () => PhotoGalleryDialog.show(context,
                                  photos: _photos),
                              style: TextButton.styleFrom(
                                  foregroundColor: AppColors.coral,
                                  padding: EdgeInsets.zero),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Ver todas',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                  Icon(LucideIcons.chevronRight, size: 14),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 112,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _photos.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (_, i) => GestureDetector(
                              onTap: () => PhotoGalleryDialog.show(context,
                                  photos: _photos, initialIndex: i),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  _photos[i],
                                  width: 112,
                                  height: 112,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Neighborhood {
  final String name;
  final LatLng pos;
  _Neighborhood(this.name, this.pos);
}

class _Chip extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;

  const _Chip({
    required this.text,
    required this.background,
    this.foreground = AppColors.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: foreground)),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}
