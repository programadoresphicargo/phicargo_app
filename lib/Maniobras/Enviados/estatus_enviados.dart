import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:palette_generator/palette_generator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:phicargo/nav.dart';
import 'package:phicargo/notificaciones/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'dart:io';
import '../../Conexion/Conexion.dart';

class EstatusOperadorManiobra extends StatefulWidget {
  String id_maniobra;

  EstatusOperadorManiobra({required this.id_maniobra, super.key});
  State<EstatusOperadorManiobra> createState() => _EstatusOperadorState();
}

class _EstatusOperadorState extends State<EstatusOperadorManiobra> {
  Future<List<dynamic>> getEstatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id_operador = prefs.getString('id');

    try {
      final response = await http.post(
        Uri.parse(
            '${conexion}phicargo/aplicacion/maniobras/estatus_enviados.php'),
        body: {
          'id_maniobra': widget.id_maniobra.toString(),
          'id_operador': id_operador.toString(),
        },
      ).timeout(const Duration(seconds: 90));

      print('estatus enviajes');
      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } on TimeoutException catch (e) {
      throw Exception('Request timed out');
    } on SocketException catch (e) {
      throw Exception('No Internet connection');
    } on FormatException catch (e) {
      throw Exception('Invalid format');
    }
  }

  Future refresh() async {
    setState(() {
      getEstatus();
    });
  }

  Future<Color> _updatePalette(String imageUrl) async {
    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
      );
      return paletteGenerator.dominantColor?.color ?? Colors.grey;
    } catch (e) {
      // Handle exceptions if needed
      return Colors.grey;
    }
  }

  late ConfettiController _controllerCenter;

  void initState() {
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(255, 255, 255, 1),
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushAndRemoveUntil<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => Nav(
                          selectedIndex: 5,
                        )),
                (route) => false,
              );
            }
          },
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 28, 42, 165),
        title: const Text(
          'Estatus enviados',
          style: TextStyle(color: Colors.white, fontFamily: 'Product Sans'),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: refresh,
            color: Colors.white,
            backgroundColor: Colors.blue[700],
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: FutureBuilder<List<dynamic>>(
                      future: getEstatus(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue[700],
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text('No data available'));
                        } else {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              var item = snapshot.data![index];
                              String imageUrl =
                                  '${conexion}phicargo/img/status/' +
                                      item['imagen'].toString();

                              return FutureBuilder<Color>(
                                future: _updatePalette(imageUrl),
                                builder: (context, colorSnapshot) {
                                  Color cardColor =
                                      colorSnapshot.data ?? Colors.white;
                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: .3,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Card(
                                      margin: EdgeInsets.zero,
                                      elevation: 0,
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              cardColor.withOpacity(0.5),
                                          child: Image.network(
                                            '${conexion}phicargo/img/status/' +
                                                item['imagen'],
                                          ),
                                        ),
                                        title: Text(
                                          item['status'],
                                          style: const TextStyle(
                                              fontFamily: 'Product Sans',
                                              fontSize: 20),
                                        ),
                                        subtitle: Text(item['fecha_hora']),
                                      ),
                                    ),
                                  );
                                },
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
          ),
        ],
      ),
    );
  }
}
