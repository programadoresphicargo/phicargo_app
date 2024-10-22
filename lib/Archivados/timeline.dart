import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:phicargo/Metodos/diferencia_tiempo.dart';
import 'package:phicargo/Estatus/maps.dart';
import 'package:phicargo/estatus/convertir_tiempos.dart';
import 'package:phicargo/estatus/vista.dart';
import 'package:phicargo/Conexion/Conexion.dart';
import 'package:url_launcher/url_launcher.dart';

class TimeLine extends StatefulWidget {
  late String id_viaje;
  late String referencia;

  TimeLine({required this.referencia, required this.id_viaje});

  @override
  _TimeLineState createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {
  var data;
  var length;

  @override
  void initState() {
    super.initState();
    getStatus(widget.id_viaje);
  }

  Future<void> getStatus(id_viaje) async {
    try {
      final response = await http.post(
          Uri.parse('${conexion}phicargo/aplicacion/estatus/timeline.php'),
          body: {
            'id_viaje': id_viaje.toString(),
          }).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        print('--');
        data = jsonDecode(response.body.toString());
        length = jsonDecode(response.body).length;
        print(length);
      } else {}
    } on TimeoutException catch (e) {
    } on Error catch (e) {
      print('ERROR :(');
    } on SocketException catch (e) {
      print('ERROR 2: NO HAY INTERNET');
    } on FormatException catch (e) {
      print('ERROR 3: FORMATO ERRONEO');
    }
  }

  Future refresh() async {
    setState(() {
      getStatus(widget.referencia);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refresh,
        color: Colors.white,
        backgroundColor: Color.fromARGB(255, 34, 69, 151),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: getStatus(widget.referencia),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset('assets/car.json', height: 150),
                            const SizedBox(
                              height: 15,
                            ),
                            const Text(
                              'Obteniendo status, espere...',
                              style: TextStyle(
                                color: Color.fromARGB(255, 34, 69, 151),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (length == 0) {
                    return Center(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/status/timeline.png',
                              height: 100,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'No hay status enviados a este viaje.',
                              style: TextStyle(
                                color: Color.fromARGB(255, 34, 69, 151),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: data == null ? 0 : data.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ReusbaleRow(
                              index: index,
                              length: length,
                              ubicacion: data[index]['status'].toString(),
                              status: data[index]['status'].toString(),
                              comentarios:
                                  data[index]['display_name'].toString(),
                              fecha_hora: data[index]['date_time'].toString(),
                              evidencia: data[index]['x_foto'].toString(),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ReusbaleRow extends StatelessWidget {
  String ubicacion;
  String status;
  String comentarios;
  String fecha_hora;
  String evidencia;
  int length;
  int index;

  ReusbaleRow({
    Key? key,
    required this.length,
    required this.index,
    required this.ubicacion,
    required this.status,
    required this.comentarios,
    required this.evidencia,
    required this.fecha_hora,
  }) : super(key: key);
  late DateTime endDate = DateTime.parse(fecha_hora);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 15,
                height: 10,
                decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(5),
                    )),
              ),
              const SizedBox(
                width: 15,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                          text: convertir_hora(fecha_hora),
                          style: const TextStyle(
                            fontFamily: 'Helvetica',
                            color: Colors.black,
                          ),
                          children: const [
                            TextSpan(
                              text: "",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                              ),
                            )
                          ]),
                    ),
                    Text(
                      printTime(fecha_hora),
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Colors.blue,
                    spreadRadius: -1,
                    blurRadius: 0,
                    offset: Offset(-4, 0),
                  ),
                ],
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.only(right: 20, left: 30),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  status,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Ubicación",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            ubicacion,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.message,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Comentarios",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            comentarios == 'False'
                                ? 'Sin Comentarios'
                                : comentarios,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.blue.shade700,
                          elevation: 0,
                          textStyle: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          MapUtils.openMap(ubicacion);
                        },
                        child: const Text(
                          'Ver en Google Maps',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 11,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: evidencia != 'false'
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.indigo,
                                elevation: 0,
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Vista(
                                      evidencia: evidencia,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Evidencia',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontFamily: 'Helvetica'),
                              ),
                            )
                          : Container(),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
