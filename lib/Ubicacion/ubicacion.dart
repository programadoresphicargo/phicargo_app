// location_service.dart
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;

class LocationService {
  final loc.Location _location = loc.Location();

  Future<loc.LocationData?> getCurrentLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      // Solicitar habilitar el servicio
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    // Verificar los permisos
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return null;
      }
    }

    // Obtener la ubicación actual
    return await _location.getLocation();
  }
}

class GeolocationService {
  Future<List<Placemark>> getPlacemarks(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      return placemarks;
    } catch (e) {
      print('Error obteniendo la dirección: $e');
      return [];
    }
  }
}
