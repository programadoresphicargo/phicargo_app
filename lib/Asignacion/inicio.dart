import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:phicargo/Conexion/Conexion.dart';
import 'package:phicargo/Asignacion/asignacion.dart';
import 'package:phicargo/nav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final FlutterTts flutterTts = FlutterTts();

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  speak() async {
    await flutterTts.setLanguage("es-MX");
    await flutterTts.setPitch(1);
    await flutterTts.speak(
        'Asignacion de viaje. Tienes un tiempo limite para seleccionar un viaje. cualquier duda favor de comunicarse con su ejecutiva. Revisa tu conexion a internet para no tener contratiempos,Para ver los viajes disponibles presiona el boton iniciar.');
    print(await flutterTts.getVoices);
  }

  @override
  void initState() {
    speak();
    super.initState();
  }

  void obtener_hora_salida() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? val = prefs.getString('id');

      var response = await http.post(
          Uri.parse('${conexion}phicargo/app/asignacion/hora_salida.php'),
          body: {
            'id': val.toString(),
          }).timeout(const Duration(seconds: 90));
      var data = response.body;

      String hora = jsonDecode(data)['FH_SALIDA'].toString();

      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => ViajeAsignacion(
            hora_salida: hora,
          ),
        ),
        (route) => false,
      );
    } on FormatException catch (e) {
      print('ERROR');
    } on TimeoutException catch (e) {
      print('ERROR');
    } on Error catch (e) {
      print('ERROR');
    } on SocketException catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 22, 22, 22),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/fondo4.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.30,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 22, 22, 22),
                    Color.fromARGB(255, 22, 22, 22).withOpacity(0.8),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    "Asignación\nde viaje",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Tienes un tiempo limite para seleccionar un viaje, cualquier duda favor de comunicarse con su ejecutiva.",
                    style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          flutterTts.stop();
                        });
                        obtener_hora_salida();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 34, 69, 151),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          )),
                      child: const Text(
                        "Iniciar",
                        style: TextStyle(
                            fontSize: 17,
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) => Nav(
                              selectedIndex: 0,
                            ),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 154, 4, 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          )),
                      child: const Text(
                        "Volver",
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
