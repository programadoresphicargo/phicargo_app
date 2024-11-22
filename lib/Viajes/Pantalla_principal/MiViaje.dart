import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:phicargo/Viajes/Pantalla_principal/Vista_principal.dart';
import 'package:phicargo/Viajes/Pantalla_principal/MasInformacion.dart';
import 'package:phicargo/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Asignacion/SinInternet.dart';
import '../../Conexion/Conexion.dart';
import '../CartaPorte.dart';

class MiViaje extends StatefulWidget {
  @override
  State<MiViaje> createState() => _MiViajeState();
}

class _MiViajeState extends State<MiViaje> {
  String id_viaje = '0';

  void buscar_viaje() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? val = prefs.getString('id');

      if (val == null) {
        throw Exception('No se encontró el ID en SharedPreferences');
      }

      var response = await http.post(
        Uri.parse('${conexion}phicargo/aplicacion/viajes/viaje_asignado.php'),
        body: {
          'id': val,
        },
      ).timeout(const Duration(seconds: 90));

      var data = jsonDecode(response.body);
      print(data);

      if (data.isNotEmpty && data[0]['travel_id'] != null) {
        setState(() {
          id_viaje = data[0]['travel_id'][0].toString();
          print(id_viaje);
        });
      } else {
        throw Exception('Respuesta inesperada del servidor');
      }
    } on TimeoutException catch (e) {
      print('Timeout: $e');
    } on SocketException catch (e) {
      print('Error de red: $e');
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    buscar_viaje();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: NavigationDrawerWidget(),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                leading: Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  },
                ),
                title: const Text(
                  'Mi viaje',
                  style: TextStyle(
                    fontFamily: 'Product Sans',
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                centerTitle: true,
                backgroundColor: Color.fromARGB(255, 34, 69, 151),
                elevation: 0,
                pinned: true,
                floating: true,
                bottom: const TabBar(
                  indicatorWeight: 3,
                  labelColor: Color.fromARGB(255, 255, 255, 255),
                  indicatorColor: Color.fromARGB(255, 34, 69, 151),
                  unselectedLabelColor: Colors.white,
                  isScrollable: true,
                  tabs: [
                    Tab(
                      child: Text('Datos de viaje'),
                    ),
                    Tab(child: Text('Más información')),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: <Widget>[
              StatusPrincipal(
                id_viaje: id_viaje,
              ),
              DashboardPage(
                id_viaje: id_viaje,
              )
            ],
          ),
        ),
      ),
    );
  }
}
