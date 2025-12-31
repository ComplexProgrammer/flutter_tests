import 'package:flutter/material.dart';
import 'dart:ui';

const kPrimaryColor = Color(0xFF6366F1); // Radiant Indigo
const kAccentColor = Color(0xFF10B981); // Emerald Green
const kSecondaryColor = Color(0xFFF43F5E); // Rose Red
const kTextColor = Color(0xFF1E293B); // Slate Dark
const kTextLightColor = Color(0xFF64748B); // Slate Grey
const kFillStarColor = Color(0xFFF59E0B); // Amber
const kBackgroundColor = Color(0xFFF8FAFC); // Very Light Slate

// Modern accent colors
const kPurpleAccent = Color(0xFF8B5CF6);
const kCyanAccent = Color(0xFF06B6D4);
const kPinkAccent = Color(0xFFEC4899);

const kDefaultPadding = 20.0;
const baseUrl = 'https://complexprogrammer.uz';
// const baseUrl = 'https://localhost:8000';

// Animation durations
const kAnimationDuration = Duration(milliseconds: 300);
const kAnimationDurationFast = Duration(milliseconds: 150);
const kAnimationDurationSlow = Duration(milliseconds: 500);

// Modern shadow with blur
const kDefaultShadow = BoxShadow(
  offset: Offset(0, 10),
  blurRadius: 20,
  color: Color(0x1A000000),
);

const kCardShadow = BoxShadow(
  offset: Offset(0, 8),
  blurRadius: 24,
  spreadRadius: -4,
  color: Color(0x20000000),
);

const kElevatedShadow = BoxShadow(
  offset: Offset(0, 16),
  blurRadius: 32,
  spreadRadius: -8,
  color: Color(0x25000000),
);

// Gradients
const kPremiumGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kPrimaryColor, Color(0xFF4F46E5)],
);

const kVibrantGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
);

const kDarkOverlayGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Colors.transparent, Color(0x80000000)],
);

const kLightOverlayGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0x00FFFFFF), Color(0x40FFFFFF)],
);

// Shimmer colors for loading
const kShimmerBaseColor = Color(0xFFE2E8F0);
const kShimmerHighlightColor = Color(0xFFF8FAFC);

// Border radius
const kCardBorderRadius = 24.0;
const kButtonBorderRadius = 16.0;

// Glassmorphism decoration
BoxDecoration kGlassmorphismDecoration({
  Color? color,
  double borderRadius = kCardBorderRadius,
}) {
  return BoxDecoration(
    color: (color ?? Colors.white).withOpacity(0.85),
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 1.5,
    ),
    boxShadow: const [kCardShadow],
  );
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
