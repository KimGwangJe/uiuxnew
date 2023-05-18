import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
                child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50.0, bottom: 10),
                  child: Text(
                    'Example',
                    style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Jamsil'),
                  ),
                ),
                Container(
                  height: 40,
                  width: 350,
                  color: Color.fromRGBO(246, 246, 246, 1),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '"백엔드 구현"',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontFamily: 'Jamsil'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    height: 40,
                    width: 350,
                    color: Color.fromRGBO(246, 246, 246, 1),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '"웹을 만드는 툴"',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontFamily: 'Jamsil'),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, bottom: 10),
                  child: Text(
                    'Capabilities',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Jamsil'),
                  ),
                ),
                Container(
                  height: 40,
                  width: 350,
                  color: Color.fromRGBO(246, 246, 246, 1),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '사용자와의 대화를 기억하지 못합니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontFamily: 'Jamsil'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    height: 40,
                    width: 350,
                    color: Color.fromRGBO(246, 246, 246, 1),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '대답이 나오는데 다소 시간이 소요됩니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontFamily: 'Jamsil'),
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
