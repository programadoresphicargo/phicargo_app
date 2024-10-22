import 'package:shared_preferences/shared_preferences.dart';

Future<void> almacenar_usuario(
    id, nombre, contrasena, modalidad, peligroso, tipo) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('id', id);
  await prefs.setString('nombre', nombre);
  await prefs.setString('contrasena', contrasena);
  await prefs.setString('modalidad', modalidad);
  await prefs.setString('peligroso', peligroso);
  await prefs.setString('tipo', tipo);
}
