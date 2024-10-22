import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phicargo/Alerta/update.dart';
import 'package:phicargo/Login/Welcome.dart';
import 'package:phicargo/Login/cerrar_sesion.dart';
import 'package:phicargo/Turnos/Listado/TurnosList.dart';
import 'package:phicargo/drawer.dart';
import 'package:phicargo/Conexion/Conexion.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Turnos extends StatefulWidget {
  const Turnos({super.key});

  @override
  State<Turnos> createState() => _TurnosState();
}

class _TurnosState extends State<Turnos> {
  String release = "";

  Future<void> PedirPermiso() async {
    if (await Permission.location.isGranted) {
      Permission.location.request();
    } else {
      Permission.location.request();
    }
  }

  Future<void> checkForUpdate() async {
    print('checking for update');
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          print('update available');
          update();
        }
      });
    }).catchError((e) {
      print(e.toString());
    });
  }

  void update() async {
    print('Updating');
    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((e) {
      print(e.toString);
    });
  }

  @override
  void initState() {
    PedirPermiso();
    SaveToken();
    comprobar_operador();
    final newVersion = NewVersionPlus(
        androidId: 'com.tb.phicargo', androidPlayStoreCountry: "es_ES");

    const simpleBehavior = true;

    if (simpleBehavior) {
      advancedStatusCheck(newVersion);
    }
    checkForUpdate();
    super.initState();
  }

  basicStatusCheck(NewVersionPlus newVersion) async {
    final version = await newVersion.getVersionStatus();
    if (version != null) {
      release = version.releaseNotes ?? "";
      setState(() {});
    }
    newVersion.showAlertIfNecessary(
      context: context,
      launchModeVersion: LaunchModeVersion.external,
    );
  }

  Future getDeviceToken() async {
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging _firebaseMessage = FirebaseMessaging.instance;

    String? deviceToken = await _firebaseMessage.getToken();
    print(deviceToken);
    return (deviceToken == null) ? "" : deviceToken;
  }

  void SaveToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    String token = await getDeviceToken();

    try {
      var response = await http.post(
          Uri.parse('${conexion}phicargo/app/tokens/confirmar_token.php'),
          body: {
            'id': id,
            'token': token,
          }).timeout(const Duration(seconds: 90));
      print(response.body);
    } on TimeoutException catch (e) {
    } on Error catch (e) {
    } on SocketException catch (e) {}
  }

  void comprobar_operador() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');

    try {
      var response = await http.post(
          Uri.parse(
              '${conexion}phicargo/aplicacion/operador/comprobar_estado.php'),
          body: {
            'id_operador': id,
          }).timeout(const Duration(seconds: 90));

      if (response.body == '0') {
        print('Cerrando sesion');
        logoutAndNavigate(context, WelcomePage());
      }
    } on TimeoutException catch (e) {
    } on Error catch (e) {
    } on SocketException catch (e) {}
  }

  advancedStatusCheck(NewVersionPlus newVersion) async {
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      if (status.localVersion != status.storeVersion) {
        print('NUEVA VERSION DISPONIBLE');

        debugPrint(status.releaseNotes);
        debugPrint(status.appStoreLink);
        debugPrint(status.localVersion);
        debugPrint(status.storeVersion);
        debugPrint(status.canUpdate.toString());

        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return UpdateDialog(
              allowDismissal: true,
              version: status.storeVersion,
              appLink: status.appStoreLink,
            );
          },
        );
      } else {
        print('MISMA VERSION');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        drawer: NavigationDrawerWidget(),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                leading: IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
                title: const Text(
                  'Turnos',
                  style: TextStyle(
                      fontFamily: 'Product Sans',
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                backgroundColor: const Color.fromARGB(255, 34, 69, 151),
                elevation: 0,
                pinned: true,
                floating: true,
                bottom: const TabBar(
                  isScrollable: true,
                  unselectedLabelColor: Colors.white,
                  indicatorWeight: 4,
                  labelColor: Color.fromARGB(255, 255, 255, 255),
                  indicatorColor: Color.fromARGB(255, 34, 69, 151),
                  tabs: [
                    Tab(
                      child: Text('Veracruz'),
                    ),
                    Tab(child: Text('Manzanillo')),
                    Tab(child: Text('México')),
                    Tab(child: Text('Cola Veracruz')),
                    Tab(child: Text('Cola Manzanillo')),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: <Widget>[
              TurnosList(
                sucursal: 'turnos_veracruz',
              ),
              TurnosList(
                sucursal: 'turnos_manzanillo',
              ),
              TurnosList(
                sucursal: 'turnos_mexico',
              ),
              TurnosList(
                sucursal: 'cola_veracruz',
              ),
              TurnosList(
                sucursal: 'cola_manzanillo',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
