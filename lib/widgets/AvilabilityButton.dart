import 'package:flutter/material.dart';

import '../brand_colors.dart';

class AvilabilityButton extends StatelessWidget {

  final String title;
  final VoidCallback? onPressed;
  final Color color;

  AvilabilityButton({required this.title, required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        onPressed: onPressed,
        color: color,
        textColor: color,
        child: SizedBox(
          height: 50.0,
          width: 200,
          child: Center(
            child: Text(title,
                style: const TextStyle(fontSize: 20.0, fontFamily: 'Brand-Bold', color: BrandColors.colorText)),
          ),
        )
    );
  }
}


