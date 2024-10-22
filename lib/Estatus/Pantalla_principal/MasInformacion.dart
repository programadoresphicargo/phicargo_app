import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:lottie/lottie.dart';
import 'package:phicargo/Estatus/convertir_tiempos.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:phicargo/Conexion/Conexion.dart';

const Color primary = Color.fromARGB(255, 34, 69, 151);
const Color secondary = Color.fromARGB(255, 34, 69, 151);
const Color black = Color(0xFF000000);
const Color white = Color(0xFFFFFFFF);
const Color bgColor = Color(0xFFF8F8F9);

class DashboardPage extends StatefulWidget {
  String id_viaje;
  DashboardPage({Key? key, required this.id_viaje}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  var data;

  Future<void> getCartaPorte() async {
    try {
      final response = await http.post(
          Uri.parse(
              '${conexion}phicargo/aplicacion/estatus/obtener_cp_info.php'),
          body: {
            'id_viaje': widget.id_viaje.toString(),
          }).timeout(const Duration(seconds: 90));
      if (response.statusCode == 200) {
        data = jsonDecode(response.body.toString());
      } else {
        print('error');
      }
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
    setState(() {
      getCartaPorte();
    });
  }

  @override
  void initState() {
    super.initState();
    getCartaPorte();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        onRefresh: refresh,
        color: Colors.white,
        backgroundColor: Color.fromARGB(255, 34, 69, 151),
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
                padding: EdgeInsets.all(0),
                itemCount: data == null ? 0 : data.length,
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 200,
                          child: Stack(
                            children: [
                              appBarCurve(),
                              Ejecutivo(
                                  ejecutivo: data[index]
                                              ['x_ejecutivo_viaje_bel'] !=
                                          false
                                      ? data[index]['x_ejecutivo_viaje_bel']
                                          .toString()
                                      : '')
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Informacion(
                          inicio_ruta_prog: data[index]['date_start'] != false
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
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Extra(
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
                        ),
                        SizedBox(
                          height: 35,
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

  Widget appBarCurve() {
    var size = MediaQuery.of(context).size;
    return ClipPath(
      clipper: OvalBottomBorderClipper(),
      child: Container(
        width: size.width,
        height: size.height * 0.25,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [primary, secondary]),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.1),
              spreadRadius: 10,
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class Extra extends StatelessWidget {
  String armado;
  String carga;
  String modo;
  String clase;

  Extra({
    Key? key,
    required this.armado,
    required this.carga,
    required this.modo,
    required this.clase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Datos extras",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            height: 144,
            child: Column(
              children: <Widget>[
                Flexible(
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.only(right: 8),
                          padding: EdgeInsets.only(left: 16),
                          height: 64,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 34, 69, 151),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Color.fromARGB(255, 34, 69, 151),
                                width: 1),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Armado',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            color: Colors.white),
                                      ),
                                      Text(
                                        armado == 'single'
                                            ? 'SENCILLO'
                                            : 'FULL',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
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
                            color: Color.fromARGB(255, 34, 69, 151)
                                .withOpacity(.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Color.fromARGB(255, 34, 69, 151)
                                    .withOpacity(.9),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                          color:
                              Color.fromARGB(255, 34, 69, 151).withOpacity(.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Color.fromARGB(255, 34, 69, 151)
                                  .withOpacity(.9),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Modo',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      modo,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
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
                          color: Color.fromARGB(255, 34, 69, 151),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Color.fromARGB(255, 34, 69, 151),
                              width: 1),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text('Clase',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            color: Colors.white)),
                                    Text(
                                      clase,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
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
        ],
      ),
    );
  }
}

class Ejecutivo extends StatelessWidget {
  String ejecutivo;

  Ejecutivo({
    Key? key,
    required this.ejecutivo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Información",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: black.withOpacity(0.01),
                    spreadRadius: 10,
                    blurRadius: 10,
                    // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lock_clock,
                          color: primary,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ejecutiv@",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              ejecutivo,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Informacion extends StatelessWidget {
  String inicio_ruta_prog;
  String llegada_planta_prog;
  String custodia;

  Informacion({
    Key? key,
    required this.custodia,
    required this.inicio_ruta_prog,
    required this.llegada_planta_prog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Programación",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            width: size.width,
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: black.withOpacity(0.01),
                  spreadRadius: 10,
                  blurRadius: 10,
                  // changes position of shadow
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lock_clock,
                        color: primary,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Inicio Ruta Prog",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              inicio_ruta_prog,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.lock_clock,
                        color: primary,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Llegada Planta Prog",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              llegada_planta_prog,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.lock_clock,
                        color: primary,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "LLeva custodia",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            custodia == 'yes' ? 'Si' : 'No',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
