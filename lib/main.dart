import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './Tab/Home.dart';
import 'Tab/Recommend/Recommend.dart';
import 'Tab/tools/tools.dart';
import 'Tab/Camera/cameraMain.dart';

void main() {
  runApp(MyApp());
}

class SplashScreen extends StatelessWidget {
  // 처음 어플에 들어오면 3초동안 보여지는 화면
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Image.asset(
            'assets/images/new2.png',
            height: 300,
            width: MediaQuery.of(context).size.width,
          ), // 로고 이미지를 표시
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = [
    Home(),
    Recommend(),
    CameraMain(),
    Tools(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), //3초로 제한
    );

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.ease));

    _animationController.forward().then((_) {
      setState(() {
        _selectedIndex = 0;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.light(),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: _animation.isCompleted
            ? _widgetOptions.elementAt(_selectedIndex)
            : AnimatedBuilder(
                animation: _animationController,
                builder: (BuildContext context, Widget? child) {
                  return Opacity(
                    opacity: _animation.value,
                    child: SplashScreen(),
                  );
                },
              ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: _selectedIndex == 0
                  ? const Icon(
                      CupertinoIcons.house,
                      color: Colors.greenAccent,
                    )
                  : const Icon(CupertinoIcons.house, color: Colors.black),
              label: 'home',
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 1
                  ? const Icon(
                      CupertinoIcons.chevron_left_slash_chevron_right,
                      color: Colors.greenAccent,
                    )
                  : const Icon(
                      CupertinoIcons.chevron_left_slash_chevron_right,
                      color: Colors.black,
                    ),
              label: 'recommend',
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 2
                  ? const Icon(
                      CupertinoIcons.camera,
                      color: Colors.greenAccent,
                    )
                  : const Icon(CupertinoIcons.camera, color: Colors.black),
              label: '주석',
            ),
            BottomNavigationBarItem(
              icon: _selectedIndex == 3
                  ? const Icon(
                      CupertinoIcons.hammer,
                      color: Colors.greenAccent,
                    )
                  : const Icon(
                      CupertinoIcons.hammer,
                      color: Colors.black,
                    ),
              label: 'tool',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          onTap: _onItemTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ),
      ),
    );
  }
}
