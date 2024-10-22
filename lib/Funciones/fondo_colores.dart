import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

Future<Color> _updatePalette(String imageUrl) async {
  try {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      NetworkImage(imageUrl),
    );
    return paletteGenerator.dominantColor?.color ?? Colors.grey;
  } catch (e) {
    // Handle exceptions if needed
    return Colors.grey;
  }
}
