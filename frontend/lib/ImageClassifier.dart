import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
// import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class ImageClassifier extends StatefulWidget {
  const ImageClassifier({super.key});

  @override
  _ImageClassifierState createState() => _ImageClassifierState();
}

class _ImageClassifierState extends State<ImageClassifier> {
  late Interpreter _interpreter; // For inference TF Lite model

  File? _image; // For image picker
  final picker = ImagePicker(); // For image picker
  int _result = -1; // For classification result
  String _apiUrl = "https://example.com/api";
  Map<int, Map<String, String>> table = {
    0: {'name': '青春痘與酒糟性皮膚炎', 'desc': '包括青春痘（痤瘡）和酒糟性皮膚炎，這是一種慢性炎症性皮膚病。'},
    1: {'name': '異位性皮膚炎', 'desc': '一種慢性過敏性皮膚病，常伴隨皮膚乾燥和瘙癢。'},
    2: {'name': "基底細胞癌", 'desc': "最常見的皮膚癌，通常由過度暴露於紫外線引起。"},
    3: {"name": "水疱性疾病", "desc": "包含如天疱瘡和類天疱瘡等疾病，特徵是皮膚或黏膜形成水疱。"},
    4: {"name": "蜂窩性組織炎其他細菌感染", "desc": "由細菌引起的皮膚感染，可能導致疼痛和腫脹。"},
    5: {"name": "濕疹", "desc": "一種常見的炎症性皮膚病，伴隨紅腫、瘙癢及皮膚乾燥。"},
    6: {"name": "紅疹與藥疹", "desc": "由病毒感染或藥物引起的全身性皮膚紅疹。"},
    7: {"name": "脫髮、禿髮及其他頭髮疾病", "desc": "包括斑禿、男性型禿髮及其他與頭髮相關的病症。"},
    8: {"name": "疱疹、人乳頭瘤病毒 (HPV) 及其他性病", "desc": "包括由病毒引起的性病，例如疱疹和尖銳濕疣。"},
    9: {"name": "光線性疾病與色素沉著障礙", "desc": "與光線過敏或色素沉著異常相關的疾病。"},
    10: {"name": "狼瘡及其他結締組織疾病", "desc": "包含紅斑性狼瘡等自體免疫性疾病。"},
    11: {"name": "黑色素瘤、皮膚癌、痣與痣樣病變", "desc": "包括黑色素瘤和其他惡性皮膚腫瘤。"},
    12: {"name": "指甲真菌感染及其他指甲疾病", "desc": "如甲癬及其他指甲相關疾病。"},
    13: {"name": "毒藤照片及其他接觸性皮膚炎", "desc": "由毒藤或其他刺激物引起的過敏性接觸皮膚炎。"},
    14: {"name": "牛皮癬、扁平苔癬及相關疾病", "desc": "包括牛皮癬及其他伴隨皮膚增生的疾病。"},
    15: {"name": "疥瘡、萊姆病及其他寄生蟲感染與叮咬", "desc": "由寄生蟲或昆蟲叮咬引起的皮膚反應。"},
    16: {"name": "脂溢性角化症及其他良性腫瘤", "desc": "包含脂溢性角化症等無害的皮膚腫瘤。"},
    17: {"name": "系統性疾病", "desc": "與內部器官功能失調相關的皮膚病變。"},
    18: {"name": "癬 (環狀癬)、念珠菌感染及其他真菌感染", "desc": "由真菌引起的感染，如足癬或股癬。"},
    19: {"name": "蕁麻疹 (風疹塊)", "desc": "一種過敏性反應，特徵是皮膚快速腫脹和瘙癢。"},
    20: {"name": "血管性腫瘤", "desc": "如血管瘤，主要由血管增生引起。"},
    21: {"name": "血管炎", "desc": "由血管發炎引起的皮膚病變。"},
    22: {"name": "疣、傳染性軟疣及其他病毒感染", "desc": "包括由病毒引起的皮膚病，如尋常疣或軟疣。"},

  };
  List<Map<String, String>> _messages = []; // 儲存訊息 { "role": "user/assistant", "text": "內容" }
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // 聊天滾動控制器
  List<Map<String, String>> _conversationBuffer = [];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    // TODO
    // _interpreter = await Interpreter.fromAsset('assets/skin.tflite');
    try {
      _interpreter = await Interpreter.fromAsset('assets/skin24.tflite');

      // 獲取輸入張量的數量
      final inputTensorCount = _interpreter.getInputTensors().length;
      print('Number of input tensors: $inputTensorCount');
      for (var i = 0; i < inputTensorCount; i++) {
        print('Input tensor $i shape: ${_interpreter.getInputTensor(i).shape}');
        print('Input tensor $i type: ${_interpreter.getInputTensor(i).type}');
      }

      // 獲取輸出張量的數量
      final outputTensorCount = _interpreter.getOutputTensors().length;
      print('Number of output tensors: $outputTensorCount');
      for (var i = 0; i < outputTensorCount; i++) {
        print('Output tensor $i shape: ${_interpreter.getOutputTensor(i).shape}');
        print('Output tensor $i type: ${_interpreter.getOutputTensor(i).type}');
      }
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  /// 每次重新選擇圖片或拍照後，都清空 buffer
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // 清空舊有的對話紀錄
      _conversationBuffer.clear();
      setState(() {
        _image = File(pickedFile.path);
        _result = -1;
        _messages.clear(); // 也可同步清空 UI 的聊天紀錄
      });
      _classifyImage(_image!);
    }
  }

  Future<List<List<List<List<double>>>>> preprocessImage(File image, {int width = 244, int height = 244}) async {
    // 1. 讀取圖片並解碼
    img.Image imageInput = img.decodeImage(image.readAsBytesSync())!;

    // 2. 調整大小
    img.Image resizedImage = img.copyResize(
      imageInput,
      width: 244,
      height: 244,
      interpolation: img.Interpolation.nearest,
    );
    // 3. 轉換為 RGB 格式
    return [
      List.generate(
        height,
            (y) => List.generate(
          width,
              (x) {
            final pixel = resizedImage.getPixel(x, y);
            final r = pixel.r.toDouble();
            final g = pixel.g.toDouble();
            final b = pixel.b.toDouble();

            // 只在 y=100, x=50 的時候印一次
            if (y == 100 && x == 50) {
              print('Pixel at (y=100, x=50) => R: $r, G: $g, B: $b');
            }

            return [r, g, b];
          },
        ),
      ),
    ];
  }
  // 與 API 溝通，拿到更詳細的說明
  Future<String> fetchSymptomExplanation(String prompt,int init) async {
    // 將當前 _conversationBuffer 一起帶給 API
    // 舉例: 將對話歷史序列化成字串
    final bufferString = _conversationBuffer.map((msg) {
      // 例如：{'role': 'user', 'content': '你好我姓張'}
      // => "{'role': 'user', 'content': '你好我姓張'}"
      return "{'role': '${msg['role']}', 'content': '${msg['content']}'}";
    }).join(", ");
    var bodyData;
    // 這裡的 body JSON 格式可依你後端需求自行調整
    if (init==1){
      bodyData = {
        "message":
        "$prompt"
      };
    }
    else{
      bodyData = {
        "message":
        "$bufferString, 前面都是歷史紀錄，下面才是這次的 input: $prompt"
      };
    }


    try {
      final response = await http.post(
        Uri.parse(_apiUrl), // **改成使用動態的 _apiUrl**
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        final utf8DecodedContent = utf8.decode(response.bodyBytes);
        final data = jsonDecode(utf8DecodedContent);
        // 假設 data['explanation'] 裝的是我們要的文字
        return data['reply']?.trim() ?? '無法取得病症說明';
      } else {
        print('Error: ${response.body}');
        return 'API 回應失敗，無法取得資料';
      }
    } catch (e) {
      print('Error: $e');
      return '無法連接至 API';
    }
  }
  Future<void> _classifyImage(File image) async {

    var input = await preprocessImage(image);
    var output = List.filled(1 *23, 0).reshape([1,23]);
    _interpreter.run(input, output);
    print('Model Output: $output');
    // Get the result
    setState(() {
      // 使用 List.reduce 找到最大值和索引
      List<double> probabilities = output[0];
      double maxValue = probabilities.reduce((a, b) => a > b ? a : b);
      int maxIndex = probabilities.indexOf(maxValue);

      _result = maxIndex;  // 預測分類索引
      double confidence = maxValue; // 信心值

      print('Predicted class index: $maxIndex');
      print('Confidence: $confidence');
    });
    // 呼叫 LLM 模型獲取病症描述
    final classname=table[_result]!['name']!;
    final prompt = "針對病症 '$classname' 提供詳細的描述與建議。";
    print(prompt);
    String response = await _getLLMResponse(prompt,1);
    // 拿完之後，再把回覆寫入 buffer 以及更新 UI
    setState(() {
      _conversationBuffer.add({"role": "system", "content": response});
      _messages.add({"role": "assistant", "text": response});
      _scrollToBottom(); // 滾動到底部
    });
  }

  /// 同上，拍照時也清空
  Future<void> _loadCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _conversationBuffer.clear();
      setState(() {
        _image = File(pickedFile.path);
        _result = -1;
        _messages.clear();
      });
      _classifyImage(_image!);
    }
  }
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  void _sendMessage(String text) async {
    if (text.isEmpty) return;
    // 使用者發言：寫入 buffer
    // _conversationBuffer.add({"role": "user", "content": text});
    setState(() {
      _messages.add({"role": "user", "text": text});
    });

    _textController.clear();
    _scrollToBottom();

    // 接著從 API 取得回覆
    final response = await _getLLMResponse(text,0);

    // API 回覆後，也加到 buffer
    // _conversationBuffer.add({"role": "system", "content": response});
    setState(() {
      _messages.add({"role": "assistant", "text": response});
    });
    _scrollToBottom();
  }
  // 模擬從 LLM 獲取回應
  // 產生給 API 的 Prompt，並呼叫 fetchSymptomExplanation
  Future<String> _getLLMResponse(String prompt,int init) async {
    // final prompt = "針對病症 '$diseaseName' 提供詳細的描述與建議。";
    // 也可以選擇先把 prompt 加入 buffer（看你是否希望 user 的提問也一併記錄）
    final response = await fetchSymptomExplanation(prompt,init);
    _conversationBuffer.add({"role": "user", "content": prompt});
    _conversationBuffer.add({"role": "system", "content": response});

    return response;
  }
  // 新增一個方法讓使用者設定 API URL **新增**
  void _setApiUrl(BuildContext context) {
    final TextEditingController urlController = TextEditingController(text: _apiUrl);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('設定 API 網址'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(hintText: '輸入新的 API 網址'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 關閉對話框
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _apiUrl = urlController.text; // 更新 API 網址
                });
                Navigator.of(context).pop(); // 關閉對話框
              },
              child: const Text('確定'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Real-time Detection'),
          actions: [
            // 加入一個不明顯的小按鈕，用來設置 API URL **新增**
            IconButton(
              icon: const Icon(Icons.settings, size: 18), // 小圖示
              tooltip: '設定 API 網址',
              onPressed: () => _setApiUrl(context),
            ),
          ],
        ),
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 載入圖片
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4 - 8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4 - 8,
                        height:
                            MediaQuery.of(context).size.height * 0.5 - 48 - 16,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: _image == null
                                ? Text(
                                    'No image selected.',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 16,
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      _image!,
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width *
                                              0.4 -
                                          8 -
                                          16,
                                      height:
                                          MediaQuery.of(context).size.height *
                                                  0.5 -
                                              48 -
                                              16 -
                                              16,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: const Text('Pick Image'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _loadCamera,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: const Text('Load Camera'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 右側區域包含預測結果和聊天框
                Expanded(
                  child: Column(
                    children: [
                      // 病症名稱顯示區
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_result != -1) ...[
                              Text(
                                "預測結果：${table[_result]!['name']!}",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ] else
                              Text(
                                "尚未有預測結果。",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 聊天框區域
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              // 聊天訊息列表
                              Expanded(
                                child: ListView.builder(
                                  controller: _scrollController, // 綁定滾動控制器
                                  itemCount: _messages.length,
                                  itemBuilder: (context, index) {
                                    final message = _messages[index];
                                    bool isUser = message["role"] == "user";
                                    return Align(
                                      alignment: isUser
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isUser
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).colorScheme.surface,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          message["text"]!,
                                          style: TextStyle(
                                            color: isUser
                                                ? Theme.of(context).colorScheme.onPrimary
                                                : Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // 聊天輸入框
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _textController,
                                      decoration: InputDecoration(
                                        hintText: '輸入你的問題...',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: () => _sendMessage(_textController.text),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
    );
  }
}
