import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:phicargo/nav.dart';

class SplashScreen2 extends StatefulWidget {
  @override
  State<SplashScreen2> createState() => _SplashScreenState2();
}

class _SplashScreenState2 extends State<SplashScreen2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: EasySplashScreen(
      loadingText: const Text(
        'Cargando',
        style: TextStyle(fontFamily: 'Product Sans', color: Colors.white),
      ),
      logo: Image.asset(
        'assets/logo.png',
      ),
      logoWidth: 100,
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      showLoader: true,
      loaderColor: Colors.white,
      navigator: Nav(selectedIndex: 0),
      durationInSeconds: 2,
    ));
  }
}
