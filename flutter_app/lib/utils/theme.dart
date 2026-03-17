import 'package:flutter/material.dart';

class ThemeUtils {
    static ThemeData get theme {
        return ThemeData(
            cardTheme: CardThemeData( // Changed from CardTheme to CardThemeData
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                ),
            ),
            // Other theme properties...
        );
    }
}