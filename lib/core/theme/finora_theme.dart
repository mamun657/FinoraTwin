import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Premium FinoraTwin design tokens.
//
// The brand identity is centered on an indigo→violet gradient (#6366F1 →
// #8B5CF6) paired with a calm teal accent and warm semantic colors. The goal
// is to feel like a modern, premium fintech — not a generic admin tool.
// ─────────────────────────────────────────────────────────────────────────────

class FinoraColors {
  FinoraColors._();

  // Core brand
  static const Color brandPrimary = Color(0xFFE83E83);
  static const Color brandPrimaryDark = Color(0xFFC92668);
  static const Color brandPrimarySoft = Color(0xFFFFEDF5);

  static const Color brandViolet = Color(0xFF7957E8);
  static const Color brandVioletDark = Color(0xFF7C3AED);

  // Accent — calm teal
  static const Color brandAccent = Color(0xFF14B8A6);
  static const Color brandAccentDark = Color(0xFF0F9488);
  static const Color brandAccentSoft = Color(0xFFE6FAF7);

  // Surface system (light)
  static const Color surface = Color(0xFFF6F7FB);
  static const Color surfaceAlt = Color(0xFFFFFFFF);
  static const Color surfaceTint = Color(0xFFEEF0FF);

  // Outlines / dividers
  static const Color outline = Color(0xFFE3E6EF);
  static const Color outlineSoft = Color(0xFFEEF0F6);

  // Text
  static const Color textPrimary = Color(0xFF0E1726);
  static const Color textSecondary = Color(0xFF59617A);
  static const Color textMuted = Color(0xFF8B94A8);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Semantic
  static const Color positive = Color(0xFF16A34A); // green-600
  static const Color positiveSoft = Color(0xFFDCFCE7);
  static const Color negative = Color(0xFFDC2626); // red-600
  static const Color negativeSoft = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFD97706); // amber-600
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF2563EB); // blue-600
  static const Color infoSoft = Color(0xFFDBEAFE);

  // Health scale (kept aligned with the backend scoring buckets)
  static const Color healthStrong = Color(0xFF16A34A);
  static const Color healthHealthy = Color(0xFF16A34A);
  static const Color healthFair = Color(0xFFD97706);
  static const Color healthWeak = Color(0xFFDC2626);
}

class FinoraSpacing {
  FinoraSpacing._();
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

class FinoraRadii {
  FinoraRadii._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pill = 999;
}

/// Shadow tokens for soft elevation. Premium UIs avoid sharp grey shadows —
/// we use tinted, low-spread shadows so cards feel layered, not stamped.
class FinoraShadows {
  FinoraShadows._();

  static List<BoxShadow> get xs => const [
    BoxShadow(
      color: Color(0x0A0F172A),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get sm => const [
    BoxShadow(
      color: Color(0x0F0F172A),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get md => const [
    BoxShadow(
      color: Color(0x1A0F172A),
      offset: Offset(0, 6),
      blurRadius: 16,
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> get lg => const [
    BoxShadow(
      color: Color(0x14130F2A),
      offset: Offset(0, 12),
      blurRadius: 32,
      spreadRadius: -6,
    ),
  ];

  /// Indigo-tinted glow for elevated surfaces (CTA buttons, hero cards).
  static List<BoxShadow> get brandGlow => const [
    BoxShadow(
      color: Color(0x406366F1),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: -2,
    ),
  ];
}

/// Gradient tokens. We expose helpers for the most common brand gradients
/// so screen widgets stay declarative.
class FinoraGradients {
  FinoraGradients._();

  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE83E83), Color(0xFF7957E8)],
  );

  static const LinearGradient brandVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE83E83), Color(0xFFC92668)],
  );

  static const RadialGradient brandRadial = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.4,
    colors: [Color(0xFF7957E8), Color(0xFFE83E83)],
  );

  static const LinearGradient mint = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF14B8A6), Color(0xFF22D3BE)],
  );

  static const LinearGradient positive = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
  );

  static const LinearGradient warning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEAB308), Color(0xFFF59E0B)],
  );

  static const LinearGradient danger = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
  );

  /// Soft tinted wash used for hero backgrounds on light cards.
  static const LinearGradient heroWash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEEF0FF), Color(0xFFF7F4FF)],
  );

  static const LinearGradient neutral = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAFBFF), Color(0xFFF1F4FB)],
  );

  static const LinearGradient sunset = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B9D), Color(0xFFFFB07C)],
  );

  static const LinearGradient ocean = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
  );

  static const LinearGradient forest = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF14B8A6), Color(0xFF22C55E)],
  );

  static const LinearGradient amber = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
  );

  static const LinearGradient violet = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
  );

  static const LinearGradient midnight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1B4B), Color(0xFF7C3AED)],
  );

  static const LinearGradient indigo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  static const LinearGradient blush = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC8DD), Color(0xFFE83E83)],
  );

  static const List<LinearGradient> featureCycle = [
    brand,
    ocean,
    forest,
    amber,
    violet,
    sunset,
  ];

  static LinearGradient byIndex(int index) {
    if (featureCycle.isEmpty) return brand;
    final i = index.abs() % featureCycle.length;
    return featureCycle[i];
  }
}

class FinoraHeroPalettes {
  FinoraHeroPalettes._();

  static const List<Color> dashboardMesh = [
    Color(0xFFFF6FA3),
    Color(0xFFE83E83),
    Color(0xFF7957E8),
    Color(0xFF1E1B4B),
  ];

  static const List<Color> healthMesh = [
    Color(0xFF14B8A6),
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFF1E1B4B),
  ];

  static const List<Color> riskMesh = [
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFF7C3AED),
    Color(0xFF1E1B4B),
  ];

  static const List<Color> successMesh = [
    Color(0xFF22C55E),
    Color(0xFF14B8A6),
    Color(0xFF6366F1),
    Color(0xFF1E1B4B),
  ];
}

/// Animation duration tokens. Keeping these centralized keeps motion coherent
/// across the app.
class FinoraMotion {
  FinoraMotion._();
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration page = Duration(milliseconds: 360);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubic;
}

/// Builds the premium `ThemeData` for FinoraTwin. The look-and-feel is built
/// around a soft surface stack, tinted shadows and a single brand gradient.
ThemeData buildFinoraTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final base = isDark ? ThemeData.dark() : ThemeData.light();

  final textTheme = GoogleFonts.interTextTheme(base.textTheme)
      .apply(
        bodyColor: FinoraColors.textPrimary,
        displayColor: FinoraColors.textPrimary,
      )
      .copyWith(
        displayLarge: GoogleFonts.sora(
          fontWeight: FontWeight.w800,
          color: FinoraColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.sora(
          fontWeight: FontWeight.w800,
          color: FinoraColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.sora(
          fontWeight: FontWeight.w800,
          color: FinoraColors.textPrimary,
          letterSpacing: -0.3,
        ),
        headlineLarge: GoogleFonts.sora(
          fontWeight: FontWeight.w800,
          color: FinoraColors.textPrimary,
          letterSpacing: -0.3,
        ),
        headlineMedium: GoogleFonts.sora(
          fontWeight: FontWeight.w800,
          color: FinoraColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.sora(
          fontWeight: FontWeight.w700,
          color: FinoraColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: FinoraColors.textPrimary,
        ),
      );

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: FinoraColors.brandPrimary,
    onPrimary: Colors.white,
    secondary: FinoraColors.brandAccent,
    onSecondary: Colors.white,
    tertiary: FinoraColors.brandViolet,
    onTertiary: Colors.white,
    error: FinoraColors.negative,
    onError: Colors.white,
    surface: isDark ? const Color(0xFF121826) : FinoraColors.surfaceAlt,
    onSurface: FinoraColors.textPrimary,
    outline: FinoraColors.outline,
  );

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: isDark
        ? const Color(0xFF0B101B)
        : FinoraColors.surface,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 20,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: FinoraColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: FinoraColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: isDark ? const Color(0xFF121826) : FinoraColors.surfaceAlt,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FinoraRadii.lg),
        side: BorderSide(color: FinoraColors.outline.withValues(alpha: 0.6)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF121826) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      labelStyle: const TextStyle(
        color: FinoraColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(color: FinoraColors.textMuted),
      helperStyle: const TextStyle(color: FinoraColors.textMuted, fontSize: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FinoraRadii.md),
        borderSide: const BorderSide(color: FinoraColors.outline, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FinoraRadii.md),
        borderSide: const BorderSide(color: FinoraColors.outline, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FinoraRadii.md),
        borderSide: const BorderSide(
          color: FinoraColors.brandPrimary,
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FinoraRadii.md),
        borderSide: const BorderSide(color: FinoraColors.negative),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: FinoraColors.brandPrimary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FinoraRadii.md),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.1,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: FinoraColors.brandPrimary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FinoraRadii.md),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: FinoraColors.brandPrimary,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: FinoraColors.outline, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FinoraRadii.md),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: FinoraColors.brandPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    dividerColor: FinoraColors.outline,
    dividerTheme: const DividerThemeData(
      color: FinoraColors.outline,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: FinoraColors.textPrimary,
      contentTextStyle: const TextStyle(color: Colors.white),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FinoraRadii.md),
      ),
    ),
    iconTheme: const IconThemeData(color: FinoraColors.textPrimary),
    splashFactory: InkRipple.splashFactory,
  );
}

Color healthColorFor(String status) {
  switch (status.toLowerCase()) {
    case 'strong':
      return FinoraColors.healthStrong;
    case 'healthy':
      return FinoraColors.healthHealthy;
    case 'moderate':
    case 'fair':
      return FinoraColors.healthFair;
    case 'weak':
    case 'critical':
      return FinoraColors.healthWeak;
    default:
      return FinoraColors.healthHealthy;
  }
}

Color riskColorFor(String risk) {
  switch (risk.toLowerCase()) {
    case 'low':
      return FinoraColors.positive;
    case 'medium':
    case 'moderate':
      return FinoraColors.warning;
    case 'high':
    case 'severe':
      return FinoraColors.negative;
    default:
      return FinoraColors.textSecondary;
  }
}

IconData riskIconFor(String risk) {
  switch (risk.toLowerCase()) {
    case 'low':
      return Icons.shield_outlined;
    case 'medium':
    case 'moderate':
      return Icons.error_outline;
    case 'high':
    case 'severe':
      return Icons.warning_amber_rounded;
    default:
      return Icons.help_outline;
  }
}

LinearGradient riskGradientFor(String risk) {
  switch (risk.toLowerCase()) {
    case 'low':
      return FinoraGradients.positive;
    case 'medium':
    case 'moderate':
      return FinoraGradients.warning;
    case 'high':
    case 'severe':
      return FinoraGradients.danger;
    default:
      return FinoraGradients.neutral;
  }
}

class FinoraTextStyles {
  FinoraTextStyles._();

  static const TextStyle display = TextStyle(
    fontFamily: 'Sora',
    fontSize: 34,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.5,
    color: FinoraColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontFamily: 'Sora',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.2,
    color: FinoraColors.textPrimary,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: 'Sora',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: FinoraColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'Sora',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: FinoraColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.35,
    color: FinoraColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: FinoraColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: FinoraColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: FinoraColors.textPrimary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: FinoraColors.textPrimary,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 1.2,
    color: FinoraColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: FinoraColors.textSecondary,
  );

  static const TextStyle metric = TextStyle(
    fontFamily: 'Sora',
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.4,
    color: FinoraColors.textPrimary,
  );

  static const TextStyle metricSmall = TextStyle(
    fontFamily: 'Sora',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: FinoraColors.textPrimary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: 0.2,
    color: FinoraColors.textInverse,
  );
}

class FinoraElevation {
  FinoraElevation._();

  static const double flat = 0;
  static const double low = 1;
  static const double medium = 3;
  static const double high = 6;
  static const double overlay = 12;

  static List<BoxShadow> shadowFor(double elevation) {
    if (elevation <= 0) return const [];
    if (elevation <= 1) return FinoraShadows.xs;
    if (elevation <= 3) return FinoraShadows.sm;
    if (elevation <= 6) return FinoraShadows.md;
    return FinoraShadows.lg;
  }
}

enum FinoraBadgeTone { brand, positive, warning, negative, info, neutral }

Color finoraBadgeBg(FinoraBadgeTone tone) {
  switch (tone) {
    case FinoraBadgeTone.brand:
      return FinoraColors.brandPrimarySoft;
    case FinoraBadgeTone.positive:
      return FinoraColors.positiveSoft;
    case FinoraBadgeTone.warning:
      return FinoraColors.warningSoft;
    case FinoraBadgeTone.negative:
      return FinoraColors.negativeSoft;
    case FinoraBadgeTone.info:
      return FinoraColors.infoSoft;
    case FinoraBadgeTone.neutral:
      return FinoraColors.outlineSoft;
  }
}

Color finoraBadgeFg(FinoraBadgeTone tone) {
  switch (tone) {
    case FinoraBadgeTone.brand:
      return FinoraColors.brandPrimaryDark;
    case FinoraBadgeTone.positive:
      return FinoraColors.positive;
    case FinoraBadgeTone.warning:
      return FinoraColors.warning;
    case FinoraBadgeTone.negative:
      return FinoraColors.negative;
    case FinoraBadgeTone.info:
      return FinoraColors.info;
    case FinoraBadgeTone.neutral:
      return FinoraColors.textSecondary;
  }
}
