import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../location/domain/entities/location_entity.dart';
import '../../../location/presentation/controllers/location_controller.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  MapLibreMapController? _mapController;
  Symbol? _userMarker;
  bool _isMapStyleLoaded = false;

  // Default initial camera position (Hồ Chí Minh, Việt Nam)
  static const CameraPosition _kInitialCameraPosition = CameraPosition(
    target: LatLng(10.776889, 106.700806),
    zoom: 14.0,
  );

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }

  void _onStyleLoadedCallback() {
    setState(() {
      _isMapStyleLoaded = true;
    });
    // If location is already available when map loads, animate to it
    final state = ref.read(locationControllerProvider);
    if (state is AsyncData<LocationEntity>) {
      _updateUserLocationOnMap(state.value);
    }
  }

  void _updateUserLocationOnMap(LocationEntity location) {
    if (_mapController == null || !_isMapStyleLoaded) return;

    final target = LatLng(location.latitude, location.longitude);

    // 1. Move/Animate Camera to new position without rebuilding Widget Tree
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(target, 16.0),
    );

    // 2. Add or update location marker on MapLibre
    if (_userMarker == null) {
      _mapController!
          .addSymbol(
            SymbolOptions(
              geometry: target,
              iconImage: 'custom-marker', // Default or system icon
              iconSize: 1.5,
              textField: 'Vị trí của bạn',
              textOffset: const Offset(0, 1.5),
              textColor: '#38BDF8',
              textSize: 12.0,
            ),
          )
          .then((symbol) => _userMarker = symbol);
    } else {
      _mapController!.updateSymbol(
        _userMarker!,
        SymbolOptions(geometry: target),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Spec 1.5: ref.listen to locationControllerProvider to animate camera performance-wise
    ref.listen<AsyncValue<LocationEntity>>(
      locationControllerProvider,
      (previous, next) {
        next.whenData((location) {
          _updateUserLocationOnMap(location);
        });
      },
    );

    final locationState = ref.watch(locationControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        title: const Text(
          'Map K — MapLibre & GPS Channel',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF090D16),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: Color(0xFF38BDF8)),
            onPressed: () {
              ref.read(locationControllerProvider.notifier).refreshLocation();
            },
            tooltip: 'Lấy lại vị trí',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. MapLibreMap Native View
          MapLibreMap(
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoadedCallback,
            initialCameraPosition: _kInitialCameraPosition,
            styleString: 'https://tiles.openfreemap.org/styles/liberty',
            myLocationEnabled: true,
            myLocationTrackingMode: MyLocationTrackingMode.tracking,
            compassEnabled: true,
          ),

          // 2. Overlay Top Card showing live location details
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: locationState.when(
                data: (loc) => Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF38BDF8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.gps_fixed_rounded,
                        color: Colors.black,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'GPS (MethodChannel Native)',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lat: ${loc.latitude.toStringAsFixed(6)}, Lng: ${loc.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                loading: () => const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF38BDF8),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Đang lấy vị trí từ Platform Channel...',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
                error: (err, _) => Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lỗi GPS: $err',
                        style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
