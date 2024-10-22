import 'package:flutter/material.dart';
import 'package:phicargo/nav.dart';

class YaAsignado extends StatelessWidget {
  const YaAsignado({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 22, 22, 22),
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/mio.jpg",
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
                      Color.fromARGB(255, 22, 22, 22).withOpacity(0.8),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Ya tienes un viaje asignado\n",
                      style: TextStyle(
                          fontSize: 27,
                          color: Color.fromARGB(255, 255, 255, 255)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            child: Text('Ver viaje',
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 255, 255, 255))),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 34, 69, 151),
                              side: BorderSide(
                                  color: Color.fromARGB(255, 34, 69, 151),
                                  width: 1),
                              minimumSize: Size(150, 50),
                            ),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 154, 4, 4),
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 154, 4, 4),
                                  width: 1),
                              minimumSize: Size(150, 50),
                            ),
                            onPressed: () {
                              Navigator.pushAndRemoveUntil<dynamic>(
                                context,
                                MaterialPageRoute<dynamic>(
                                  builder: (BuildContext context) => Nav(
                                    selectedIndex: 0,
                                  ),
                                ),
                                (route) => false,
                              );
                            },
                            child: const Text('Volver',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 255, 255, 255))),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onWillPop: () async => false,
    );
  }
}
