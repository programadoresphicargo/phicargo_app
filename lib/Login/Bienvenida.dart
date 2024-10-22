import 'package:flutter/material.dart';
import 'package:phicargo/login/login.dart';
import 'package:phicargo/nav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Bienvenida extends StatefulWidget {
  const Bienvenida({super.key});

  @override
  State<Bienvenida> createState() => _BienvenidaState();
}

class _BienvenidaState extends State<Bienvenida> {
  void CheckLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? val = prefs.getString('id');

    if (val != null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => Nav(
                    selectedIndex: 0,
                  )),
          (route) => false);
    } else {}
  }

  @override
  void initState() {
    super.initState();
    CheckLogin();
  }

  final List<String> imgList = [
    'assets/mio.jpg',
    'assets/R2.jpg',
    'assets/fondo4.jpg',
    'assets/fondo.jpg',
    'assets/13.jpg',
    'assets/EEE.jpg'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 22, 22, 22),
      body: Column(
        children: [
          Builder(
            builder: (context) {
              final double height = MediaQuery.of(context).size.height * 0.65;
              return CarouselSlider(
                options: CarouselOptions(
                  height: height,
                  viewportFraction: 0.8,
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
                            height: MediaQuery.of(context).size.height * 0.2,
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(34, 0, 34, 34),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://phi-cargo.com/wp-content/uploads/2021/05/logo-phicargo-vertical.png',
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) => LoginPage(
                              identifier: '',
                            ),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 154, 4, 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          )),
                      child: const Text(
                        "INGRESAR",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
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
