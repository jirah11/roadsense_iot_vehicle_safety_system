import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AppColors{
  static const backgroundStart = Color(0xFF213448);
  static const backgroundMid = Color(0xFF2A4359);
  static const backgroundEnd = Color(0xFF213448);
  static const cardDark = Color(0xFF4A5F78);
  static const cardDarker= Color(0xFF3D4F64);
  static const cardDarkest = Color(0xFF2F3D54);
  static const primary = Color(0xFF547792);
  static const primaryLight = Color(0xFF5C84A0);
  static const accent = Color(0xFF94B4C1);
  static const accentLight = Color(0xFFA0C0CC);
  static const rose = Color(0xFFEF4444);
  static const roseDark = Color(0xFFDC2626);
  static const emerald = Color(0xFF10B981);
  static const emeraldDark = Color(0xFF059669);
  static const caution = Color(0xFFD4A017);
  static const cautionDark = Color(0xFFB8860B);
  static const white = Colors.white;
}

class AppTextStyles {
  static TextStyle h1(BuildContext context) => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );
  static TextStyle h2(BuildContext context) => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );
  static TextStyle h3(BuildContext context) => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
  static TextStyle body(BuildContext context) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );
  static TextStyle bodyMuted(BuildContext context) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.white.withValues(alpha: 0.7),
  );
  static TextStyle caption(BuildContext context) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.accent,
  );
  static TextStyle captionMuted(BuildContext context) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.white.withValues(alpha: 0.5),
  );
}