import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phicargo/Conexion/Conexion.dart';

class Contenedor extends StatefulWidget {
  String nombre;
  Contenedor({required this.nombre, Key? key}) : super(key: key);

  @override
  _ContenedorState createState() => _ContenedorState(nombre_viaje: nombre);
}

class _ContenedorState extends State<Contenedor> {
  String nombre_viaje;

  _ContenedorState({required this.nombre_viaje});

  var data;

  Future<void> getUserApi(nombre) async {
    try {
      var response = await http.post(
          Uri.parse('${conexion}phicargo/aplicacion/estatus/obtener_cp.php'),
          body: {
            'name': nombre,
          }).timeout(const Duration(seconds: 90));
      if (response.statusCode == 200) {
        data = jsonDecode(response.body.toString());
      } else {}
    } on TimeoutException catch (e) {
    } on Error catch (e) {
      print('ERROR 1:');
    } on SocketException catch (e) {
      print('ERROR 2: NO HAY INTERNET');
    } on FormatException catch (e) {
      print('ERROR 3: FORMATO ERRONEO');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        color: Color.fromARGB(255, 255, 255, 255),
      ),
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: getUserApi(nombre_viaje),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 34, 69, 151)),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Cargando',
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
                    padding: const EdgeInsets.all(20),
                    itemCount: data.length == null ? 0 : data.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 0,
                        margin: EdgeInsets.all(8.0),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(data[index]['x_reference'].toString()),
                            leading: CircleAvatar(
                              child: Image.asset('assets/contenedor.png'),
                            ),
                            onTap: () {},
                          ),
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
    );
  }
}
