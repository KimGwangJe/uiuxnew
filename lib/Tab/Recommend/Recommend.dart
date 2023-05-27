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
  String _generatedText = ""; //gpt의 대답
  String _textValue = ""; //사용자 요구사항
  bool showActivityIndicator = false; //indicator 여부 초기값은 false

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
    //대답이 아직 오지 않았다면 indicator가 돌아 갈 수 있게 해준다
    if (_generatedText == '') {
      setState(() {
        showActivityIndicator = true; //indicator 여부를 true로 변경
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
          resizeToAvoidBottomInset: true, //키보드가 올라올때 화면이 같이 올라오게됨
          appBar: AppBar(
            centerTitle: true, //글자 중앙에 위치시킴
            title: Text(
              '추천',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color.fromRGBO(73, 73, 73, 1),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                // 스크롤 가능
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height -
                          50, //전체 디바이스 세로길이에서 bottomtab의 높이인 50을 뺌
                      child: (Column(children: [
                        Container(
                          width:
                              MediaQuery.of(context).size.width, //전체 디바이스 가로길이
                          child: gptquery == '' //아직 질문을 안했다면
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
                                            fontFamily: 'Jamsil'), //font를 가져옴
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
                                              fontFamily: 'Jamsil'), //font를 가져옴
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
                                                fontFamily:
                                                    'Jamsil'), //font를 가져옴
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
                                            fontFamily: 'Jamsil'), //font를 가져옴
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
                                              fontFamily: 'Jamsil'), //font를 가져옴
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
                                                fontFamily:
                                                    'Jamsil'), //font를 가져옴
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              : Container(
                                  //질문이 전송되었다면
                                  width: MediaQuery.of(context)
                                      .size
                                      .width, //디바이스 전체 가로 길이
                                  child: SingleChildScrollView(
                                    //스크롤 가능하게
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10.0), //둥글기 10으로 지정
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(
                                                      0.2), //그림자의 색상 및 투명도 0.2
                                                  spreadRadius: 5, //그림자의 확산 반경
                                                  blurRadius: 7, //그림자의 흐림 반경
                                                  offset:
                                                      Offset(0, 3), //그림자의 위치
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
                                                '$gptquery', // 질문 내용
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
                                                  BorderRadius.circular(
                                                      10.0), //둥글기
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(
                                                      0.2), //그림자의 색상 및 투명도 0.2
                                                  spreadRadius: 5, //그림자의 확산 반경
                                                  blurRadius: 7, //그림자의 흐림 반경
                                                  offset:
                                                      Offset(0, 3), //그림자의 위치
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
                                                '$_generatedText', //gpt의 대답
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                    fontFamily:
                                                        'Jamsil'), //font를 가져옴
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
                //textfield를 화면 제일 아래에 고정
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
                                _textValue = value; //입력되는 값을 변수에 저장
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
                        //아이콘이 터치가 가능하게 해줌
                        onTap: () {
                          if (_textValue != '') {
                            //textfield가 비어있지 않다면 실행시킴
                            setState(() {
                              gptquery = _textValue +
                                  '을(를) 위해 사용 할 수 있는\n변수, 클래스, 함수명을\n 각각 3개씩 보여드리겠습니다.'; //화면에 보여줄
                              String prompt =
                                  "사용자가 적은 질문: $_textValue\n변수, 클래스, 함수명을 각각3개 씩만 추천하고 답'삭제해줘 "; //gpt에게 전해지는 질문
                              generateText(prompt);
                              _generatedText = '';
                              showActivityIndicator =
                                  true; //indicator를 돌려서 아직 요청이 완료되지않음을 표시
                            });
                          }
                          FocusScope.of(context).unfocus(); // 키보드 내림
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: AnimatedSwitcher(
                            //애니메이션 전환을 수행
                            duration:
                                Duration(milliseconds: 300), //0.3초동안 애니메이션
                            switchInCurve: Curves.easeIn,
                            switchOutCurve: Curves.easeOut,
                            transitionBuilder: (child, animation) {
                              //전환 애니메이션에 사용되는 커스텀 트랜지션을 정의
                              return ScaleTransition(
                                //크기 변환
                                scale: animation,
                                child: child,
                              );
                            },
                            child: _generatedText.isEmpty //아직 답변이 없는가?
                                ? showActivityIndicator //true라면 indicator를 돌린다.
                                    ? CupertinoActivityIndicator()
                                    : Icon(
                                        //false라면 사용자가 질문을 할 수 있는 버튼으로 바꾼다.
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
