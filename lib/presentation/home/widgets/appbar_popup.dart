import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget appBarInfoPopup(
    bool isDark, String name, String username, String email, String id) {
  return PopupMenuButton<String>(
    elevation: 0,
    color: isDark ? const Color.fromARGB(255, 90, 90, 90) : Colors.white,
    enabled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
      side: BorderSide(
        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
      ),
    ),
    onSelected: (String choice) {},
    icon: const Icon(Icons.supervised_user_circle_sharp),
    itemBuilder: (BuildContext context) {
      return [
        PopupMenuItem<String>(
          enabled: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.spaceGrotesk(fontSize: 24),
                ),
                Text(
                  '@$username',
                  style: GoogleFonts.spaceGrotesk(
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                      fontSize: 18),
                ),
                Text(
                  email,
                  style: GoogleFonts.spaceGrotesk(
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                      fontSize: 18),
                ),
                Text(
                  id,
                  style: GoogleFonts.spaceGrotesk(
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                      fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ];
    },
  );
}
