import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.light(),
      home: Scaffold(
        body: Container(
          color: Colors.white,
          child: Column(
            //홈화면 소개
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 10),
                child: Image.asset(
                  //홈 화면의 아이콘 설정
                  'assets/images/new.png',
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width, //디바이스 전체 가로 길이
                  decoration: BoxDecoration(
                    border: Border.all(
                      //container의 border을 지정한다 두께 2
                      width: 2,
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(10.0), //둥글기를 지정
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 7.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, //중앙으로 모음
                      children: [
                        const Icon(
                          CupertinoIcons.chevron_left_slash_chevron_right,
                          color: Colors.black,
                        ),
                        Text(
                          '변수와 함수 이름을 정해드립니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontFamily: 'Jamsil'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width, //디바이스 전체 가로 길이
                  decoration: BoxDecoration(
                    border: Border.all(
                      //container의 border을 지정한다 두께 2
                      width: 2,
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(10.0), //둥글기를 지정
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 7.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, //중앙으로 모음
                      children: [
                        const Icon(CupertinoIcons.camera, color: Colors.black),
                        Text(
                          '코드 분석과 오류를 수정해드립니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontFamily: 'Jamsil'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width, //디바이스 전체 가로 길이
                  decoration: BoxDecoration(
                    border: Border.all(
                      //container의 border 두께 2
                      width: 2,
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 7.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, //중앙 정렬
                      children: [
                        const Icon(
                          CupertinoIcons.hammer,
                          color: Colors.black,
                        ),
                        Text(
                          '아이디어를 구현할 툴을 추천드립니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontFamily: 'Jamsil'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
