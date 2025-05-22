import 'package:flutter/material.dart';
import 'package:plantapp/constant.dart';
import 'package:plantapp/screens/home/components/featured_plants.dart';
import 'package:plantapp/screens/home/components/header_with_searchbox.dart';
import 'package:plantapp/screens/home/components/see_map_button.dart';
import 'package:plantapp/screens/home/components/recomend_plants.dart';
import 'package:plantapp/screens/home/components/title_with_more_btn.dart';
import 'package:plantapp/screens/order/see_map.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String? _alamatDipilih;

  Future<void> _pilihAlamat() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SeeMap()), 
    );

    if (result != null && result is String) {
      setState(() {
        _alamatDipilih = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          HeaderWithSearchBox(size: size),
          TitleWithMoreBtn(title: "Recommended", press: () {}),
          RecomendsPlants(),
          TitleWithMoreBtn(title: "Featured Plants", press: () {}),
          FeaturedPlants(),
          const SizedBox(height: kDefaultPadding),
          OrderButton(
            press: _pilihAlamat,
            alamatDipilih: _alamatDipilih,
          ),
        ],
      ),
    );
  }
}
