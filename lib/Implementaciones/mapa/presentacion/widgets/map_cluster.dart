import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart'
    as cluster_manager;
import 'package:my_gasolinera/Implementaciones/gasolineras/domain/models/gasolinera.dart';
import 'package:my_gasolinera/Implementaciones/mapa/data/services/map_helpers.dart';
import 'package:my_gasolinera/core/utils/app_logger.dart';

/// Mixin que encapsula toda la lógica del ClusterManager.
/// Úsalo en _MapWidgetState con: `with MapClusterMixin`
mixin MapClusterMixin<T extends StatefulWidget> on State<T> {
  // ── Dependencias que el State principal debe proveer ───────────────────────
  MarkerHelper get markerHelper;
  List<String> get favoritosIds;
  double get currentZoom;
  Future<void> Function(Gasolinera, bool) get onMarkerTap;

  // ── Estado del cluster ─────────────────────────────────────────────────────
  cluster_manager.ClusterManager<Gasolinera>? clusterManager;
  Set<Marker> clusterMarkers = {};

  /// Inicializa el ClusterManager. Llamar en initState().
  void initClusterManager() {
    clusterManager = cluster_manager.ClusterManager<Gasolinera>(
      [],
      _updateClusterMarkers,
      markerBuilder: _markerBuilder,
      levels: [1, 4.5, 8.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.5, 20.0],
      extraPercent: 0.2,
    );
    AppLogger.info('ClusterManager inicializado', tag: 'MapCluster');
  }

  /// Callback que el ClusterManager llama cuando cambian los marcadores.
  void _updateClusterMarkers(Set<Marker> markers) {
    if (mounted) {
      setState(() => clusterMarkers = markers);
      AppLogger.debug(
        'Marcadores de cluster actualizados: ${markers.length}',
        tag: 'MapWidget',
      );
    }
  }

  /// Builder de marcadores para clustering (Decluttering Mode).
  Future<Marker> _markerBuilder(dynamic cluster) async {
    final typedCluster = cluster as cluster_manager.Cluster<Gasolinera>;

    // ── Caso 1: Gasolinera individual → abrir info ─────────────────────────
    if (!typedCluster.isMultiple) {
      final gasolinera = typedCluster.items.first;
      final esFavorita = favoritosIds.contains(gasolinera.id);
      return markerHelper.createMarker(
        gasolinera,
        favoritosIds,
        (g, fav) => onMarkerTap(g, fav),
      );
    }

    // ── Caso 2: Clúster múltiple → Decluttering (mismo icono, zoom al tocar) ─
    final containsFavorite =
        typedCluster.items.any((g) => favoritosIds.contains(g.id));

    BitmapDescriptor icon;
    if (containsFavorite && markerHelper.favoriteGasStationIcon != null) {
      icon = markerHelper.favoriteGasStationIcon!;
    } else if (markerHelper.gasStationIcon != null) {
      icon = markerHelper.gasStationIcon!;
    } else {
      icon = BitmapDescriptor.defaultMarkerWithHue(
        containsFavorite
            ? BitmapDescriptor.hueViolet
            : BitmapDescriptor.hueOrange,
      );
    }

    return Marker(
      markerId: MarkerId(typedCluster.getId()),
      position: typedCluster.location,
      icon: icon,
      anchor: const Offset(0.5, 1.0),
      zIndex: containsFavorite ? 10.0 : 1.0,
      onTap: () {
        // Zoom suave al tocar un grupo
        AppLogger.debug(
          'Zoom in suave al cluster: ${currentZoom + 2.0}',
          tag: 'MapCluster',
        );
        // El mapController lo maneja el State principal a través del mixin
        onClusterTap(typedCluster.location, currentZoom + 2.0);
      },
    );
  }

  /// Hook que el State principal debe implementar para hacer zoom al tocar un cluster.
  void onClusterTap(LatLng location, double zoom);
}
