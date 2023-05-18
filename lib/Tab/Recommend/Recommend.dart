import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Recommend extends StatefulWidget {
  const Recommend({Key? key}) : super(key: key);

  @override
  State<Recommend> createState() => _Recommend();
}

class _Recommend extends State<Recommend> {
  String gptquery = ''; //버튼을 누를시 textfield값을 변경
  final TextEditingController _textController = TextEditingController();
  String _generatedText = "";
  String _textValue = "";
  bool showActivityIndicator = false; //indicator

  Future<void> generateText(String prompt) async {
    String model = "text-davinci-003";
    String apiKey = "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";

    var response = await http.post(
      Uri.parse('https://api.openai.com/v1/engines/$model/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'prompt': prompt,
        'max_tokens': 2024,
        'temperature': 0.5,
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var generatedText = data['choices'][0]['text'];
      setState(() {
        _generatedText = utf8.decode(generatedText.codeUnits);
      });
    } else {
      setState(() {
        _generatedText = "Error: ${response.reasonPhrase}";
      });
    }
  }

  void indicate() {
    if (_generatedText == '') {
      setState(() {
        showActivityIndicator = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus(); // 키보드 닫기 이벤트
      },
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData.light(),
        home: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              '추천',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color.fromRGBO(73, 73, 73, 1),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height - 50,
                      child: (Column(children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: gptquery == ''
                              ? Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 50.0, bottom: 10),
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
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          '"1~10까지 더한 값을 저장할 변수"',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'Jamsil'),
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
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            '"더하기 기능을 수행할 함수 혹은 클래스"',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontFamily: 'Jamsil'),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 30.0, bottom: 10),
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
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          '사용자와의 대화를 기억하지 못합니다.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'Jamsil'),
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
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            '대답이 나오는데 다소 시간이 소요됩니다.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontFamily: 'Jamsil'),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              : Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  spreadRadius: 5,
                                                  blurRadius: 7,
                                                  offset: Offset(0,
                                                      3), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                '$gptquery',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.black,
                                                    fontFamily: 'Jamsil'),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black26,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  spreadRadius: 5,
                                                  blurRadius: 7,
                                                  offset: Offset(0,
                                                      3), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                '$_generatedText',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                    fontFamily: 'Jamsil'),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        )
                      ])),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.white,
                  height: 50,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _textValue = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Example을 참고해주세요',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_textValue != '') {
                            setState(() {
                              gptquery = _textValue +
                                  '을(를) 위해 사용 할 수 있는\n툴을 사용자들이 선호하는 순서로\n 보여드리겠습니다.';
                              String prompt =
                                  "사용자가 적은 질문: $_textValue\n변수, 클래스, 함수명을 각각3개 씩만 추천하고 답'삭제해줘 ";
                              generateText(prompt);
                              _generatedText = '';
                              showActivityIndicator = true;
                            });
                          }
                          FocusScope.of(context).unfocus(); // 키보드 내림
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            switchInCurve: Curves.easeIn,
                            switchOutCurve: Curves.easeOut,
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: _generatedText.isEmpty
                                ? showActivityIndicator
                                    ? CupertinoActivityIndicator()
                                    : Icon(
                                        CupertinoIcons.paperplane,
                                        color: Colors.black,
                                      )
                                : Icon(
                                    CupertinoIcons.paperplane,
                                    color: Colors.black,
                                  ),
                          ),
                        ),
                      ),
                    ],
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
