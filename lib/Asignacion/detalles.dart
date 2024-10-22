import 'dart:async';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:phicargo/Conexion/Conexion.dart';
import 'package:phicargo/Asignacion/inicio.dart';
import 'package:phicargo/Asignacion/Success.dart';
import 'package:phicargo/notificaciones/services.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductItemScreen extends StatefulWidget {
  String id_plan_viaje;
  String origen;
  String ruta;
  String cliente;
  String ejecutiva;
  String armado;
  String carga;
  String modo;
  String clase;
  String hora;
  String categoria;

  ProductItemScreen(
      {required this.id_plan_viaje,
      required this.origen,
      required this.ruta,
      required this.cliente,
      required this.ejecutiva,
      required this.armado,
      required this.carga,
      required this.modo,
      required this.clase,
      required this.hora,
      required this.categoria});

  @override
  State<ProductItemScreen> createState() => _ProductItemScreenState();
}

class _ProductItemScreenState extends State<ProductItemScreen> {
  void seleccionar_viaje(id_viaje) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? val = prefs.getString('id');
      String? valnombre = prefs.getString('nombre');

      showDialog(
          context: context,
          builder: (context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          });

      var response = await http.post(
          Uri.parse('${conexion}phicargo/app/asignacion/asignacion_viaje.php'),
          body: {
            'id': val.toString(),
            'nombre': valnombre.toString(),
            'id_viaje_plan': id_viaje.toString(),
          }).timeout(const Duration(seconds: 90));
      print(response.body);
      if (response.body == '1') {
        showNotificacion('¡Viaje asignado con éxito!', '');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Success()),
        );
        print('CORRECTO');
      } else if (response.body == '0') {}
    } on TimeoutException catch (e) {
      Navigator.of(context).pop();
      print('ERROR');
    } on Error catch (e) {
      Navigator.of(context).pop();
    } on SocketException catch (e) {
      Navigator.pop(context);
      Flushbar(
        icon: Icon(
          Icons.wifi_off_sharp,
          color: Colors.white,
          size: 25,
        ),
        backgroundColor: Color.fromARGB(255, 154, 4, 4),
        duration: Duration(seconds: 5),
        message: "Revise su conexión a internet e intentelo de nuevo.",
        messageSize: 13,
        titleText: Text("Sin internet",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      )..show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            height: 260,
            width: 600,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/fondo4.jpg',
                ),
                fit: BoxFit.cover,
                colorFilter:
                    const ColorFilter.mode(Colors.grey, BlendMode.modulate),
              ),
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(30),
                  topRight: const Radius.circular(30)),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 350,
                color: Colors.black12,
                padding: EdgeInsets.only(top: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              child: Icon(
                                Icons.arrow_back_ios_sharp,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            width: 24,
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.ruta,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 23),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 25,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                widget.ruta,
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                  ],
                ),
              ),
            ),
          ),
          scroll(),
        ],
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          QuickAlert.show(
              context: context,
              type: QuickAlertType.confirm,
              title: '¿Estas seguro?',
              text: 'Para confirmar la selección del viaje presiona confirmar.',
              confirmBtnText: 'Confirmar',
              cancelBtnText: 'Cancelar',
              confirmBtnColor: Color.fromARGB(255, 70, 190, 10),
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              confirmBtnTextStyle: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.bold,
              ),
              titleColor: Color.fromARGB(255, 0, 0, 0),
              textColor: Color.fromARGB(255, 0, 0, 0),
              onConfirmBtnTap: () async {
                seleccionar_viaje(widget.id_plan_viaje.toString());
              });
        },
        child: Container(
          height: 55,
          decoration: BoxDecoration(color: Color.fromARGB(255, 70, 190, 10)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(
              Icons.check,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'SELECCIONAR VIAJE',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            )
          ]),
        ),
      ),
    );
  }

  scroll() {
    return DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 1.0,
        minChildSize: 0.75,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 28, 28, 28),
              borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(30),
                  topRight: const Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          IconlyLight.location,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ORIGEN',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: 5,
                              ),
                              Text(widget.origen,
                                  style: TextStyle(
                                    color: Colors.white,
                                  )),
                            ]),
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color.fromARGB(255, 47, 157, 22),
                        child: Icon(
                          IconlyLight.location,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('DESTINO',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 47, 157, 22),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: 5,
                              ),
                              Text(widget.ruta,
                                  style: TextStyle(
                                    color: Colors.white,
                                  )),
                            ]),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(
                      color: Color.fromARGB(255, 22, 22, 22),
                      height: 4,
                    ),
                  ),
                  item(context, 'CATEGORIA:', widget.cliente, '',
                      widget.categoria),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(
                      color: Color.fromARGB(255, 22, 22, 22),
                      height: 4,
                    ),
                  ),
                  item(context, 'CLIENTE', widget.cliente, '', widget.cliente),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(
                      color: Color.fromARGB(255, 22, 22, 22),
                      height: 4,
                    ),
                  ),
                  item(
                    context,
                    'EJECUTIVA',
                    widget.ejecutiva,
                    '',
                    widget.ejecutiva,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(
                      color: Color.fromARGB(255, 22, 22, 22),
                      height: 4,
                    ),
                  ),
                  Text('ESPECIFICACIONES',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
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
                                  color: Color.fromARGB(255, 20, 20, 20),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Color.fromARGB(255, 20, 20, 20),
                                      width: 1),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Image.asset(
                                      widget.armado == 'full'
                                          ? 'assets/status/2container.png'
                                          : 'assets/status/container1.png',
                                      height: 40,
                                      fit: BoxFit.contain,
                                    ),
                                    Padding(
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
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: Colors.white),
                                          ),
                                          Text(
                                            widget.armado == 'single'
                                                ? 'SENCILLO'
                                                : 'FULL',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 10,
                                                color: Colors.grey[400]),
                                          )
                                        ],
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
                                  color: Color.fromARGB(255, 20, 20, 20),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Color.fromARGB(255, 20, 20, 20),
                                      width: 1),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/status/container.png',
                                      height: 40,
                                      fit: BoxFit.contain,
                                    ),
                                    Padding(
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
                                            widget.carga,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 10,
                                                color: Colors.grey[400]),
                                          )
                                        ],
                                      ),
                                    )
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
                                  color: Color.fromARGB(255, 20, 20, 20),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Color.fromARGB(255, 20, 20, 20),
                                      width: 1),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Image.asset(
                                      widget.modo == 'exp'
                                          ? 'assets/status/planeta.png'
                                          : 'assets/status/mexico.png',
                                      height: 40,
                                      fit: BoxFit.contain,
                                    ),
                                    Padding(
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
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: Colors.white),
                                          ),
                                          Text(
                                            widget.modo,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 10,
                                                color: Colors.grey[400]),
                                          )
                                        ],
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
                                  color: Color.fromARGB(255, 20, 20, 20),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Color.fromARGB(255, 20, 20, 20),
                                      width: 1),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/status/danger.png',
                                      height: 40,
                                      fit: BoxFit.contain,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text('Clase',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color: Colors.white)),
                                          Text(
                                            widget.clase,
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.grey[400]),
                                          ),
                                        ],
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(
                      color: Color.fromARGB(255, 22, 22, 22),
                      height: 4,
                    ),
                  ),
                  item(
                    context,
                    'INICIO RUTA PROGRAMADA',
                    widget.hora,
                    '',
                    widget.hora,
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget item(BuildContext context, String title, String subtitle, String sf,
      String op2) {
    return Row(children: [
      Flexible(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(
            height: 5,
          ),
          Text(subtitle == sf ? 'SENCILLO' : op2,
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 15,
              )),
        ]),
      ),
    ]);
  }
}
