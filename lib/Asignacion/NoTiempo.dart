import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:phicargo/Conexion/Conexion.dart';
import 'package:phicargo/nav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NoTiempo extends StatefulWidget {
  const NoTiempo({super.key});

  @override
  State<NoTiempo> createState() => _NoTiempoState();
}

class _NoTiempoState extends State<NoTiempo> {
  var hora = '';

  @override
  void initState() {
    super.initState();
    horario();
  }

  void horario() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? val = prefs.getString('id');

      var response = await http.post(
          Uri.parse('${conexion}phicargo/app/asignacion/obtener_horario.php'),
          body: {
            'id': val.toString(),
          }).timeout(const Duration(seconds: 90));
      var data = response.body;
      print(data);
      setState(() {
        hora = data.toString();
      });
    } on TimeoutException catch (e) {
      print('ERROR');
    } on Error catch (e) {
      print(e.toString());
    } on SocketException catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 22, 22, 22),
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/mio.jpg",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * .1,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "¡No es tu turno para\nescoger viaje!",
                      style: TextStyle(
                          fontSize: 27,
                          color: Color.fromARGB(255, 255, 255, 255)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Entrada:\n' + hora,
                      // ignore: prefer_const_constructors
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 255, 255, 255)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Intentalo más tarde...",
                      style: TextStyle(
                          fontSize: 17,
                          color: Color.fromARGB(255, 255, 255, 255)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            child: const Text(
                              'Volver luego',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 154, 4, 4),
                              side: BorderSide(
                                  color: Color.fromARGB(255, 154, 4, 4),
                                  width: 1),
                              minimumSize: Size(150, 50),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Nav(
                                          selectedIndex: 0,
                                        )),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onWillPop: () async => false,
    );
  }
}
