import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:phicargo/Contactos/modelo_departamento.dart';

import '../Conexion/Conexion.dart';

class Services {
  static Future<List<Departamento>> getPhotos() async {
    try {
      final response = await http.get(
          Uri.parse("${conexion}/phicargo/app/contactos/getDepartamentos.php"));
      if (response.statusCode == 200) {
        List<Departamento> list = parsePhotos(response.body);
        return list;
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static List<Departamento> parsePhotos(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<Departamento>((json) => Departamento.fromJson(json))
        .toList();
  }
}
