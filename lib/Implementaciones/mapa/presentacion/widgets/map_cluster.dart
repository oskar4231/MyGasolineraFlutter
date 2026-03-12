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
  Marker _buildClusterMarker(LayerCluster<Gasolinera> cluster, BitmapDescriptor dynamicIcon) {
    return Marker(
      markerId: MarkerId('cluster_${cluster.uuid}'),
      position: LatLng(cluster.latitude, cluster.longitude),
      icon: dynamicIcon,
      anchor: const Offset(0.5, 1.0),
      zIndexInt: 5,
    );
  }

  /// Actualiza los marcadores mostrados en la cámara actual de formá asíncrona
  Future<void> updateClusterMarkers(
      GoogleMapController mapController, CameraPosition position) async {
    if (clusterManager == null) return;

    final visibleRegion = await mapController.getVisibleRegion();
    
    // Obtener marcadores en la región visible (añadimos padding para que no desaparezcan al borde)
    final dLat = (visibleRegion.northeast.latitude - visibleRegion.southwest.latitude) * 0.2;
    final dLng = (visibleRegion.northeast.longitude - visibleRegion.southwest.longitude) * 0.2;

    final searchResult = clusterManager!.search(
      visibleRegion.southwest.longitude - dLng,
      visibleRegion.southwest.latitude - dLat,
      visibleRegion.northeast.longitude + dLng,
      visibleRegion.northeast.latitude + dLat,
      position.zoom.toInt(),
    );

    // Verificar si hay algún cluster presente en la búsqueda
    bool hasClusters = false;
    for (var element in searchResult) {
      element.handle(
        cluster: (_) { hasClusters = true; },
        point: (_) {}
      );
      if (hasClusters) break;
    }

    // Preparar lista de tareas para generar iconos asíncronos en paralelo
    List<Future<Marker?>> markerFutures = searchResult.map((element) async {
      Marker? marker;
      await element.handle(
        cluster: (clusterData) async {
            // Generar icono dinámico con el número encima 
            final customIcon = await markerHelper.getClusterMarker(clusterData.childPointCount);
            marker = _buildClusterMarker(clusterData, customIcon);
        },
        point: (pointData) async {
            // Mostrar gasolineras individuales solo si NO hay clusters presentes
            if (!hasClusters) {
              marker = _buildIndexMarker(pointData.originalPoint);
            }
        }
      );
      return marker;
    }).toList();

    // Esperar a que se generen todos
    final resultMarkers = await Future.wait(markerFutures);
    Set<Marker> newMarkers = resultMarkers.whereType<Marker>().toSet();

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
        radius: 120, // Distancia razonable en píxeles de agrupación
        minPoints: 5, // Tienen que ser mínimo 5 gasolineras para formar un cluster
        maxZoom: 15, // A partir del zoom 16 se deshacen todos los clusters
      )..load(items);
      
      if (mapController != null && position != null) {
          await updateClusterMarkers(mapController, position);
      }
  }

  /// Hook que el State principal debe implementar para hacer zoom al tocar un cluster.
  void onClusterTap(LatLng location, double zoom);
}
