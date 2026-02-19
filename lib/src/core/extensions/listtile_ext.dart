import 'package:flutter/material.dart';

extension ListTileX on ListTile {
  Widget decorated({
    Color? backgroundColor,
    Color? borderColor,
    double radius = 8,
    double elevation = 0,
  }) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: borderColor != null
            ? BorderSide(color: borderColor)
            : BorderSide.none,
      ),
      child: this,
    );
  }
}
