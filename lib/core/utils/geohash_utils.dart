const _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

class GeohashUtils {
  static String encode(double lat, double lon, {int precision = 12}) {
    if (lat < -90.0 || lat > 90.0 || lon < -180.0 || lon > 180.0) {
      throw ArgumentError('Coordinates out of range');
    }

    var idx = 0;
    var bit = 0;
    var evenBit = true;
    var geohash = '';

    var latMin = -90.0;
    var latMax = 90.0;
    var lonMin = -180.0;
    var lonMax = 180.0;

    while (geohash.length < precision) {
      if (evenBit) {
        // Bisect longitude
        var lonMid = (lonMin + lonMax) / 2;
        if (lon >= lonMid) {
          idx = idx * 2 + 1;
          lonMin = lonMid;
        } else {
          idx = idx * 2;
          lonMax = lonMid;
        }
      } else {
        // Bisect latitude
        var latMid = (latMin + latMax) / 2;
        if (lat >= latMid) {
          idx = idx * 2 + 1;
          latMin = latMid;
        } else {
          idx = idx * 2;
          latMax = latMid;
        }
      }

      evenBit = !evenBit;

      if (++bit == 5) {
        geohash += _base32[idx];
        bit = 0;
        idx = 0;
      }
    }

    return geohash;
  }
}
