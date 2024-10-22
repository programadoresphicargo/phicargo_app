import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:phicargo/Alertas/alerta.dart';
import 'package:phicargo/Conexion/Conexion.dart';
import 'package:phicargo/Login/Almacenar.dart';
import 'package:phicargo/Login/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  String identifier;
  LoginPage({required this.identifier});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final id = TextEditingController();
  final contrasena = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();
  String username = '';
  String passwoord = '';

  Future<void> secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  void initState() {
    super.initState();
  }

  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<String> getDeviceToken() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      FirebaseMessaging _firebaseMessage = FirebaseMessaging.instance;

      String? deviceToken = await _firebaseMessage.getToken();
      print(deviceToken);
      return deviceToken ?? "";
    } catch (e) {
      // Manejar cualquier excepción ocurrida durante el proceso
      print('Error al obtener el token del dispositivo: $e');
      return "";
    }
  }

  void SaveToken(token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');

    try {
      var response = await http.post(
          Uri.parse('${conexion}phicargo/app/tokens/guardar_token.php'),
          body: {
            'id': id,
            'token': token,
          }).timeout(const Duration(seconds: 90));
      var data = jsonDecode(response.body);

      if (response.body == '1') {
      } else if (response.body == '0') {
        print('NO SE GUARDO');
      }
    } on TimeoutException catch (e) {
    } on Error catch (e) {
    } on SocketException catch (e) {}
  }

  void _showAlertDialog() {
    showDialog(
        context: context,
        builder: (buildcontext) {
          return AlertDialog(
            title: Text(
              "¡Sesión Duplicada!",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 34, 69, 151)),
            ),
            content: Text(
                "Por políticas de seguridad no se permiten inicios de sesión en más de un dispositivo a la vez."),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 34, 69, 151),
                ),
                child: Text(
                  "Ok",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void iniciar_sesion(id, pass) async {
    try {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });

      var response = await http
          .post(Uri.parse('${conexion}phicargo/app/usuario/login.php'), body: {
        'id': id,
        'passwoord': pass,
        'identifier': widget.identifier,
      }).timeout(const Duration(seconds: 10));
      print(response.body);
      if (response.body == "0") {
        Navigator.of(context).pop();
        error_alert(
            'Datos erróneos',
            'El nombre de usuario o contraseña son incorrectos.',
            const Icon(
              Icons.wifi_off_sharp,
              color: Colors.white,
              size: 25,
            ),
            context);
      } else if (response.body == "2") {
        Navigator.of(context).pop();
        _showAlertDialog();
      } else {
        var data = jsonDecode(response.body);
        String nombre = data['nombre_operador'];
        String opid = data['id'];
        String passworrd = data['passwoord'];
        String modalidad = data['modalidad'];
        String peligroso = data['peligroso'];
        String tipo = data['tipo'];

        almacenar_usuario(opid, nombre, passworrd, modalidad, peligroso, tipo);
        String deviceToken = await getDeviceToken();
        print(deviceToken);
        SaveToken(deviceToken);
        // ignore: use_build_context_synchronously
        Navigator.pushAndRemoveUntil<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => SplashScreen2(),
          ),
          (route) => false,
        );
      }
    } on TimeoutException catch (e) {
      print('ERROR');
      Navigator.of(context).pop();
      error_alert(
          'Sin conexión internet',
          'Revise su conexión a internet e intentelo de nuevo.',
          const Icon(
            Icons.wifi_off_sharp,
            color: Colors.white,
            size: 25,
          ),
          context);
    } on Error catch (e) {
      Navigator.of(context).pop();
    } on SocketException catch (e) {
      Navigator.of(context).pop();
      error_alert(
          'Sin internet',
          'Revise su conexión a internet e intentelo de nuevo.',
          const Icon(
            Icons.wifi_off_sharp,
            color: Colors.white,
            size: 25,
          ),
          context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      body: Padding(
        padding: EdgeInsets.only(left: 14, right: 14, top: 25, bottom: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'hero-tag',
              child: Image.network(
                "https://phi-cargo.com/wp-content/uploads/2021/05/logo-phicargo-vertical.png",
                color: Colors.white,
                height: 100,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              "Ingresa tus credenciales para iniciar sesión",
              style: TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ),
                  fontFamily: 'Product Sans'),
            ),
            const SizedBox(
              height: 14,
            ),
            TextFormField(
              controller: id,
              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 44, 44, 44),
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 1.0,
                  ),
                ),
                fillColor: Colors.white,
                iconColor: Colors.white,
                border: OutlineInputBorder(),
                labelText: 'Usuario',
                labelStyle: const TextStyle(
                    color: Colors.white, fontFamily: 'Product Sans'),
              ),
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(
              height: 15,
            ),
            TextFormField(
              controller: contrasena,
              obscureText: _obscureText,
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 44, 44, 44),
                    width: 1.0,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 1.0,
                  ),
                ),
                fillColor: Colors.white,
                iconColor: Colors.white,
                border: OutlineInputBorder(),
                labelText: 'Contraseña',
                labelStyle: const TextStyle(
                    color: Colors.white, fontFamily: 'Product Sans'),
                suffixIcon: IconButton(
                  icon: Icon(
                    color: Colors.white,
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              cursorColor: Colors.orange, // Color del cursor
              style: const TextStyle(
                  color: Colors.white), // Color del texto ingresado
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: () {
                username = id.text;
                passwoord = contrasena.text;
                print(username);
                print(passwoord);

                if (username != '' && passwoord != '') {
                  iniciar_sesion(username, passwoord);
                } else {
                  error_alert(
                    'Datos incompletos',
                    'Revisa que los campos de usuario y contraseña estén llenos.',
                    const Icon(
                      Icons.error,
                      color: Colors.white,
                    ),
                    context,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 54),
                backgroundColor: Colors.blue[800],
                textStyle: const TextStyle(
                  fontSize: 26.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8.0), // Aquí defines el BorderRadius
                ),
              ),
              child: const Center(
                child: Text(
                  "INICIAR SESIÓN",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Product Sans',
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            TextButton(
              child: const Text(
                "¿Olvidaste tu usuario y contraseña?",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontFamily: 'Product Sans'),
              ),
              onPressed: () async {
                _sendMessage();
              },
            )
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    const phoneNumber = '+2291590967';
    const message =
        'Hola, podrias compartirme mi usuario y contraseña de la aplicacion para envio de estatus mi nombre es:';
    final Uri _url = Uri.parse(
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

    if (!await launchUrl(_url)) {
      throw Exception('Could not launch whatsappUrl');
    }
  }
}
