import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

void failureAnimatedSnackbar(BuildContext context, String errorMessage) {
  return AnimatedSnackBar(
    builder: ((context) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color.fromARGB(255, 249, 79, 67)),
        padding: const EdgeInsets.all(8),
        height: 50,
        child: Row(
          children: [
            const Icon(Icons.error_outline_sharp, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              errorMessage,
              style: GoogleFonts.robotoMono(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }),
    desktopSnackBarPosition: DesktopSnackBarPosition.topRight,
    mobileSnackBarPosition: MobileSnackBarPosition.top,
  ).show(context);
}

void customAnimatedSnackbar(
    BuildContext context, String message, Color color, IconData icon) {
  return AnimatedSnackBar(
    builder: ((context) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color,
        ),
        padding: const EdgeInsets.all(8),
        height: 50,
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              message,
              style: GoogleFonts.robotoMono(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }),
    desktopSnackBarPosition: DesktopSnackBarPosition.topRight,
    mobileSnackBarPosition: MobileSnackBarPosition.top,
  ).show(context);
}
