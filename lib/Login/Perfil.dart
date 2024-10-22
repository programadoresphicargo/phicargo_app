import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:phicargo/login/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:phicargo/Conexion/Conexion.dart';
import 'package:webview_flutter/platform_interface.dart';

import 'cerrar_sesion.dart';

class Perfil extends StatefulWidget {
  static Route<dynamic> route() {
    return CupertinoPageRoute(
      builder: (BuildContext context) {
        return Perfil();
      },
    );
  }

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  bool loading = true;

  late var data;

  @override
  void initState() {
    getDatos();
    super.initState();
  }

  void getDatos() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? val = prefs.getString('id');

      var response = await http.post(
          Uri.parse('${conexion}phicargo/app/perfil/obtener-info.php'),
          body: {
            'id': val.toString(),
          }).timeout(const Duration(seconds: 90));
      print(response.body);
      setState(() {
        data = response.body;
        print(data);
        loading = false;
      });
    } on TimeoutException catch (e) {
      Navigator.of(context).pop();
      print('ERROR');
    } on Error catch (e) {
      Navigator.of(context).pop();
    } on SocketException catch (e) {
      Navigator.pop(context);
    }
  }

  void _showAlertDialog() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            'Cancelar',
            style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 15,
                color: Color.fromARGB(255, 34, 69, 151)),
          ),
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          Container(
            color: Color.fromARGB(255, 34, 69, 151),
            child: CupertinoActionSheetAction(
              onPressed: () {},
              child: Column(
                children: [
                  Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 15,
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    '¿Estas seguro de que quieres cerrar sesión?',
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: CupertinoActionSheetAction(
              child: const Text(
                'Confirmar',
                style: TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 15,
                    color: Color.fromARGB(255, 34, 69, 151)),
              ),
              onPressed: () {
                logoutAndNavigate(context, WelcomePage());
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 22, 22, 22),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text(
          "Perfil",
          style: TextStyle(color: Colors.white, fontFamily: 'Product Sans'),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_sharp,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      body: loading == true
          ? const Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 255, 255, 255)),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Cargando',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 15,
                  ),
                ),
              ],
            ))
          : SingleChildScrollView(
              child: Stack(
                children: <Widget>[
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/fondo4.jpg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.2,
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
                  Container(
                    margin: EdgeInsets.fromLTRB(15, 180, 15, 15),
                    child: Column(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(15),
                              margin: EdgeInsets.only(top: 15),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 44, 44, 44),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(left: 95),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          jsonDecode(data)[0]['name']
                                              .toString(),
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        ListTile(
                                          contentPadding: EdgeInsets.all(0),
                                          title: Text(
                                            jsonDecode(data)[0]['job_id'][1]
                                                .toString(),
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 80,
                              margin: EdgeInsets.only(left: 15, top: 40),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(0, 0),
                                    blurRadius: 10,
                                    color: Colors.black.withOpacity(0.15),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(
                                  50,
                                ),
                                image: DecorationImage(
                                  image: MemoryImage(
                                    base64Decode(jsonDecode(data)[0]['image']),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(
                              255,
                              44,
                              44,
                              44,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                title: Text("Información",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Divider(),
                              ListTile(
                                title: Text("ID Usuario",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  jsonDecode(data)[0]['id'].toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                                leading: Icon(
                                  Icons.person,
                                  size: 45,
                                  color: Colors.white,
                                ),
                              ),
                              ListTile(
                                title: Text("Departamento",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  jsonDecode(data)[0]['department_id'][1]
                                      .toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                                leading: Icon(
                                  Icons.supervised_user_circle_sharp,
                                  size: 45,
                                  color: Colors.white,
                                ),
                              ),
                              ListTile(
                                title: Text("Puesto",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  jsonDecode(data)[0]['job_id'][1].toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                                leading: Icon(
                                  Icons.person_pin_sharp,
                                  size: 45,
                                  color: Colors.white,
                                ),
                              ),
                              ListTile(
                                title: Text("No. de Licencia",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  jsonDecode(data)[0]['tms_driver_license_id']
                                      .toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                                leading: Image.asset(
                                  'assets/status/car.png',
                                  height: 35,
                                  color: Colors.white,
                                ),
                              ),
                              ListTile(
                                title: Text("Tipo de Licencia",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  jsonDecode(data)[0]['tms_driver_license_type']
                                      .toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                                leading: Image.asset(
                                  'assets/status/car.png',
                                  height: 35,
                                  color: Colors.white,
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  "Modalidad",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  jsonDecode(data)[0]['x_modalidad']
                                              .toString() ==
                                          'full'
                                      ? 'FULL'
                                      : 'SENCILLO',
                                  style: TextStyle(color: Colors.white),
                                ),
                                leading: Image.asset(
                                  'assets/status/car.png',
                                  height: 35,
                                  color: Colors.white,
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  "Lic. Carga Peligrosa",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  jsonDecode(data)[0]['x_peligroso_lic']
                                      .toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                                leading: Image.asset(
                                  'assets/status/car.png',
                                  height: 35,
                                  color: Colors.white,
                                ),
                              ),
                              ListTile(
                                onTap: () {
                                  return _showAlertDialog();
                                },
                                title: Text(
                                  "Cerrar sesión",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                leading: Icon(
                                  Icons.logout_sharp,
                                  size: 45,
                                  color: Colors.red,
                                ),
                              ),
                            ],
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
