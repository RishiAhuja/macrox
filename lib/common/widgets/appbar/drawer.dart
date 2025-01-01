import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BasicDrawer extends StatelessWidget {
  const BasicDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        // const DrawerHeader(child: Text('Blog')),
        // ListTile(
        //   title: Text(
        //     'Blog',
        //     style: GoogleFonts.robotoMono(fontSize: 13.sp),
        //   ),
        // ),
        ListTile(
            title: Text('Home', style: GoogleFonts.robotoMono(fontSize: 18))),
        ListTile(
            title: Text('Users', style: GoogleFonts.robotoMono(fontSize: 18))),
        ListTile(
          title: Text(
            'Explore',
            style: GoogleFonts.robotoMono(fontSize: 18),
          ),
        ),
      ],
    ));
  }
}
