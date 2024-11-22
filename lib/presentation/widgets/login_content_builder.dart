import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/auth_provider_check.dart';
import '../../models/story.dart';

class LoginContentBuilder extends StatelessWidget {
  final Future<List<Story>> futureStories;
  final Widget Function(List<Story> stories) storyBuilder;

  const LoginContentBuilder({
    Key? key,
    required this.futureStories,
    required this.storyBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviderCheck>(builder: (context, authProvider, child) {
      if (!authProvider.isLoggedIn) {
        return const Center(child: Text('Chưa đăng nhập'));
      }
      return FutureBuilder<List<Story>>(
        future: futureStories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return storyBuilder(snapshot.data!);
          } else {
            return const Center(child: Text('No stories found.'));
          }
        },
      );
    });
  }
}
