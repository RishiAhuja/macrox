import 'package:blog/common/helper/extensions/is_dark.dart';
import 'package:blog/common/widgets/appbar/appbar.dart';
import 'package:blog/presentation/auth/bloc/auth_bloc.dart';
import 'package:blog/presentation/auth/bloc/auth_state.dart';
import 'package:blog/presentation/home/widgets/appbar_popup.dart';
import 'package:blog/presentation/landing/landing.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class Users extends StatelessWidget {
  const Users({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthSuccess) {
          return const Landing();
        }
        return Scaffold(
          appBar: BasicAppBar(
            isLanding: false,
            customActionWidgetPrefix: appBarInfoPopup(
                context.isDark,
                state.userEntity.name,
                state.userEntity.username,
                state.userEntity.email,
                state.userEntity.id),
          ),
          body: FirestorePagination(
            query: FirebaseFirestore.instance
                .collection('Users')
                .orderBy('followerCount', descending: true),
            itemBuilder: (context, docs, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(
                  child: Text(data['username'][0].toUpperCase()),
                ),
                title: Text(data['username']),
                subtitle: Text(data['email']),
                onTap: () =>
                    context.go('/profile/@${data['username']}', extra: {
                  'email': data['email'],
                  'name': data['name'],
                  'userUid': data['uid'],
                  'username': data['username'],
                }),
              );
            },
          ),
        );
      },
    );
  }
}
