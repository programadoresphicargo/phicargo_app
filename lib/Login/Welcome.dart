import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:phicargo/Conexion/Conexion.dart';
import 'package:phicargo/login/login.dart';
import 'package:phicargo/nav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:http/http.dart' as http;

String _identifier = 'Unknown';

class WelcomePage extends StatefulWidget {
  static Route<dynamic> route() {
    return CupertinoPageRoute(
      builder: (BuildContext context) {
        return WelcomePage();
      },
    );
  }

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

const Color background = Color.fromARGB(255, 22, 22, 22);

final List<String> imgList = [
  'assets/mio.jpg',
  'assets/R2.jpg',
  'assets/fondo4.jpg',
  'assets/fondo.jpg',
  'assets/13.jpg',
  'assets/EEE.jpg'
];

class _WelcomePageState extends State<WelcomePage> {
  void actualizar() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString('id');
      var response = await http.post(
          Uri.parse('${conexion}phicargo/app/usuario/actualizar.php'),
          body: {
            'id': id,
          }).timeout(const Duration(seconds: 90));
      var data = jsonDecode(response.body);
      var Modalidad = data['modalidad'];
      var Peligroso = data['peligroso'];
      var tipo_usuario = data['tipo'];

      await prefs.setString('modalidad', Modalidad);
      await prefs.setString('peligroso', Peligroso);
      await prefs.setString('tipo', tipo_usuario);

      print('Informacion Actualizada');
      String? mod = prefs.getString('modalidad');
      String? pel = prefs.getString('peligroso');
      String? tip = prefs.getString('tipo');

      print('---');
      print(mod.toString());
      print(pel.toString());
      print(tip.toString());

      print('Sesion iniciada');
    } on TimeoutException catch (e) {
    } on Error catch (e) {}
  }

  void CheckLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? val = prefs.getString('id');
    String? mod = prefs.getString('modalidad');
    String? pel = prefs.getString('peligroso');
    print('---');
    print(val.toString());
    print(mod.toString());
    print(pel.toString());
    print('Sesion iniciada');

    if (val != null) {
      actualizar();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => Nav(
                    selectedIndex: 0,
                  )),
          (route) => false);
    } else {}
  }

  Future<void> initUniqueIdentifierState() async {
    String identifier;
    try {
      identifier = (await UniqueIdentifier.serial)!;
      print(identifier);
    } on PlatformException {
      identifier = 'Failed to get Unique Identifier';
    }

    if (!mounted) return;

    setState(() {
      _identifier = identifier;
    });
    print(identifier);
  }

  @override
  void initState() {
    initUniqueIdentifierState();
    super.initState();
    CheckLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 22, 22, 22),
      body: Stack(
        children: [
          _backgroundImage(),
          _backgroundGradient(),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 35, right: 35),
                child: SimpleShadow(
                  opacity: 0.6,
                  color: Color.fromARGB(255, 22, 22, 22),
                  offset: Offset(5, 5),
                  sigma: 7,
                  child: Image.network(
                    "https://phi-cargo.com/wp-content/uploads/2021/05/logo-phicargo-vertical.png",
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
              Container(
                child: Text(
                  "App Operadores",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 18),
                ),
              ),
              SizedBox(height: 70),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 70),
                height: 54,
                width: MediaQuery.of(context).size.width,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(9)),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (BuildContext context) => LoginPage(
                          identifier: _identifier,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    textStyle: const TextStyle(
                      fontSize: 26.0,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "COMENZAR",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Produt Sans',
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 15),
                child: Text(
                  "Transportes Belchez S.A. De C.V.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                      fontSize: 15),
                ),
              ),
              SizedBox(height: 35),
            ],
          )
        ],
      ),
    );
  }
}

class _backgroundGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                  background.withOpacity(1),
                  background.withOpacity(1),
                  background.withOpacity(1),
                  background.withOpacity(1),
                  background.withOpacity(1),
                  background.withOpacity(0.1),
                  background.withOpacity(0.1),
                  background.withOpacity(0.1),
                  background.withOpacity(0.1),
                  background.withOpacity(0.1),
                ])),
          ),
        )
      ],
    );
  }
}

class _backgroundImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Builder(
            builder: (context) {
              final double height = MediaQuery.of(context).size.height * 0.9;
              return CarouselSlider(
                options: CarouselOptions(
                  height: height,
                  viewportFraction: .8,
                  aspectRatio: 16 / 9,
                  enlargeCenterPage: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayCurve: Curves.easeOutSine,
                  enlargeFactor: 0.2,
                ),
                items: imgList
                    .map((item) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                item,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.1,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 22, 22, 22),
                                  Color.fromARGB(255, 22, 22, 22)
                                      .withOpacity(0.8),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ),
        Expanded(flex: 2, child: Container()),
      ],
    );
  }
}
