import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:phicargo/viajes/contenedores.dart';
import 'package:phicargo/viajes/convertir_tiempos.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phicargo/Conexion/Conexion.dart';

class CartaPorte extends StatefulWidget {
  String id;
  String name;
  CartaPorte({Key? key, required this.id, required this.name})
      : super(key: key);

  @override
  _CartaPorteState createState() => _CartaPorteState();
}

class _CartaPorteState extends State<CartaPorte> {
  var data;

  Future<void> getCartaPorte() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');

    try {
      final response = await http.post(
          Uri.parse(
              '${conexion}phicargo/aplicacion/estatus/obtener_cp_info.php'),
          body: {
            'id': id.toString(),
            'name': widget.name.toString(),
          }).timeout(const Duration(seconds: 90));
      if (response.statusCode == 200) {
        data = jsonDecode(response.body.toString());
      } else {}
    } on TimeoutException catch (e) {
    } on Error catch (e) {
    } on SocketException catch (e) {
    } on FormatException catch (e) {}
  }

  Future refresh() async {
    setState(() {
      getCartaPorte();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: refresh,
        color: Colors.white,
        backgroundColor: Color.fromARGB(255, 34, 69, 151),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: getCartaPorte(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset('assets/car.json', height: 150),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Obteniendo viaje, favor espere un segundo...',
                              style: TextStyle(
                                color: Color.fromARGB(255, 34, 69, 151),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: data == null ? 0 : data.length,
                      itemBuilder: (context, index) {
                        return Container(
                          color: Color.fromARGB(255, 255, 255, 255),
                          child: Column(
                            children: [
                              Informacion(
                                ejecutiva: data[index]
                                            ['x_ejecutivo_viaje_bel'] !=
                                        false
                                    ? data[index]['x_ejecutivo_viaje_bel']
                                        .toString()
                                    : '',
                                inicio_ruta_prog: data[index]['date_start'] !=
                                        false
                                    ? convertir_hora(data[index]['date_start'])
                                    : '',
                                llegada_planta_prog:
                                    data[index]['x_date_arrival_shed'] != false
                                        ? convertir_hora(
                                            data[index]['x_date_arrival_shed'])
                                        : '',
                                custodia: data[index]['x_custodia_bel'] != false
                                    ? data[index]['x_custodia_bel'].toString()
                                    : '',
                                armado: data[index]['x_tipo_bel'] != false
                                    ? data[index]['x_tipo_bel'].toString()
                                    : '',
                                clase: data[index]['x_clase_bel'] != false
                                    ? data[index]['x_clase_bel'].toString()
                                    : '',
                                modo: data[index]['x_modo_bel'] != false
                                    ? data[index]['x_modo_bel'].toString()
                                    : '',
                                carga: data[index]['x_tipo2_bel'] != false
                                    ? data[index]['x_tipo2_bel'].toString()
                                    : '',
                                categoria:
                                    data[index]['waybill_category'] != false
                                        ? data[index]['waybill_category'][1]
                                            .toString()
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
          ],
        ),
      ),
    );
  }
}

class Informacion extends StatelessWidget {
  String categoria;
  String ejecutiva;
  String inicio_ruta_prog;
  String llegada_planta_prog;
  String custodia;
  String armado;
  String carga;
  String modo;
  String clase;

  Informacion({
    Key? key,
    required this.categoria,
    required this.ejecutiva,
    required this.inicio_ruta_prog,
    required this.llegada_planta_prog,
    required this.custodia,
    required this.armado,
    required this.carga,
    required this.modo,
    required this.clase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(('CATEGORIA'),
                          style: TextStyle(
                            color: Color.fromARGB(255, 34, 69, 151),
                            fontSize: 15,
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Text((categoria),
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 20,
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Text(('EJECUTIVO DE VIAJE'),
                          style: TextStyle(
                            color: Color.fromARGB(255, 34, 69, 151),
                            fontSize: 15,
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Text((ejecutiva),
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 20,
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Text(('Programado'),
                          style: TextStyle(
                            color: Color.fromARGB(255, 34, 69, 151),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Text(('INICIO RUTA PROG.'),
                          style: TextStyle(
                            color: Color.fromARGB(255, 34, 69, 151),
                            fontSize: 15,
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Text(inicio_ruta_prog,
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 20,
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Text(('LLEGADA A PLANTA PROG.'),
                          style: TextStyle(
                            color: Color.fromARGB(255, 34, 69, 151),
                            fontSize: 15,
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Text(llegada_planta_prog,
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 20,
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Text(('CUSTODIA:'),
                          style: TextStyle(
                            color: Color.fromARGB(255, 34, 69, 151),
                            fontSize: 15,
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Text((custodia == 'yes' ? 'Si' : 'No'),
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 20,
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Text(('Datos Extra'),
                          style: TextStyle(
                            color: Color.fromARGB(255, 34, 69, 151),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: 144,
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(right: 8),
                                    padding: EdgeInsets.only(left: 16),
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.indigo,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.indigo, width: 1),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Image.asset(
                                          armado == 'full'
                                              ? 'assets/status/2container.png'
                                              : 'assets/status/container1.png',
                                          height: 40,
                                          fit: BoxFit.contain,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  'Armado',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Colors.white),
                                                ),
                                                Text(
                                                  armado == 'single'
                                                      ? 'SENCILLO'
                                                      : 'FULL',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 10,
                                                      color: Colors.grey[400]),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 8),
                                    padding: EdgeInsets.only(left: 16),
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.shade400,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.indigo.shade400,
                                          width: 1),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Image.asset(
                                          'assets/status/container.png',
                                          height: 40,
                                          fit: BoxFit.contain,
                                        ),
                                        Expanded(
                                            child: Padding(
                                          padding: EdgeInsets.only(left: 16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                'Carga',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                carga,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 10,
                                                    color: Colors.grey[400]),
                                              )
                                            ],
                                          ),
                                        )),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(right: 8),
                                    padding: EdgeInsets.only(left: 16),
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.shade400,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.indigo.shade400,
                                          width: 1),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Image.asset(
                                          modo == 'exp'
                                              ? 'assets/status/planeta.png'
                                              : 'assets/status/mexico.png',
                                          height: 40,
                                          fit: BoxFit.contain,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  'Modo',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Colors.white),
                                                ),
                                                Text(
                                                  modo,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 10,
                                                      color: Colors.grey[400]),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 8),
                                    padding: EdgeInsets.only(left: 16),
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.indigo,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.indigo, width: 1),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Image.asset(
                                          'assets/status/danger.png',
                                          height: 40,
                                          fit: BoxFit.contain,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text('Clase',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12,
                                                        color: Colors.white)),
                                                Text(
                                                  clase,
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.grey[400]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
