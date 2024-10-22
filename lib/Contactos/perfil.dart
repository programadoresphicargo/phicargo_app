import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class Profile extends StatelessWidget {
  var user;
  String foto;
  String nombre;
  String puesto;
  String numero;

  Profile(
      {super.key,
      required this.user,
      required this.foto,
      required this.nombre,
      required this.puesto,
      required this.numero});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            delegate: SilverPersistenDelegate(foto: foto, nombre: nombre),
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Column(children: [
              Container(
                padding: EdgeInsets.all(25),
                child: Column(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      nombre,
                      style: TextStyle(
                          fontFamily: 'Product Sans',
                          color: Colors.blue.shade700,
                          fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      puesto,
                      style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0), fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      numero,
                      style: TextStyle(
                          fontFamily: 'Product Sans',
                          color: Colors.grey[600],
                          fontSize: 20),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CrearIcono(
                            icon: Icons.abc, text: 'Llamar', numero: numero)
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 300),
              SizedBox(height: 300),
              SizedBox(height: 300),
              SizedBox(height: 300),
              SizedBox(height: 300),
            ]),
          )
        ],
      ),
    );
  }

  _callNumber(number) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(number);
  }

  CrearIcono(
      {required IconData icon, required String text, required String numero}) {
    return InkWell(
      onTap: () {
        _callNumber(numero);
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.call,
              size: 30,
              color: Colors.blue.shade700,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              text,
              style: TextStyle(
                  fontFamily: 'Product Sans', color: Colors.blue.shade700),
            )
          ],
        ),
      ),
    );
  }
}

class SilverPersistenDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeaderHeight = 180;
  final double minHeaderHeight = kToolbarHeight + 20;
  final double maxImageSize = 130;
  final double minImageSize = 40;

  String foto;
  String nombre;

  SilverPersistenDelegate({required this.nombre, required this.foto});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final size = MediaQuery.of(context).size;
    final percent = shrinkOffset / (maxHeaderHeight - 35);
    final percent2 = shrinkOffset / (maxHeaderHeight);

    final currentImageSize =
        (maxImageSize * (1 - percent)).clamp(minImageSize, maxImageSize);
    final currentImagePosition = ((size.width / 2 - 65) * (1 - percent))
        .clamp(minImageSize, maxImageSize);
    return Container(
      color: Colors.blue.shade700,
      child: Stack(children: [
        Positioned(
          left: currentImagePosition + 50,
          top: MediaQuery.of(context).viewPadding.top + 18,
          child: Text(
            nombre,
            style: TextStyle(
                color: percent2 > .3 ? Colors.white : Colors.blue.shade700),
          ),
        ),
        Positioned(
            left: 10,
            top: MediaQuery.of(context).viewPadding.top + 5,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            )),
        Positioned(
            left: currentImagePosition,
            top: MediaQuery.of(context).viewPadding.top + 5,
            bottom: 0,
            child: Container(
              width: currentImageSize,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: foto != '0'
                          ? NetworkImage(foto)
                          : Image.asset(
                              "assets/perfil.png",
                            ).image)),
            ))
      ]),
    );
  }

  @override
  double get maxExtent => maxHeaderHeight;

  @override
  double get minExtent => minHeaderHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
