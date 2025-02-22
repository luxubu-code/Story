import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:story/core/constants/AppColors.dart';
import 'package:story/presentation/screens/rank/rank_screen.dart';

import 'core/services/provider/auth_provider_check.dart';
import 'core/services/provider/rank_provider.dart';
import 'core/services/provider/subscription_provider.dart';
import 'core/services/provider/user_provider.dart';
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
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProviderCheck()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RankStateProvider()),
        ChangeNotifierProvider(
            create: (_) => SubscriptionProvider(
                dio: Dio() // Configure your Dio instance as needed
                ))
      ],
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
      home: MyHomePage(key: MyHomePage.globalKey),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final int initialIndex;
  final int rankTabIndex;

  const MyHomePage({
    Key? key,
    // Thêm validator cho initialIndex
    this.initialIndex = 0,
    this.rankTabIndex = 0,
  })  : assert(initialIndex >= 0 && initialIndex <= 3),
        // Đảm bảo initialIndex hợp lệ
        super(key: key);
  static final GlobalKey<_MyHomePageState> globalKey = GlobalKey();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _selectedIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _selectedIndex = index;
        _pageController.jumpToPage(index);
      });
    }
  }

  List<Widget> get _pages => [
        NewStoryListPage(key: PageStorageKey('home')),
        RankScreen(
          key: PageStorageKey('showMore'),
          initialTabIndex: widget.rankTabIndex, // Use the passed tab index
        ),
        FavouritePage(key: PageStorageKey('favourite')),
        ProfilePage(key: PageStorageKey('profile')),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (_selectedIndex != index) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        children: _pages,
        physics: const NeverScrollableScrollPhysics(),
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
