class PolygonUtils {
  /// Verifica si una coordenada (lat, lng) está dentro de un polígono.
  /// El polígono es una lista de puntos [lat, lng].
  static bool isPointInPolygon(
      double lat, double lng, List<List<double>> polygon) {
    bool isInside = false;
    int i, j = polygon.length - 1;

    for (i = 0; i < polygon.length; i++) {
      double lati = polygon[i][0];
      double lngi = polygon[i][1];
      double latj = polygon[j][0];
      double lngj = polygon[j][1];

      // Algoritmo Ray-Casting
      if (((lati > lat) != (latj > lat)) &&
          (lng < (lngj - lngi) * (lat - lati) / (latj - lati) + lngi)) {
        isInside = !isInside;
      }
      j = i;
    }

    return isInside;
  }
}
