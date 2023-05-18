import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
// import './RecommendMain.dart';
import 'package:http/http.dart' as http; //HTTP요청을 위한 라이브러리
import 'package:image_picker/image_picker.dart'; //이미지 선택기능을위한  라이브러리
import 'dart:io'; //입출력작업을 수행하기위한 라이브러리
import 'dart:convert'; // JSON 디코딩을 하기위한 라이브러리

class CameraMain extends StatefulWidget {
  @override
  _CameraMain createState() => _CameraMain();
}

class _CameraMain extends State<CameraMain> {
  double _bottomSheetHeight = 550;
  final picker = ImagePicker();
  bool _isSecondContainerOpen = true;
  String title = '추천';
  String _extractedText = ''; //이미지에서 추출된 텍스트
  String _aftergptText = ''; //gpt를 거치고난 텍스트

  Future<File?> _pickImage() async {
    //갤러리에서  이미지를 선택하는 함수
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      //이미지가 선택되면
      return File(pickedFile.path); //이미지파일 반환
    } else {
      //취소될경우 null반환
      return null;
    }
  }

  Future<String> _extractCodeFromImage(String imagePath) async {
    // 1. Google Cloud Vision API에 보낼 이미지를 base64로 인코딩
    final bytes =
        await File(imagePath).readAsBytes(); //File 클래스로 이미지파일을 읽고 바이트배열로 읽음
    final imageBytes = base64.encode(bytes);

    // 2. Vision API 호출을 위한 HTTP 요청 작성
    final apiKey = 'AIzaSyAFWLdA1Ixonrd0Avy1mmtxdyo2fWE7os0';
    final response = await http.post(
      Uri.parse(// url에 저장된 주소로 요청을 보냄
          'https://vision.googleapis.com/v1/images:annotate?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requests': [
          //json으로 인코딩
          {
            'image': {'content': imageBytes},
            'features': [
              {'type': 'TEXT_DETECTION'}
            ],
          }
        ]
      }),
    );
    final Map<String, dynamic> responseData =
        jsonDecode(utf8.decode(response.bodyBytes)); //위에서 인코딩된 데이터를 디코딩
    if (responseData.containsKey('error')) {
      //받은 데이터에서 에러발생시
      final String errorMessage =
          responseData['error']['message'] ?? '에러가 발생하였습니다'; //에러메세지 출력
      return errorMessage;
    }
    // Vision API에서 추출한 텍스트 반환
    final textAnnotations =
        responseData['responses'][0]['textAnnotations']; //텍스트블록에서 추출된 텍스트를 가져옴
    final extractedText = textAnnotations[0]['description']
        as String; //추출된 텍스트를 extractedText변수에 할당
    return extractedText; //추출된텍스트 반환
  }

  Future<String> _aftergptCode(String code, String prompt) async {
    //GPT API로 추출된코드에 주석,오류수정을 하는함수
    final String model = 'text-davinci-003'; //사용할 gpt api의 모델명
    final String apiKey =
        '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'; //gpt api를 사용하기위한 apikey

    final http.Response response = await http.post(
      //url에 저장된 주소로 요청을 보냄
      Uri.parse('https://api.openai.com/v1/engines/$model/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'prompt': '"$prompt $code"', //미리설정한 prompt값(주석요청,코드수정요청)과 추출된 코드를 넣음
        'temperature': 0.7,
        'max_tokens': 2000, //최대 토큰수
      }),
    );

    final Map<String, dynamic> responseData =
        jsonDecode(utf8.decode(response.bodyBytes)); //위의 json데이터를 디코딩

    if (responseData.containsKey('error')) {
      //responseData에 error키 포함시
      final String errorMessage =
          responseData['error']['message'] ?? '에러가 발생하였습니다'; //에러텍스트 출력
      return errorMessage;
    }

    final String generatedText = responseData['choices'][0]
        ['text']; //gpt api의 응답데이터에서 생성된 텍스트를 generatedText에 할당
    return '$generatedText\n\n\n'; //gpt를 거쳐 생성된 텍스트반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '$title',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(73, 73, 73, 1),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width / 1.2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '$_extractedText',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontFamily: 'Gmarket'),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width / 1.2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '$_aftergptText',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontFamily: 'Gmarket'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            bottom: 0,
            left: 0,
            right: 0,
            height: _bottomSheetHeight,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.8),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              constraints: BoxConstraints(
                minHeight: 40,
                maxHeight: 550,
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_isSecondContainerOpen) {
                          _isSecondContainerOpen = false;
                          _bottomSheetHeight = 40;
                        } else {
                          _isSecondContainerOpen = true;
                          _bottomSheetHeight = 550;
                        }
                      });
                    },
                    child: _isSecondContainerOpen == false
                        ? Icon(
                            Icons.keyboard_arrow_up_rounded,
                            size: 35,
                          )
                        : Icon(
                            Icons.slideshow,
                            size: 50,
                          ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Container(
                                          height: 200,
                                          width: 300,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color: Colors.black,
                                                      width: 3.0,
                                                    ),
                                                  ),
                                                ),
                                                height: 120,
                                                child: Center(
                                                  child: Text(
                                                    '원하는 작업을 선택해주세요.',
                                                    style: TextStyle(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: 'Gmarket'),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 80,
                                                child: Row(children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      setState(() async {
                                                        _isSecondContainerOpen =
                                                            false;
                                                        _bottomSheetHeight =
                                                            100;
                                                        title = '오류 수정';
                                                        _extractedText =
                                                            '오류 수정 ';
                                                        _aftergptText = '답';
                                                        final File? imageFile =
                                                            await _pickImage(); //pickImage함수를 통해 선택한 이미지를 저장

                                                        if (imageFile != null) {
                                                          //이미지가 선택됐을시
                                                          final String
                                                              imagePath =
                                                              imageFile
                                                                  .path; // 이미지파일의 경로를 imagePath에 저장

                                                          //  이미지에서 코드 추출
                                                          final String code =
                                                              await _extractCodeFromImage(
                                                                  imagePath);
                                                          final String prompt =
                                                              'Please fix this code so it works correctly and tell me in korean where and why these errors are occured from first to last and write fixed code:';
                                                          //  GPT API 호출
                                                          final String
                                                              aftergptCode =
                                                              await _aftergptCode(
                                                                  code, prompt);

                                                          //  원문코드와 오류가수정된 코드를 각각 '오류수정'과 '답'칸에 출력
                                                          setState(() {
                                                            _aftergptText =
                                                                aftergptCode;
                                                            _extractedText =
                                                                code;
                                                          });
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      height: 80,
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          right: BorderSide(
                                                            color: Colors.black,
                                                            width: 3.0,
                                                          ),
                                                        ),
                                                      ),
                                                      width: 150,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(
                                                            CupertinoIcons
                                                                .brightness_solid,
                                                            size: 24,
                                                          ),
                                                          Text(
                                                            '오류 수정',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontFamily:
                                                                    'Gmarket'),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      setState(() async {
                                                        _isSecondContainerOpen =
                                                            false;
                                                        _bottomSheetHeight = 40;
                                                        title = '주석 처리';
                                                        _extractedText = '주석';
                                                        _aftergptText = '답';

                                                        final File? imageFile =
                                                            await _pickImage();

                                                        if (imageFile != null) {
                                                          final String
                                                              imagePath =
                                                              imageFile.path;
                                                          final String prompt =
                                                              '코드의 처음부터 한글로 주석을달아줘:';
                                                          //  이미지에서 코드 추출
                                                          final String code =
                                                              await _extractCodeFromImage(
                                                                  imagePath);

                                                          // GPT API 호출
                                                          final String
                                                              aftergptCode =
                                                              await _aftergptCode(
                                                                  code, prompt);

                                                          //  주석 추가
                                                          setState(() {
                                                            _aftergptText =
                                                                aftergptCode;
                                                            _extractedText =
                                                                code;
                                                          });
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 150,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(
                                                            CupertinoIcons
                                                                .bubble_left_bubble_right_fill,
                                                            size: 24,
                                                          ),
                                                          Text(
                                                            '주석 처리',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontFamily:
                                                                    'Gmarket'),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Text('사진 가져오기'),
                              ),
                            ],
                          ),
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
    );
  }
}
