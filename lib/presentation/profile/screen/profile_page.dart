import 'package:blog/common/widgets/appbar/appbar.dart';
import 'package:blog/presentation/profile/bloc/profile_bloc.dart';
import 'package:blog/presentation/profile/bloc/profile_event.dart';
import 'package:blog/presentation/profile/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  final String userUid;
  final String username;
  final String name;
  final String email;
  const ProfilePage(
      {super.key,
      required this.userUid,
      required this.username,
      required this.name,
      required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(LoadUserData(widget.userUid)),
      child: Scaffold(
        appBar: const BasicAppBar(),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return Center(
                  child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    'Loading user data',
                    style: GoogleFonts.robotoMono(),
                  )
                ],
              ));
            }
            if (state is UserError) {
              return Center(
                child: Text("Error: ${state.message}",
                    style: GoogleFonts.robotoMono()),
              );
            }
            if (state is UserLoaded) {
              return Center(
                child: Column(
                  children: [
                    const Text('Profile Page'),
                    Text('Username: ${widget.username}'),
                    Text('Name: ${widget.name}'),
                    Text('Email: ${widget.email}'),
                    Text('User UID: ${widget.userUid}'),
                    Text('User UID Loaded from data: ${state.userData.uid}'),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
