import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:phicargo/Alertas/alerta.dart';
import 'package:phicargo/Asignacion/inicio.dart';
import 'package:phicargo/Conexion/Conexion.dart';
import '../../main.dart';
import 'Detalles.dart';

class TurnosList extends StatefulWidget {
  late String sucursal;

  TurnosList({required this.sucursal});
  @override
  _TurnosListState createState() => _TurnosListState();
}

class _TurnosListState extends State<TurnosList> {
  late String data;
  late String json_title;
  bool loading = true;
  var superheros_length;
  @override
  void initState() {
    loading = true;
    super.initState();
    getData();

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Color.fromARGB(255, 34, 69, 151),
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        }

        await flutterTts.setLanguage("es-MX");
        await flutterTts.setPitch(1);
        await flutterTts.speak(notification!.title! + notification!.body!);
      },
    );
  }

  void getData() async {
    try {
      http.Response response;
      response = await http.post(
          Uri.parse('${conexion}/phicargo/app/turnos/getTurnos.php'),
          body: {'sucursal': widget.sucursal});
      if (response.statusCode == 200) {
        data = response.body;
        setState(() {
          loading = false;
          superheros_length = jsonDecode(data);
          print(superheros_length.length);
        });
      } else {
        print(response.statusCode);
      }
    } on Error catch (e) {
      print('ERROR #1');
    } on TimeoutException catch (e) {
      print('ERROR #2');
    } on SocketException catch (e) {
      print('SIN CONEXIÓN A INTERNET');
      // ignore: use_build_context_synchronously
      Flushbar(
        icon: const Icon(
          Icons.wifi_off_sharp,
          color: Colors.white,
          size: 25,
        ),
        backgroundColor: Color.fromARGB(255, 154, 4, 4),
        duration: const Duration(seconds: 5),
        message: "Revise su conexión a internet e intentelo de nuevo.",
        messageSize: 13,
        titleText: const Text("Sin internet",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ).show(context);
    }
  }

  Future refresh() async {
    getData();
  }

  void dispose() {
    super.dispose();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
            onRefresh: refresh,
            color: Colors.white,
            backgroundColor: Color.fromARGB(255, 34, 69, 151),
            child: Container(
              color: Color.fromARGB(255, 248, 246, 246),
              child: loading == true
                  ? Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        child: Column(children: [
                          Lottie.asset('assets/car.json'),
                          const SizedBox(
                            width: 15,
                          ),
                          const Text(
                            'Cargando...',
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 34, 69, 151)),
                          )
                        ]),
                      ),
                    )
                  : superheros_length.length == 0
                      ? Center(
                          child: Container(
                            width: 300,
                            height: 200,
                            child: Column(children: [
                              Image.asset(
                                'assets/status/driver.png',
                                width: 80,
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              const Text(
                                'No existen turnos en esta sección.',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 34, 69, 151)),
                              )
                            ]),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(20),
                          itemCount: superheros_length == null
                              ? 0
                              : superheros_length.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: (context) => Detalles(
                                          turno: index,
                                          nombre: (jsonDecode(data)[index]
                                                  ['nombre_operador']
                                              .toString()),
                                          eco: (jsonDecode(data)[index]
                                                  ['unidad']
                                              .toString()),
                                          fecha: (jsonDecode(data)[index]
                                                  ['fecha_llegada']
                                              .toString()),
                                          hora: (jsonDecode(data)[index]
                                                  ['hora_llegada']
                                              .toString()),
                                          comentarios: (jsonDecode(data)[index]
                                                  ['comentarios']
                                              .toString()),
                                        ));
                              },
                              child: jobComponent(
                                count: index,
                                nombre: (jsonDecode(data)[index]
                                        ['nombre_operador']
                                    .toString()),
                                eco: (jsonDecode(data)[index]['unidad']
                                    .toString()),
                                fecha: (jsonDecode(data)[index]['fecha_llegada']
                                    .toString()),
                                hora: (jsonDecode(data)[index]['hora_llegada']
                                    .toString()),
                                comentarios: (jsonDecode(data)[index]
                                        ['comentarios']
                                    .toString()),
                              ),
                            );
                          },
                        ),
            )));
  }
}

jobComponent(
    {required int count,
    required String nombre,
    required String eco,
    required String fecha,
    required String hora,
    required String comentarios}) {
  return Container(
    padding: EdgeInsets.all(10),
    margin: EdgeInsets.only(bottom: 15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 0,
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset('assets/usuario.png'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nombre,
                            style: TextStyle(
                                color: Color.fromARGB(255, 34, 69, 151),
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Image.asset(
                              'assets/status/car.png',
                              height: 30,
                              color: Colors.grey[600],
                            ),
                            Text(eco,
                                style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 7),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color.fromARGB(255, 34, 69, 151)),
              child: Row(
                children: [
                  Icon(Icons.numbers_sharp,
                      color: Color.fromARGB(255, 255, 255, 255)),
                  Text((count + 1).toString(),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255)))
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Color.fromARGB(255, 34, 69, 151)
                                  .withAlpha(20)),
                          child: Text('LLEGADA: ' + fecha + ' ' + hora,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
