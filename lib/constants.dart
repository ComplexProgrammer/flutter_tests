import 'package:flutter/material.dart';
import 'dart:ui';

const kPrimaryColor = Color(0xFF6366F1); // Radiant Indigo
const kAccentColor = Color(0xFF10B981); // Emerald Green
const kSecondaryColor = Color(0xFFF43F5E); // Rose Red
const kTextColor = Color(0xFF1E293B); // Slate Dark
const kTextLightColor = Color(0xFF64748B); // Slate Grey
const kFillStarColor = Color(0xFFF59E0B); // Amber
const kBackgroundColor = Color(0xFFF8FAFC); // Very Light Slate

const kDefaultPadding = 20.0;
const baseUrl = 'https://complexprogrammer.uz';
// const baseUrl = 'https://localhost:8000';

const kDefaultShadow = BoxShadow(
  offset: Offset(0, 10),
  blurRadius: 20,
  color: Color(0x1A000000), // Very subtle shadow
);

const kPremiumGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kPrimaryColor, Color(0xFF4F46E5)],
);

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
