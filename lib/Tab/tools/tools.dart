import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'toolItems.dart';
import 'firstScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Tools extends StatefulWidget {
  const Tools({Key? key}) : super(key: key);

  @override
  State<Tools> createState() => _Tools();
}

class _Tools extends State<Tools> {
  List<toolItems> tool = List.empty(growable: true);
  String gptquery = ''; //버튼을 누를시 textfield값을 변경
  final FocusNode _focusNode = FocusNode();
  bool _isKeyboardVisible = false;
  final TextEditingController _textController = TextEditingController();
  String _generatedText = "";
  String _textValue = "";
  bool showActivityIndicator = false; //indicator
  List<String> generatedKeywords = [];
  List<String> imageNames = [
    'assets/images/chatgpt.png',
    'assets/images/ajax.png',
    'assets/images/android.png',
    'assets/images/angular.png',
    'assets/images/angularjs.png',
    'assets/images/as.png',
    'assets/images/bootstrap.png',
    'assets/images/c.png',
    'assets/images/cordova.png',
    'assets/images/css.png',
    'assets/images/diango.png',
    'assets/images/flask.png',
    'assets/images/flutter.png',
    'assets/images/html.png',
    'assets/images/ionic.png',
    'assets/images/java.png',
    'assets/images/javascript.png',
    'assets/images/jquery.png',
    'assets/images/kotlin.png',
    'assets/images/mysql.png',
    'assets/images/native.png',
    'assets/images/node.png',
    'assets/images/objectivec.png',
    'assets/images/php.png',
    'assets/images/react.png',
    'assets/images/reactnative.png',
    'assets/images/ruby.png',
    'assets/images/spring.png',
    'assets/images/sql.png',
    'assets/images/studio.png',
    'assets/images/svelte.png',
    'assets/images/swift.png',
    'assets/images/unity.png',
    'assets/images/visual.png',
    'assets/images/vue.png',
    'assets/images/wordpress.png',
    'assets/images/xcode.png',
    'assets/images/corona.png',
    'assets/images/sdk.png',
    'assets/images/koding.png',
    'assets/images/appmaker.png',
    'assets/images/ios.png',
    'assets/images/stroyboard.png',
    'assets/images/uikit.png',
    'assets/images/nodejs.png',
    'assets/images/apache.png',
    'assets/images/nginx.png',
    'assets/images/python.png',
    'assets/images/tensorflow.png',
    'assets/images/pytorch.png',
    'assets/images/caffe.png',
    'assets/images/CAFFE.png',
    'assets/images/mxnet.png',
    'assets/images/cntk.png',
    'assets/images/theano.png',
    'assets/images/dlib.png',
    'assets/images/go.png',
    'assets/images/js.png',
    'assets/images/ios.png',
    'assets/images/los.png',
    'assets/images/FIREBASE.png',
    'assets/images/scikitlearn.png',
    'assets/images/chainer.png',
  ];

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
        generatedKeywords = extractKeywords(_generatedText);
      });
    } else {
      setState(() {
        _generatedText = "Error: ${response.reasonPhrase}";
      });
    }
  }

  List<String> extractKeywords(String text) {
    List<String> keywords = [];

    List<String> extractedWords = text.split(' ');
    for (String word in extractedWords) {
      String cleanWord = word.replaceAll(RegExp(r'[\W\d]'), '');
      if (cleanWord.isNotEmpty && !cleanWord.contains(RegExp(r'^\d+$'))) {
        keywords.add(cleanWord);
      }
    }

    return keywords;
  }

  bool checkImageName(String imageName) {
    String higherImageName = imageName.toLowerCase();
    for (String keyword in generatedKeywords) {
      if (higherImageName.contains(keyword.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: MaterialApp(
          title: "개발 툴 추천",
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
                '개발 툴',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Color.fromRGBO(73, 73, 73, 1),
            ),
            body: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height +
                      100, // Stack 안에서 전체 화면을 차지하도록 설정
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height +
                              100, // 높이를 제한합니다.
                          child: gptquery == ''
                              ? FirstScreen() // 질문이 아직 없다면 처음 화면만을 보여줍니다.
                              : Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            '$gptquery',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontFamily: 'Jamsil'),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12.0),
                                          child: Column(
                                            children: [
                                              for (String keyword
                                                  in generatedKeywords)
                                                if (checkImageName(keyword))
                                                  Column(
                                                    children: [
                                                      Image.asset(
                                                        'assets/images/$keyword.png',
                                                        width: 200,
                                                        height: 100,
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ), // 이미지들 사이의 간격을 설정합니다.
                                                    ],
                                                  ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: _isKeyboardVisible ? 0 : 0, //이거 만져봐라
                  child: Container(
                    color: Colors.white,
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: TextField(
                              focusNode: _focusNode,
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
                            _textValue == ''
                                ? print('asd')
                                : setState(() {
                                    gptquery = _textValue +
                                        '을 위해 사용 할 수 있는\n툴을 사용자들이 선호하는 순서로\n 보여드리겠습니다.';

                                    String prompt =
                                        "사용자가 적은 질문: ${_textValue}\n을(를) 만들기 위해 사용할 수 있는 툴을 사용자들이 선호하는 키워드만 (대문자로) 해 주고 6개 만 적어줘";
                                    generateText(prompt);
                                    showActivityIndicator = true;
                                  });
                            FocusScope.of(context).unfocus();
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
                              child: generatedKeywords.isEmpty
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
        ));
  }
}
