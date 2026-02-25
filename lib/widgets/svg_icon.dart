import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;

/// gan'to gamitin SvgIcon('water-solid', size: 24, color: Colors.white)
class SvgIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;

  const SvgIcon(this.name, {super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'icons/$name.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}