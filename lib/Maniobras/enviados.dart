import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:phicargo/Maniobras/vista.dart';
import 'package:phicargo/Metodos/diferencia_tiempo.dart';
import 'package:phicargo/Estatus/maps.dart';
import 'package:phicargo/nav.dart';
import 'package:phicargo/Conexion/Conexion.dart';

class Status_Enviados_Maniobras extends StatefulWidget {
  late String id_cp;
  late String referencia;
  late String tipo;

  Status_Enviados_Maniobras({
    required this.referencia,
    required this.id_cp,
    required this.tipo,
  });

  @override
  _Status_Enviados_Maniobras_State createState() =>
      _Status_Enviados_Maniobras_State();
}

class _Status_Enviados_Maniobras_State
    extends State<Status_Enviados_Maniobras> {
  var data;
  var length;

  @override
  void initState() {
    super.initState();
    getStatus(widget.id_cp);
  }

  Future<void> getStatus(id_cp) async {
    try {
      final response = await http.post(
          Uri.parse('${conexion}phicargo/app/maniobras/status_enviados.php'),
          body: {
            'id_cp': id_cp.toString(),
            'tipo': widget.tipo.toString(),
          }).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
        length = jsonDecode(response.body).length;
      } else {
        print('AHSCULT');
      }
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
      getStatus(widget.id_cp);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (AppBar(
          backgroundColor: widget.tipo == 'Retiro'
              ? const Color.fromARGB(255, 182, 229, 98)
              : Colors.amber,
          title: const Text(
            'Enviados',
            style: TextStyle(
                fontFamily: 'Product Sans', fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                print(1);
                Navigator.of(context).pop();
              } else {
                print(2);
                Navigator.of(context).push(
                  CupertinoPageRoute(
                      builder: (context) => Nav(
                            selectedIndex: 4,
                          )),
                );
              }
            },
          ))),
      body: RefreshIndicator(
        onRefresh: refresh,
        color: Colors.white,
        backgroundColor: const Color.fromARGB(255, 182, 229, 98),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: getStatus(widget.id_cp),
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
                        return Container(
                          child: Column(
                            children: [
                              ReusbaleRow(
                                index: index,
                                length: length,
                                status: data[index]['status'].toString(),
                                comentarios:
                                    data[index]['comentarios'].toString(),
                                fecha_hora:
                                    data[index]['fecha_envio'].toString(),
                                evidencia: data[index]['nombre'].toString(),
                                latitud: data[index]['latitud'].toString(),
                                longitud: data[index]['longitud'].toString(),
                                calle: data[index]['calle'].toString(),
                                codigo_postal:
                                    data[index]['codigo_postal'].toString(),
                                localidad: data[index]['localidad'].toString(),
                                sublocalidad:
                                    data[index]['sublocalidad'].toString(),
                                tipo: data[index]['tipo'].toString(),
                                id_cp: data[index]['id_cp'].toString(),
                              ),
                            ],
                          ),
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
  String id_cp;

  String latitud;
  String longitud;
  String calle;
  String localidad;
  String sublocalidad;
  String codigo_postal;
  String tipo;

  String status;
  String comentarios;
  String fecha_hora;
  String evidencia;
  int length;
  int index;

  ReusbaleRow(
      {Key? key,
      required this.id_cp,
      required this.length,
      required this.index,
      required this.latitud,
      required this.longitud,
      required this.calle,
      required this.localidad,
      required this.sublocalidad,
      required this.codigo_postal,
      required this.status,
      required this.comentarios,
      required this.evidencia,
      required this.fecha_hora,
      required this.tipo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    BoxDecoration boxDecoration;
    if (tipo == 'Retiro') {
      boxDecoration = BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 0, 227, 201),
            spreadRadius: -1,
            blurRadius: 0,
            offset: Offset(-4, 0),
          ),
        ],
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      );
    } else {
      boxDecoration = BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 253, 110, 0),
            spreadRadius: -1,
            blurRadius: 0,
            offset: Offset(-4, 0),
          ),
        ],
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 25),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 15,
                height: 10,
                decoration: BoxDecoration(
                  color: tipo == 'Retiro'
                      ? const Color.fromARGB(255, 0, 227, 201)
                      : Colors.amber.shade900,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(5),
                  ),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                width: MediaQuery.of(context).size.width - 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                          text: fecha_hora,
                          style: const TextStyle(
                            fontFamily: 'Product Sans',
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
                      printTime(fecha_hora.toString()),
                      style: const TextStyle(
                        fontFamily: 'Product Sans',
                        color: Colors.grey,
                      ),
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
            decoration: boxDecoration,
            margin: const EdgeInsets.only(right: 20, left: 30),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(
                    fontFamily: 'Product Sans',
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
                    fontFamily: 'Product Sans',
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
                              fontFamily: 'Product Sans',
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            '$latitud $longitud $calle $localidad $sublocalidad $codigo_postal',
                            style: const TextStyle(
                              fontFamily: 'Product Sans',
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
                              fontFamily: 'Product Sans',
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
                          backgroundColor: tipo == 'Retiro'
                              ? const Color.fromARGB(255, 182, 229, 98)
                              : Colors.amber.shade900,
                          elevation: 0,
                          textStyle: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          MapUtilsCoord.openMap(
                              latitud.toString(), longitud.toString());
                        },
                        child: const Text(
                          'Ver en Google Maps',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Product Sans', fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Visibility(
                      visible: evidencia == 'null' ? false : true,
                      child: Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: tipo == 'Retiro'
                                ? Color.fromARGB(255, 0, 227, 201)
                                : Colors.amber,
                            elevation: 0,
                            textStyle: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Vista_foto(
                                  evidencia: evidencia,
                                  id_cp: id_cp,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Evidencia',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Product Sans',
                            ),
                          ),
                        ),
                      ),
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
