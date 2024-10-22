import 'dart:convert';

import 'package:flare_flutter/base/math/vec2d.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Conexion/Conexion.dart';
import 'reporte_mecanico.dart';

class Reporte_fallas extends StatefulWidget {
  @override
  Reporte_fallasState createState() => Reporte_fallasState();
}

class Reporte_fallasState extends State<Reporte_fallas> {
  late Future<List<dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = fetchData();
  }

  recharge() {
    setState(() {
      _dataFuture = fetchData();
    });
  }

  Future<List<dynamic>> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? val = prefs.getString('id');

    final response = await http.post(
        Uri.parse('${conexion}/phicargo/app/reportes_fallas/reportes.php'),
        body: {'id_operador': val});
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 100, 100, 100),
        title: const Text(
          'Mis reportes de fallas mecánicas',
          style: TextStyle(fontFamily: 'Product Sans', color: Colors.white),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          recharge();
        },
        color: Colors.white,
        backgroundColor: Colors.grey,
        child: FutureBuilder<List<dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.grey,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Cargando...',
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final List<dynamic> data = snapshot.data!;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    child: Column(children: [
                      jobComponent(
                          referencia: data[index]['name'].toString(),
                          vehiculo: data[index]['vehicle_id'][1].toString(),
                          notas: data[index]['x_notas_operador'] != false
                              ? data[index]['x_notas_operador'].toString()
                              : '',
                          fecha: data[index]['create_date'].toString(),
                          id: data[index]['id'],
                          estado: data[index]['solved'])
                    ]),
                  );
                },
              );
            } else {
              return Center(child: Text('No se encontraron datos.'));
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 100, 100, 100),
        foregroundColor: Colors.black,
        onPressed: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => formulario_reporte_fallas(
                editable: true,
                id_reporte: 0,
              ),
            ),
          );
        },
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: const Text(
          'Nuevo',
          style: TextStyle(
              fontSize: 18, color: Colors.white, fontFamily: 'Product Sans'),
        ),
      ),
    );
  }

  Widget jobComponent({
    required int id,
    required String referencia,
    required String vehiculo,
    required String notas,
    required String fecha,
    required bool estado,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => formulario_reporte_fallas(
              editable: false,
              id_reporte: id,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ]),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(children: [
                    Container(
                        width: 60,
                        height: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset('assets/reporte_mecanico.png'),
                        )),
                    SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(referencia,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade200),
                            child: Text(
                              vehiculo,
                            ),
                          ),
                        ],
                      ),
                    )
                  ]),
                ),
                Visibility(
                  visible: estado,
                  child: Chip(
                    elevation: 0,
                    label: const Text(
                      'Resuelto',
                      style: TextStyle(color: Colors.white),
                    ),
                    avatar: const Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    fecha,
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
