import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Poppins',

        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          primaryContainer: Color(0xFF2A2850),
          secondary: AppColors.accent,
          secondaryContainer: Color(0xFF003D30),
          surface: AppColors.surface,
          error: AppColors.danger,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.onSurface,
          onError: Colors.white,
          outline: AppColors.outline,
        ),

        scaffoldBackgroundColor: AppColors.background,

        // ── AppBar ────────────────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: AppColors.surface,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          iconTheme: IconThemeData(color: AppColors.onSurface, size: 22),
          titleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
            fontFamily: 'Poppins',
            letterSpacing: -0.3,
          ),
        ),

        // ── Navigation Bar ────────────────────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          height: 64,
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                fontFamily: 'Poppins',
              );
            }
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
              fontFamily: 'Poppins',
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primary, size: 22);
            }
            return const IconThemeData(
                color: AppColors.onSurfaceVariant, size: 22);
          }),
        ),

        // ── Elevated Button ───────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.surfaceVariant,
            disabledForegroundColor: AppColors.onSurfaceVariant,
            elevation: 0,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ),

        // ── Text Button ───────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ),

        // ── Input ─────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outline, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outline, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(
            color: AppColors.onSurfaceMuted,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
          labelStyle: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),

        // ── Card ──────────────────────────────────────────
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.outline, width: 0.5),
          ),
          margin: EdgeInsets.zero,
        ),

        // ── Dialog ────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.outline, width: 0.5),
          ),
          titleTextStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            fontFamily: 'Poppins',
          ),
          contentTextStyle: const TextStyle(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
            fontFamily: 'Poppins',
            height: 1.5,
          ),
        ),

        // ── SnackBar ──────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surfaceElevated,
          contentTextStyle: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 13,
            fontFamily: 'Poppins',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 0,
        ),

        // ── Bottom Sheet ──────────────────────────────────
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          dragHandleColor: AppColors.outlineLight,
          showDragHandle: true,
        ),

        // ── Popup Menu ────────────────────────────────────
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.surfaceElevated,
          surfaceTintColor: Colors.transparent,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.outline, width: 0.5),
          ),
          textStyle: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),

        // ── Divider ───────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.outline,
          thickness: 0.5,
          space: 0,
        ),

        // ── Checkbox ──────────────────────────────────────
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
          side: const BorderSide(color: AppColors.outline, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        // ── Switch ────────────────────────────────────────
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return AppColors.onSurfaceVariant;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.surfaceVariant;
          }),
        ),

        // ── FAB ───────────────────────────────────────────
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          extendedTextStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),

        // ── ListTile ──────────────────────────────────────
        listTileTheme: const ListTileThemeData(
          tileColor: Colors.transparent,
          iconColor: AppColors.onSurfaceVariant,
          textColor: AppColors.onSurface,
          titleTextStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
            fontFamily: 'Poppins',
          ),
          subtitleTextStyle: TextStyle(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
            fontFamily: 'Poppins',
          ),
        ),

        // ── Text Theme ────────────────────────────────────
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            fontFamily: 'Poppins',
            letterSpacing: -1,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            fontFamily: 'Poppins',
            letterSpacing: -0.5,
          ),
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            fontFamily: 'Poppins',
            letterSpacing: -0.3,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
            fontFamily: 'Poppins',
          ),
          titleLarge: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
            fontFamily: 'Poppins',
          ),
          titleMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
            fontFamily: 'Poppins',
          ),
          titleSmall: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
            fontFamily: 'Poppins',
          ),
          bodyLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurface,
            fontFamily: 'Poppins',
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurfaceVariant,
            fontFamily: 'Poppins',
            height: 1.5,
          ),
          bodySmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurfaceMuted,
            fontFamily: 'Poppins',
          ),
          labelLarge: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
            fontFamily: 'Poppins',
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
            fontFamily: 'Poppins',
            letterSpacing: 0.5,
          ),
        ),
      );

  // Alias pentru backward compat
  static ThemeData get lightTheme => darkTheme;
}
