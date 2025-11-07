import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
// import 'package:permission_handler/permission_handler.dart';

class DiseaseInformation extends StatefulWidget {
  const DiseaseInformation({super.key});

  @override
  _DiseaseInformationState createState() => _DiseaseInformationState();
}

class _DiseaseInformationState extends State<DiseaseInformation> {
  int selectedIndex = -1;

  List<Map<String, String>> diseaseList = [
    {
      "title": "青春痘與酒糟性皮膚炎",
      "img": "https://i.imgur.com/xpDfWUn.jpeg",
      "desc": "包括青春痘（痤瘡）和酒糟性皮膚炎，這是一種慢性炎症性皮膚病，可能由多種因素如油脂分泌過多、細菌感染和激素變化引起，常見於青少年和成年人。酒糟性皮膚炎可能伴隨臉部潮紅及小血管擴張。"
    },
    {
      "title": "異位性皮膚炎",
      "img": "https://i.imgur.com/w7wXrJQ.jpeg",
      "desc": "一種慢性過敏性皮膚病，常伴隨皮膚乾燥和瘙癢，通常由環境過敏原或基因因素引起，患者可能會出現紅腫和脫屑，甚至因過度搔抓導致皮膚增厚。"
    },
    {
      "title": "基底細胞癌",
      "img": "https://i.imgur.com/hQnX65A.jpeg",
      "desc": "最常見的皮膚癌，通常由過度暴露於紫外線引起，表現為緩慢生長的皮膚病變，常見於面部、耳朵或手背等暴露部位，若未治療可能侵入鄰近組織。"
    },
    {
      "title": "水疱性疾病",
      "img": "https://i.imgur.com/FNTMixD.jpeg",
      "desc": "包含如天疱瘡和類天疱瘡等疾病，特徵是皮膚或黏膜形成水疱，這些水疱可能是自體免疫疾病的表現，嚴重時可能導致感染或脫水危險。"
    },
    {
      "title": "蜂窩性組織炎與其他細菌感染",
      "img": "https://i.imgur.com/zhxkZjH.jpeg",
      "desc": "由細菌引起的皮膚感染，可能導致局部疼痛、紅腫及發熱，嚴重時可擴散至淋巴結或引發全身感染，需及時以抗生素治療。"
    },
    {
      "title": "濕疹",
      "img": "https://i.imgur.com/PcrvOs5.jpeg",
      "desc": "一種常見的炎症性皮膚病，伴隨紅腫、瘙癢及皮膚乾燥，可能由過敏原、氣候變化或壓力引發，經常反覆發作，治療需保濕及抗炎藥物並重。"
    },
    {
      "title": "紅疹與藥疹",
      "img": "https://i.imgur.com/h2iraEC.jpeg",
      "desc": "由病毒感染或藥物過敏引起的全身性皮膚紅疹，可能伴隨發燒、搔癢及皮膚脫屑，嚴重時會導致史帝文斯-強森症候群等危險併發症。"
    },
    {
      "title": "脫髮、禿髮及其他頭髮疾病",
      "img": "https://i.imgur.com/UESm9NG.jpeg",
      "desc": "包括斑禿、男性型禿髮及其他與頭髮相關的病症，可能由基因、壓力或自體免疫反應引起，對患者的心理健康造成影響。"
    },
    {
      "title": "疱疹、人乳頭瘤病毒 (HPV) 及其他性病",
      "img": "https://i.imgur.com/vmTOsYT.jpeg",
      "desc": "包括由病毒引起的性病，例如疱疹（HSV）和尖銳濕疣（HPV），這些疾病可能通過皮膚接觸或性行為傳播，需透過抗病毒或手術治療。"
    },
    {
      "title": "光線性疾病與色素沉著障礙",
      "img": "https://i.imgur.com/4IoYd67.jpeg",
      "desc": "與光線過敏或色素沉著異常相關的疾病，如白斑、雀斑或曬斑，紫外線是主要的誘因，防曬是預防的關鍵。"
    },
    {
      "title": "狼瘡及其他結締組織疾病",
      "img": "https://i.imgur.com/HUG2102.jpeg",
      "desc": "包含紅斑性狼瘡等自體免疫性疾病，患者可能出現皮膚紅斑、光敏感及多系統症狀，需結合免疫抑制劑治療。"
    },
    {
      "title": "黑色素瘤、皮膚癌、痣與痣樣病變",
      "img": "https://i.imgur.com/QNYIeCN.jpeg",
      "desc": "包括黑色素瘤和其他惡性皮膚腫瘤，通常起源於痣的變化，早期發現和切除是提高存活率的關鍵。"
    },
    {
      "title": "指甲真菌感染及其他指甲疾病",
      "img": "https://i.imgur.com/xgXuIRL.jpeg",
      "desc": "如甲癬及其他指甲相關疾病，可能導致指甲增厚、變色或脆弱，治療需長期抗真菌藥物。"
    },
    {
      "title": "毒藤照片及其他接觸性皮膚炎",
      "img": "https://i.imgur.com/SmYCtAL.jpeg",
      "desc": "由毒藤或其他刺激物引起的過敏性接觸皮膚炎，表現為局部紅腫、水疱及瘙癢，需避免接觸並使用抗炎藥物治療。"
    },
    {
      "title": "牛皮癬、扁平苔癬及相關疾病",
      "img": "https://i.imgur.com/vHqc64X.jpeg",
      "desc": "包括牛皮癬及其他伴隨皮膚增生的疾病，特徵是皮膚增厚、脫屑及瘙癢，嚴重時可能影響關節。"
    },
    {
      "title": "疥瘡、萊姆病及其他寄生蟲感染與叮咬",
      "img": "https://i.imgur.com/cDGjYXb.jpeg",
      "desc": "由寄生蟲或昆蟲叮咬引起的皮膚反應，可能伴隨劇烈搔癢及二次感染，治療需結合殺蟲藥及消炎藥。"
    },
    {
      "title": "脂溢性角化症及其他良性腫瘤",
      "img": "https://i.imgur.com/P6fxjhD.jpeg",
      "desc": "包含脂溢性角化症等無害的皮膚腫瘤，表現為皮膚表面的褐色斑塊或結節，通常無需治療但可手術切除以改善外觀。"
    },
    {
      "title": "系統性疾病",
      "img": "https://i.imgur.com/h0gTD8q.jpeg",
      "desc": "與內部器官功能失調相關的皮膚病變，如肝病引起的黃疸或糖尿病引起的皮膚感染，需針對基礎疾病治療。"
    },
    {
      "title": "癬 (環狀癬)、念珠菌感染及其他真菌感染",
      "img": "https://i.imgur.com/ITdJilg.jpeg",
      "desc": "由真菌引起的感染，如足癬或股癬，表現為皮膚環狀紅疹，治療需抗真菌藥物。"
    },
    {
      "title": "蕁麻疹 (風疹塊)",
      "img": "https://i.imgur.com/n0i28cl.jpeg",
      "desc": "一種過敏性反應，特徵是皮膚快速腫脹和瘙癢，可能由食物、藥物或環境因素引起，通常短時間內緩解。"
    },
    {
      "title": "血管性腫瘤",
      "img": "https://i.imgur.com/OyMEmxH.jpeg",
      "desc": "如血管瘤，主要由血管增生引起，常見於嬰幼兒，多數屬良性且可自然消退，少數需手術治療。"
    },
    {
      "title": "血管炎",
      "img": "https://i.imgur.com/j0FB5Ih.jpeg",
      "desc": "由血管發炎引起的皮膚病變，可能伴隨全身症狀如發燒及疲憊，需及時診治以避免器官受損。"
    },
    {
      "title": "疣、傳染性軟疣及其他病毒感染",
      "img": "https://i.imgur.com/i8TSAN0.jpeg",
      "desc": "包括由病毒引起的皮膚病，如尋常疣或軟疣，主要通過接觸傳播，治療方式包括冷凍治療或抗病毒藥物。"
    }
  ];


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TODO
        title: const Text('Disease Information'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1),
          child: Container(
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2 - 8,
                    child: ListView.builder(
                      itemCount: diseaseList.length,
                      itemBuilder: (context, index) {
                        return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            decoration: BoxDecoration(
                              color: selectedIndex == index
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2)
                                  : Theme.of(context).colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: selectedIndex == index
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                diseaseList[index]["title"]!,
                                style: TextStyle(
                                  color: selectedIndex == index
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                              },
                              selected: selectedIndex == index,
                            ));
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  selectedIndex == -1
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6 - 8,
                          child: Center(
                            child: Text(
                              'Select a disease to view information.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6 - 8,
                          child: Column(
                            children: [
                              Image.network(
                                diseaseList[selectedIndex]["img"]!,
                                width: MediaQuery.of(context).size.width * 0.6 - 8,
                                height: MediaQuery.of(context).size.height * 0.3,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                diseaseList[selectedIndex]["title"]!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                diseaseList[selectedIndex]["desc"]!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              )),
        ),
      ),
    );
  }
}
