import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:story/core/constants/AppColors.dart';
import 'package:story/presentation/screens/rank/rank_screen.dart';

import 'core/services/auth_provider_check.dart';
import 'firebase_options.dart';
import 'presentation/screens/favourite/favourite_screen.dart';
import 'presentation/screens/home/main_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'routes/FirebaseApi.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Gọi Firebase API an toàn
  final firebaseApi = FirebaseApi();
  await firebaseApi.initNotifications();
  if (Platform.isAndroid) {
    // Chỉ chạy logic Firebase Messaging trên Android/iOS.
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
  }
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProviderCheck())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final int initialIndex;

  const MyHomePage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    _pageController.jumpToPage(index);
  }

  List<Widget> get _pages => [
        NewStoryListPage(key: PageStorageKey('home')),
        RankScreen(title: '', key: PageStorageKey('showMore')),
        FavouritePage(key: PageStorageKey('favourite')),
        ProfilePage(key: PageStorageKey('profile')),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Xếp hạng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Tủ truyện',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box_outlined),
            label: 'Tài khoản',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.rebeccaPurple,
        unselectedItemColor: AppColors.thistle,
        onTap: _onTap,
      ),
    );
  }
}
