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
  double _bottomSheetHeight = 550; //사진 선택 탭의 초기 높이
  final picker = ImagePicker();
  bool _isSecondContainerOpen = true; //사진 선택하기 탭
  String title = ''; //appbar 이름
  String _extractedText = ''; //이미지에서 추출된 텍스트
  String _aftergptText = ''; //gpt를 거치고난 텍스트
  bool _isLoading = false; // gpt의 답 로딩

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
          '$title', //title은 초기값 ''에서 원하는 메뉴 선택시 바뀜
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(73, 73, 73, 1),
      ),
      body: Stack(
        //container에 container를 쌓기위해 사용
        children: [
          Positioned.fill(
            //부모 위젯의 영역을 채우는 형태로 자식 위젯을 배치
            child: Container(
              height: MediaQuery.of(context).size.height, //최대 height
              width: MediaQuery.of(context).size.width, //최대 width
              child: SingleChildScrollView(
                //스크롤 가능하게
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0), //둥글기 지정
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey
                                  .withOpacity(0.2), //그림자의 색상 및 투명도 0.2
                              spreadRadius: 5, //그림자의 확산 반경
                              blurRadius: 7, //그림자의 흐림 반경
                              offset: Offset(0, 3), //그림자의 위치
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
                                fontFamily: 'Gmarket'), //폰트지정
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
                              color: Colors.grey
                                  .withOpacity(0.2), //그림자의 색상 및 투명도 0.2
                              spreadRadius: 5, //그림자의 확산 반경
                              blurRadius: 7, //그림자의 흐림 반경
                              offset: Offset(0, 3), //그림자의 위치
                            ),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width / 1.2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _isLoading //아직 로딩중인가?
                              ? CupertinoActivityIndicator() // showActivityIndicator를 표시하는 위젯을 여기에 추가
                              : Text(
                                  _aftergptText,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontFamily: 'Gmarket',
                                  ),
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
            // 올라오는 화면의 애니메이션 지정
            duration: Duration(milliseconds: 500), //애니메이션의 지속 시간
            curve: Curves.easeInOut, //애니메이션의 커브
            bottom: 0,
            left: 0,
            right: 0,
            height: _bottomSheetHeight,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0), //좌측상단 둥글기
                  topRight: Radius.circular(30.0), //우측상단 둥글기
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.8), //그림자의 색상 및 투명도 0.8
                    spreadRadius: 2, //그림자의 확산 반경
                    blurRadius: 10, //그림자의 흐림 반경
                    offset: Offset(0, 3), //그림자의 위치
                  ),
                ],
              ),
              constraints: BoxConstraints(
                //위젯의 크기 제약
                minHeight: 40, //최소 40
                maxHeight: 550, //최대 550
              ),
              child: Column(
                children: [
                  GestureDetector(
                    //터치 가능하게 해줌
                    onTap: () {
                      setState(() {
                        if (_isSecondContainerOpen) {
                          _isSecondContainerOpen = false; // 닫기
                          _bottomSheetHeight = 40; // 최소 40
                        } else {
                          _isSecondContainerOpen = true; //열기
                          _bottomSheetHeight = 550; // 최소 550
                        }
                      });
                    },
                    child: _isSecondContainerOpen ==
                            false //conatiner가 올라왔는지를 확인 후 아이콘을 바꿔줌
                        ? Icon(
                            Icons.keyboard_arrow_up_rounded,
                            size: 35, //닫혔을때는 올라가는 버튼모양
                          )
                        : Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 35, // 열렸을때는 닫는 모양
                          ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 500), //애니메이션의 지속 시간
                        curve: Curves.easeInOut, //애니메이션의 커브를 설정
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 25.0, bottom: 20),
                                child: Text(
                                  'Warning',
                                  style: TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold, //글씨 두께
                                      fontFamily: 'Jamsil'), //폰트지정
                                ),
                              ),
                              Container(
                                height: 55,
                                width: 350,
                                color: Color.fromRGBO(246, 246, 246, 1),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    '코드에 줄번호가 같이 인식 될 시 \n텍스트가 정상적으로 추출 되지 않을 수 있습니다.',
                                    textAlign: TextAlign.center, //중앙정렬
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontFamily: 'Jamsil'), //폰트 설정
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Container(
                                  height: 55,
                                  width: 350,
                                  color: Color.fromRGBO(246, 246, 246, 1),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      '주석이 이미 달려있는 코드를 인식 할 시 \n텍스트가 정상적으로 추출 되지 않을 수 있습니다.',
                                      textAlign: TextAlign.center, //중앙 정렬
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontFamily: 'Jamsil'), //폰트 설정
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 50.0),
                                child: SizedBox(
                                  height: 62,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      //버튼 스타일
                                      primary:
                                          Color.fromRGBO(73, 73, 73, 1), //색상
                                      shape: RoundedRectangleBorder(
                                        //동그란 버튼으로 만들어줌
                                        borderRadius:
                                            BorderRadius.circular(80.0),
                                      ),
                                    ),
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                              //다잉얼로그의 모양
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            child: Container(
                                              height: 200,
                                              width: 300,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0), //둥글기 지정
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
                                                            fontFamily:
                                                                'Gmarket'), //폰트 설정
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 80,
                                                    child: Row(children: [
                                                      GestureDetector(
                                                        onTap: () async {
                                                          Navigator.pop(
                                                              context); //닫기
                                                          setState(() {
                                                            _isSecondContainerOpen =
                                                                false;
                                                            _bottomSheetHeight =
                                                                40;
                                                            _isLoading = true;
                                                          });
                                                          setState(() async {
                                                            title = '오류 수정';
                                                            _extractedText =
                                                                '오류 수정 ';
                                                            final File?
                                                                imageFile =
                                                                await _pickImage(); //pickImage함수를 통해 선택한 이미지를 저장

                                                            if (imageFile !=
                                                                null) {
                                                              //이미지가 선택됐을시
                                                              final String
                                                                  imagePath =
                                                                  imageFile
                                                                      .path; // 이미지파일의 경로를 imagePath에 저장

                                                              //  이미지에서 코드 추출
                                                              final String
                                                                  code =
                                                                  await _extractCodeFromImage(
                                                                      imagePath);
                                                              final String
                                                                  prompt =
                                                                  'Please fix this code so it works correctly and tell me in korean where and why these errors are occured from first to last and write fixed code:';
                                                              //  GPT API 호출
                                                              final String
                                                                  aftergptCode =
                                                                  await _aftergptCode(
                                                                      code,
                                                                      prompt);

                                                              //  원문코드와 오류가수정된 코드를 각각 '오류수정'과 '답'칸에 출력
                                                              setState(() {
                                                                _aftergptText =
                                                                    aftergptCode;
                                                                _extractedText =
                                                                    code;
                                                                _isLoading =
                                                                    false;
                                                              });
                                                            }
                                                          });
                                                        },
                                                        child: Container(
                                                          height: 80,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border(
                                                              right: BorderSide(
                                                                color: Colors
                                                                    .black,
                                                                width: 3.0,
                                                              ),
                                                            ),
                                                          ),
                                                          width: 150,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center, //중앙정렬
                                                            children: [
                                                              const Icon(
                                                                CupertinoIcons
                                                                    .brightness_solid,
                                                                size: 24,
                                                              ),
                                                              Text(
                                                                '오류 수정',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontFamily:
                                                                        'Gmarket'),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () async {
                                                          Navigator.pop(
                                                              context); //닫기
                                                          setState(() {
                                                            _isSecondContainerOpen =
                                                                false;
                                                            _bottomSheetHeight =
                                                                40;
                                                            _isLoading = true;
                                                          });
                                                          setState(() async {
                                                            _isSecondContainerOpen =
                                                                false;
                                                            _bottomSheetHeight =
                                                                40;
                                                            title = '주석 처리';
                                                            _extractedText =
                                                                '주석';

                                                            final File?
                                                                imageFile =
                                                                await _pickImage();

                                                            if (imageFile !=
                                                                null) {
                                                              final String
                                                                  imagePath =
                                                                  imageFile
                                                                      .path;
                                                              final String
                                                                  prompt =
                                                                  '코드의 처음부터 한글로 주석을달아줘:';
                                                              //  이미지에서 코드 추출
                                                              final String
                                                                  code =
                                                                  await _extractCodeFromImage(
                                                                      imagePath);

                                                              // GPT API 호출
                                                              final String
                                                                  aftergptCode =
                                                                  await _aftergptCode(
                                                                      code,
                                                                      prompt);
                                                              //  주석 추가
                                                              setState(() {
                                                                _aftergptText =
                                                                    aftergptCode;
                                                                _extractedText =
                                                                    code;
                                                                _isLoading =
                                                                    false;
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
                                                                    fontSize:
                                                                        20,
                                                                    fontFamily:
                                                                        'Gmarket'), //폰트지정
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
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
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
