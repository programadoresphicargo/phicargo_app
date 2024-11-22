import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:phicargo/Alertas/alerta.dart';
import 'package:phicargo/Viajes/Enviados/estatus_enviados.dart';
import 'package:phicargo/viajes/contenedores.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phicargo/Conexion/Conexion.dart';

import '../Envio_evidencias/evidencia.dart';
import '../Seleccion_estatus/seleccion_estatus.dart';

class StatusPrincipal extends StatefulWidget {
  String id_viaje;
  StatusPrincipal({Key? key, required this.id_viaje}) : super(key: key);

  @override
  _StatusPrincipalState createState() => _StatusPrincipalState();
}

class _StatusPrincipalState extends State<StatusPrincipal> {
  var data;
  bool CorreosLigadosAViaje = false;

  Future<void> getViaje() async {
    try {
      final response = await http.post(
          Uri.parse('${conexion}phicargo/aplicacion/viajes/obtener_viaje.php'),
          body: {
            'id_viaje': widget.id_viaje.toString(),
          }).timeout(const Duration(seconds: 90));
      if (response.statusCode == 200) {
        data = jsonDecode(response.body.toString());
        print(data);
      } else {}
    } on TimeoutException catch (e) {
      print(e);
    } on Error catch (e) {
      print(e);
    } on SocketException catch (e) {
      print(e);
    } on FormatException catch (e) {
      print(e);
    }
  }

  Future refresh() async {
    print(widget.id_viaje);
    setState(() {
      getViaje();
    });
  }

  @override
  void initState() {
    getViaje();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refresh,
        color: Colors.white,
        backgroundColor: Color.fromARGB(255, 34, 69, 151),
        child: FutureBuilder(
          future: getViaje(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/car.json', height: 150),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      'Obteniendo viaje, favor espere un segundo...',
                      style: TextStyle(
                        color: Color.fromARGB(255, 34, 69, 151),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: data == null ? 0 : data.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: Column(
                      children: [
                        ReusbaleRow(
                          id: data[index]['id'].toString(),
                          nombre: data[index]['name'].toString(),
                          ejecutiva: data[index]['user_id'] != false
                              ? data[index]['user_id'][1].toString()
                              : '',
                          ruta: data[index]['route_id'] != false
                              ? data[index]['route_id'][1].toString()
                              : '',
                          vehiculo: data[index]['vehicle_id'] != false
                              ? data[index]['vehicle_id'][1].toString()
                              : '',
                          remolque1: data[index]['trailer1_id'] != false
                              ? data[index]['trailer1_id'][1].toString()
                              : '',
                          remolque2: data[index]['trailer2_id'] != false
                              ? data[index]['trailer2_id'][1].toString()
                              : '',
                          dolly: data[index]['dolly_id'] != false
                              ? data[index]['dolly_id'][1].toString()
                              : '',
                          cliente: data[index]['partner_id'] != false
                              ? data[index]['partner_id'][1].toString()
                              : '',
                          fecha: data[index]['date_start_real'].toString(),
                          validacion: data[index]['x_status_viaje'].toString(),
                          origen: data[index]['departure_id'] != false
                              ? data[index]['departure_id'][1].toString()
                              : '',
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class ReusbaleRow extends StatelessWidget {
  String id;
  String nombre;
  String ejecutiva;
  String origen;
  String ruta;
  String vehiculo;
  String remolque1;
  String remolque2;
  String dolly;
  String cliente;
  String fecha;
  String validacion;

  ReusbaleRow({
    Key? key,
    required this.id,
    required this.nombre,
    required this.ejecutiva,
    required this.origen,
    required this.ruta,
    required this.vehiculo,
    required this.remolque1,
    required this.remolque2,
    required this.dolly,
    required this.cliente,
    required this.fecha,
    required this.validacion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void Reportar() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString('id');

      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });

      try {
        final response = await http.post(
            Uri.parse('${conexion}phicargo/aplicacion/estatus/reportar.php'),
            body: {
              'id': id.toString(),
            }).timeout(const Duration(seconds: 90));
        if (response.body == '1') {
          Navigator.of(context).pop();
          print('Enviado');
          alerta_success('Reporte enviado', 'Se atenderá lo más pronto posible',
              Icon(Icons.check_circle), context);
        } else {
          Navigator.of(context).pop();
          print('Error, no enviado.');
        }
      } on TimeoutException catch (e) {
      } on Error catch (e) {
      } on SocketException catch (e) {
      } on FormatException catch (e) {}
    }

    return Container(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset('assets/carrito2.png'),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 7),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue.shade600),
                  child: Row(
                    children: [
                      const Text(
                        'Referencia \n de Viaje',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        (nombre),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(('ORIGEN:'),
                        style: TextStyle(
                          color: Color.fromARGB(255, 34, 69, 151),
                          fontSize: 15,
                        )),
                    const SizedBox(
                      height: 15,
                    ),
                    Text((origen),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20,
                        )),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(('RUTA:'),
                        style: TextStyle(
                          color: Color.fromARGB(255, 34, 69, 151),
                          fontSize: 15,
                        )),
                    const SizedBox(
                      height: 15,
                    ),
                    Text((ruta),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20,
                        )),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(('CLIENTE:'),
                        style: TextStyle(
                          color: Color.fromARGB(255, 34, 69, 151),
                          fontSize: 15,
                        )),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      (cliente),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(
              height: 15,
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KIT',
                    style: TextStyle(
                        fontSize: 15, color: Color.fromARGB(255, 34, 69, 151)),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                ('VEHÍCULO'),
                                style: TextStyle(
                                  color: Color.fromARGB(255, 34, 69, 151),
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text((vehiculo),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 15,
                                  )),
                            ]),
                      ),
                      Visibility(
                        visible: remolque1 == '' ? false : true,
                        child: Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                ('REMOLQUE 1'),
                                style: TextStyle(
                                  color: Color.fromARGB(255, 34, 69, 151),
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                (remolque1),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Visibility(
                        visible: remolque2 == '' ? false : true,
                        child: Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                ('REMOLQUE 2'),
                                style: TextStyle(
                                  color: Color.fromARGB(255, 34, 69, 151),
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                (remolque2),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: dolly == '' ? false : true,
                        child: Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                ('DOLLY'),
                                style: TextStyle(
                                  color: Color.fromARGB(255, 34, 69, 151),
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                (dolly),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (context) => Contenedor(nombre: nombre),
                        );
                      },
                      child:
                          const Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(
                          "Contenedores",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Product Sans',
                            fontSize: 18,
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 34, 69, 151),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: (validacion.contains('ruta') ||
                              validacion.contains('planta') ||
                              validacion.contains('retorno'))
                          ? () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => Status(
                                    id: id,
                                    referencia: nombre,
                                    id_vehiculo: vehiculo,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child:
                          const Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(
                          'Nuevo estatus',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Product Sans',
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.send_rounded,
                          size: 24.0,
                          color: Colors.white,
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Envío de evidencias",
                            style: TextStyle(
                              fontFamily: 'Product Sans',
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.picture_as_pdf,
                            size: 24.0,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                              builder: (context) => MyAppScan(
                                    id_viaje: id,
                                    id_vehiculo: vehiculo,
                                  )),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Estatus enviados",
                            style: TextStyle(
                              fontFamily: 'Product Sans',
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.timeline_sharp,
                            size: 24.0,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => StatusPageTimeline(
                              id_viaje: id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 164, 0, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "No puedo enviar estatus",
                            style: TextStyle(
                              fontFamily: 'Product Sans',
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.notifications_active_outlined,
                            size: 24.0,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      onPressed: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Enviar reporte'),
                          content: const Text(
                              'Se alertará a monitoreo y a sistemas sobre su problema.'),
                          actions: <Widget>[
                            Container(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade300,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Cancelar",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Icon(
                                      Icons.cancel_outlined,
                                      size: 24.0,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Reportar();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Enviar reporte",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Icon(
                                      Icons.send,
                                      size: 24.0,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
