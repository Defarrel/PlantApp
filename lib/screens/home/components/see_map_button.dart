import 'package:flutter/material.dart';
import 'package:plantapp/constant.dart';

class OrderButton extends StatelessWidget {
  final VoidCallback press;
  final String? alamatDipilih;

  const OrderButton({super.key, required this.press, this.alamatDipilih});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: kDefaultPadding,
                vertical: kDefaultPadding / 2,
              ),
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: press,
            child: const Text("Chose Address", style: TextStyle(color: Colors.white)),
          ),
        ),
        alamatDipilih == null
            ? const Text('Tidak ada alamat yang dipilih')
            : Text(alamatDipilih!),
        SizedBox(height: kDefaultPadding),
      ],
    );
  }
}
