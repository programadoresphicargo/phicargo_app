import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:phicargo/Conexion/Conexion.dart';
import 'package:phicargo/Asignacion/SinViajes.dart';
import 'package:phicargo/Asignacion/TerminoTiempo.dart';
import 'package:phicargo/Asignacion/detalles.dart';
import 'package:phicargo/Asignacion/inicio.dart';
import 'package:phicargo/Asignacion/ticket.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViajeAsignacion extends StatefulWidget {
  String hora_salida;
  ViajeAsignacion({super.key, required this.hora_salida});

  @override
  _ViajeAsignacionState createState() => _ViajeAsignacionState();
}

class _ViajeAsignacionState extends State<ViajeAsignacion> {
  String remainingTime = "";
  Timer? _timer;
  StreamController<String> timerStream = StreamController<String>.broadcast();
  late DateTime endDate = DateTime.parse(widget.hora_salida);
  DateTime currentDate = DateTime.now();

  late String data;
  bool loading = true;
  var superheros_length;
  late int seconds;

  @override
  void initState() {
    getData();
    prepareData();
    super.initState();
  }

  @override
  void dispose() {
    try {
      if (_timer != null && _timer!.isActive) _timer!.cancel();
    } catch (e) {
      print(e);
    }
    super.dispose();
  }

  prepareData() {
    final difference = daysBetween(currentDate, endDate);
    print(difference);
    print('difference in days');
    var result = Duration(seconds: 0);
    result = endDate.difference(currentDate);
    remainingTime = result.inSeconds.toString();
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  String dayHourMinuteSecondFunction(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String days = twoDigits(duration.inDays);
    String twoDigitHours = twoDigits(duration.inHours.remainder(24));
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return twoDigitMinutes + ":" + twoDigitSeconds;
  }

  speak() async {
    await flutterTts.setLanguage("es-MX");
    await flutterTts.setPitch(1);
    await flutterTts.speak('Deprisa. Te queda menos de un minuto.');
    print(await flutterTts.getVoices);
  }

  Widget dateWidget() {
    return StreamBuilder<String>(
      stream: timerStream.stream,
      initialData: "0",
      builder: (cxt, snapshot) {
        const oneSec = Duration(seconds: 1);
        if (_timer != null && _timer!.isActive) _timer!.cancel();
        _timer = Timer.periodic(
          oneSec,
          (Timer timer) {
            try {
              int second = int.tryParse(remainingTime) ?? 0;
              second = second - 1;
              if (second < -1) return;
              remainingTime = second.toString();
              if (second == -1) {
                timer.cancel();
                print('timer cancelled');
                Navigator.pushAndRemoveUntil<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => TerminoTiempo(),
                  ),
                  (route) => false,
                );
              }
              if (second >= 0) {
                timerStream.add(remainingTime);
              }
            } catch (e) {
              print(e);
            }
          },
        );
        String remainTimeDisplay = "-";
        try {
          seconds = int.parse(remainingTime);
          var now = Duration(seconds: seconds);
          remainTimeDisplay = dayHourMinuteSecondFunction(now);
        } catch (e) {
          print(e);
        }
        print(remainTimeDisplay);

        if (remainTimeDisplay == '00:59') {
          speak();
        }
        return SliverAppBar(
          backgroundColor: seconds >= 60
              ? const Color.fromARGB(255, 70, 190, 10)
              : const Color.fromARGB(255, 154, 4, 4),
          title: Center(
              child: Container(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(
                Icons.timer_outlined,
                size: 50,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                remainTimeDisplay,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold),
              ),
            ]),
          )),
          elevation: 10.0,
          automaticallyImplyLeading: false,
          expandedHeight: 80,
          pinned: false,
          snap: true,
          floating: true,
          centerTitle: true,
        );
      },
    );
  }

  void getData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString('id');
      String? modalidad = prefs.getString('modalidad');
      String? peligroso = prefs.getString('peligroso');

      var response = await http.post(
          Uri.parse('${conexion}phicargo/app/asignacion/viaje_disponible.php'),
          body: {
            'id': id.toString(),
            'modalidad': modalidad.toString(),
            'peligroso': peligroso.toString(),
          }).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        data = response.body;
        print(response.body);

        setState(() {
          loading = false;
          superheros_length = jsonDecode(data);

          final registros = json.decode(response.body);
          final length = registros.length;

          if (length == 0) {
            Navigator.pushAndRemoveUntil<dynamic>(
              context,
              MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => SinViajes(),
              ),
              (route) => false,
            );
          }
        });
      } else {
        print(response.statusCode);
      }
    } on Error catch (e) {
      print('ERROR 31');
      getData();
    } on TimeoutException catch (e) {
      print('ERROR 42');
      getData();
    } on FormatException catch (e) {
      print('ERROR 56');
      getData();
      e.message;
    } on SocketException catch (e) {
      getData();

      Flushbar(
        icon: const Icon(Icons.wifi_off_sharp),
        backgroundColor: const Color.fromARGB(255, 154, 4, 4),
        duration: const Duration(seconds: 5),
        message: 'Revisar internet',
        messageSize: 13,
        titleText: const Text('Sin conexión a internet',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ).show(context);
    }
  }

  Future refresh() async {
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: Color.fromARGB(255, 34, 69, 151),
                title: Container(
                    color: Color.fromARGB(255, 34, 69, 151),
                    child: const Text(
                      "Viajes disponibles",
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold),
                    )),
                elevation: 10.0,
                automaticallyImplyLeading: false,
                expandedHeight: 20,
                floating: true,
                centerTitle: true,
                snap: true,
              ),
              dateWidget()
            ];
          },
          body: RefreshIndicator(
            onRefresh: refresh,
            color: Colors.white,
            backgroundColor: const Color.fromARGB(255, 34, 69, 151),
            child: loading == true
                ? Center(
                    child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 34, 69, 151)),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Obteniendo viajes, espere un momento...',
                          style: TextStyle(
                            color: Color.fromARGB(255, 34, 69, 151),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ))
                : Container(
                    color: Color.fromARGB(255, 248, 246, 246),
                    child: ListView.builder(
                        padding: EdgeInsets.all(10),
                        itemCount: superheros_length == null
                            ? 0
                            : superheros_length.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                context: context,
                                builder: (context) => ProductItemScreen(
                                  id_plan_viaje:
                                      jsonDecode(data)[index]['id'].toString(),
                                  origen: jsonDecode(data)[index]['store_id'] !=
                                          false
                                      ? jsonDecode(data)[index]['store_id'][1]
                                          .toString()
                                      : '',
                                  ruta: jsonDecode(data)[index]['x_ruta_bel']
                                      .toString(),
                                  cliente: jsonDecode(data)[index]
                                              ['partner_id'] !=
                                          false
                                      ? jsonDecode(data)[index]['partner_id'][1]
                                          .toString()
                                      : '',
                                  ejecutiva: jsonDecode(data)[index]
                                          ['x_ejecutivo_viaje_bel']
                                      .toString(),
                                  armado: jsonDecode(data)[index]['x_tipo_bel']
                                      .toString(),
                                  carga: jsonDecode(data)[index]['x_tipo2_bel']
                                      .toString(),
                                  modo: jsonDecode(data)[index]['x_modo_bel']
                                      .toString(),
                                  clase: jsonDecode(data)[index]['x_clase_bel']
                                      .toString(),
                                  hora: jsonDecode(data)[index]
                                          ['date_start_real']
                                      .toString(),
                                  categoria: jsonDecode(data)[index]
                                              ['waybill_category'] !=
                                          false
                                      ? jsonDecode(data)[index]
                                              ['waybill_category'][1]
                                          .toString()
                                      : '',
                                ),
                              );
                            },
                            child: Ticket(
                              jsonDecode(data)[index]['id'].toString(),
                              jsonDecode(data)[index]['store_id'][1].toString(),
                              jsonDecode(data)[index]['x_ruta_bel'].toString(),
                              jsonDecode(data)[index]['x_tipo_bel'].toString(),
                              jsonDecode(data)[index]['date_start_real']
                                  .toString(),
                              jsonDecode(data)[index]['x_custodia_bel']
                                  .toString(),
                              jsonDecode(data)[index]['x_ejecutivo_viaje_bel']
                                  .toString(),
                              jsonDecode(data)[index]['x_clase_bel'].toString(),
                              jsonDecode(data)[index]['waybill_category']
                                  .toString(),
                            ),
                          );
                        }),
                  ),
          ),
        ),
      ),
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                  'No puedes regresar hasta que selecciones un viaje, de otro modo cierra la aplicación.'),
              actionsAlignment: MainAxisAlignment.end,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Ok'),
                ),
              ],
            );
          },
        );
        return shouldPop!;
      },
    );
  }
}
