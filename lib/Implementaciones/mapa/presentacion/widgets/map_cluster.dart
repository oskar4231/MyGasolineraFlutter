import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supercluster/supercluster.dart';
import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';
import 'package:my_gasolinera/Implementaciones/mapa/data/services/map_helpers.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';
import 'dart:async';

/// Mixin que encapsula toda la lógica del ClusterManager con Supercluster
mixin MapClusterMixin<T extends StatefulWidget> on State<T> {
  // ── Dependencias que el State principal debe proveer ───────────────────────
  MarkerHelper get markerHelper;
  List<String> get favoritosIds;
  double get currentZoom;
  Future<void> Function(Gasolinera, bool) get onMarkerTap;

  // ── Estado del cluster ─────────────────────────────────────────────────────
  Supercluster<Gasolinera>? clusterManager;
  Set<Marker> clusterMarkers = {};

  /// Inicializa el ClusterManager. Llamar en initState().
  void initClusterManager({GoogleMapController? mapController}) {}

  /// Construye un marcador individual de gasolinera
  Marker _buildIndexMarker(Gasolinera gasolinera) {
    return markerHelper.createMarker(
      gasolinera,
      favoritosIds,
      (g, fav) => onMarkerTap(g, fav),
    );
  }

  /// Construye un marcador que representa una agrupación (Decluttering Mode).
  Marker _buildClusterMarker(LayerCluster<Gasolinera> cluster) {
    return Marker(
      markerId: MarkerId('cluster_${cluster.uuid}'),
      position: LatLng(cluster.latitude, cluster.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      anchor: const Offset(0.5, 1.0),
      zIndexInt: 5,
      onTap: () {
        AppLogger.debug('Zoom in suave al cluster: ${currentZoom + 2.0}',
            tag: 'MapCluster');
        onClusterTap(LatLng(cluster.latitude, cluster.longitude), currentZoom + 2.0);
      },
    );
  }

  /// Actualiza los marcadores mostrados en la cámara actual de formá asíncrona
  Future<void> updateClusterMarkers(
      GoogleMapController mapController, CameraPosition position) async {
    if (clusterManager == null) return;

    final visibleRegion = await mapController.getVisibleRegion();
    
    // Obtener marcadores en la región visible
    final searchResult = clusterManager!.search(
      visibleRegion.southwest.longitude,
      visibleRegion.southwest.latitude,
      visibleRegion.northeast.longitude,
      visibleRegion.northeast.latitude,
      position.zoom.toInt(),
    );

    Set<Marker> newMarkers = {};
    for (var element in searchResult) {
       element.handle(
           cluster: (clusterData) {
               newMarkers.add(_buildClusterMarker(clusterData));
           },
           point: (pointData) {
               newMarkers.add(_buildIndexMarker(pointData.originalPoint));
           }
       );
    }

    if (mounted) {
      setState(() {
        clusterMarkers = newMarkers;
      });
    }
  }

  /// Sobrescribe los items en el Supercluster
  Future<void> setItems(List<Gasolinera> items, GoogleMapController? mapController, CameraPosition? position) async {
      clusterManager = SuperclusterImmutable<Gasolinera>(
        getX: (g) => g.lng,
        getY: (g) => g.lat,
      )..load(items);
      
      if (mapController != null && position != null) {
          await updateClusterMarkers(mapController, position);
      }
  }

  /// Hook que el State principal debe implementar para hacer zoom al tocar un cluster.
  void onClusterTap(LatLng location, double zoom);
}
