import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  MapUtils._();

  static Future<void> openMap(String coordenadas) async {
    final dateList = coordenadas.split(" ");

    var latitud = dateList[0];
    var longitud = dateList[2];

    final Uri googleurl = Uri.parse(
        "https://www.google.com/maps?q=$latitud, $longitud&hl=es-PY&gl=py&shorturl=1");

    await launch(
        "https://www.google.com/maps?q=$latitud, $longitud&hl=es-PY&gl=py&shorturl=1");
  }
}

class MapUtilsCoord {
  MapUtilsCoord._();

  static Future<void> openMap(String latitud, String longitud) async {
    final Uri googleurl = Uri.parse(
        "https://www.google.com/maps?q=$latitud, $longitud&hl=es-PY&gl=py&shorturl=1");

    await launch(
        "https://www.google.com/maps?q=$latitud, $longitud&hl=es-PY&gl=py&shorturl=1");
  }
}
