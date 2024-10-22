import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phicargo/Asignacion/NoProgramado.dart';
import 'package:phicargo/Asignacion/NoTiempo.dart';
import 'package:phicargo/Asignacion/SinInternet.dart';
import 'package:phicargo/Asignacion/inicio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:phicargo/Conexion/Conexion.dart';

class Opciones extends StatefulWidget {
  const Opciones({super.key});

  @override
  State<Opciones> createState() => _OpcionesState();
}

class _OpcionesState extends State<Opciones> {
  @override
  void initState() {
    super.initState();
    validar();
  }

  var data;

  void validar() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? val = prefs.getString('id');

      var response = await http.post(
          Uri.parse('${conexion}phicargo/app/asignacion/validacion.php'),
          body: {
            'id': val.toString(),
          }).timeout(const Duration(seconds: 90));
      data = response.body;
      switch (data) {
        case '1':
          print('CASO 1');

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoTiempo()),
          );
          break;
        case '2':
          print('CASO 2');

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Inicio()),
          );
          break;
        case '3':
          print('CASO 3');

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoProgramado()),
          );
          break;
        case '4':
          print('CASO 4');

          break;
        default:
          print('NINGUNO DE LOS ANTERIORES');
          break;
      }
    } on TimeoutException catch (e) {
      print('ERROR ?');
    } on Error catch (e) {
      print('ERROR !');
      print(data);
    } on SocketException catch (e) {
      print('ERROR 3d');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SinInternet()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 22, 22, 22),
    );
  }
}
