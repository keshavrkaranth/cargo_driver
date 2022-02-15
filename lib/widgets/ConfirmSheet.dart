import 'package:cargo_driver/widgets/TaxiButton.dart';
import 'package:flutter/material.dart';

import '../brand_colors.dart';

class ConfirmSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onPressed;
  const ConfirmSheet(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15.0,
            spreadRadius: 0.5,
            offset: Offset(0.7, 0.7),
          ),
        ],
      ),
      height: 220,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 10.0,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 22,
                  fontFamily: 'Brand-Bold',
                  color: BrandColors.colorText),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: BrandColors.colorTextLight),
            ),
            const SizedBox(
              height: 24,
            ),
            Row(
              children: <Widget>[
                Expanded(
                    child: Container(
                        child: TaxiOutlineButton(
                            title: "Back",
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            color: BrandColors.colorLightGrayFair))),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                    child: Container(
                        child: TaxiOutlineButton(
                            title: "Confirm",
                            onPressed: onPressed,
                            color: (title=='GO ONLINE') ? BrandColors.colorGreen : Colors.red))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
