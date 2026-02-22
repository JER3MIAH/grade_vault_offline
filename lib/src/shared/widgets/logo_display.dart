import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class LogoDisplay extends StatelessWidget {
  final String? logo;
  const LogoDisplay({super.key, required this.logo});

  @override
  Widget build(BuildContext context) {
    if (logo != null) {
      return Image.memory(
        Uint8List.fromList(base64Decode(logo!)),
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Container(
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported_outlined),
        ),
      );
    }
    return Image.asset(
      'assets/app_icon_no_bg.png',
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined),
      ),
    );
  }
}
