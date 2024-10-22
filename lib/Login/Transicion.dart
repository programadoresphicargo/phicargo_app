import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:phicargo/nav.dart';

class Transicion extends StatefulWidget {
  @override
  State<Transicion> createState() => _TransicionState();
}

class _TransicionState extends State<Transicion> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(milliseconds: 1500),
      (() => Navigator.of(context).pushReplacement(
            PageTransition(
              type: PageTransitionType.bottomToTop,
              duration: const Duration(seconds: 1),
              child: Nav(
                selectedIndex: 0,
              ),
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 34, 69, 151),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Spacer(),
            Center(
              child: FractionallySizedBox(
                widthFactor: .8,
                child: Image.asset(
                  "assets/logo_1.png",
                  color: Colors.white,
                  height: 260,
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
