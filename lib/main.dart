import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:xml/xml.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ERdata {
  String erId; // 응급실 기관번호
  String erName; // 응급실 이름
  String erCall; // 응급실 직통전화
  String updateDate; // 최신화 날짜
  String availableER; // 가용 응급실 베드 수
  String availableOR; // 가용 수술실 수
  String availableRM; // 가용 입원실 수
  String availableMICU; // 가용 내과중환자실 베드 수
  String availableSICU; // 가용 외과중환자실 베드 수
  String availableNSCICU; // 가용 신경외과중환자실 베드 수
  String ctYN; // CT 촬영 가용 여부
  String agYN; // 조영촬영 가용 여부
  String mriYN; // MRI 촬영 가용 여부
  String ventYN; //인공호흡기 가용 여부

  ERdata(
      {this.erId = '0',
      this.erName = '0',
      this.erCall = '0',
      this.updateDate = '0',
      this.availableER = '0',
      this.availableOR = '0',
      this.availableRM = '0',
      this.availableMICU = '0',
      this.availableSICU = '0',
      this.availableNSCICU = '0',
      this.ctYN = '0',
      this.agYN = '0',
      this.mriYN = '0',
      this.ventYN = '0'});
}

List<ERdata> erList = [];

void main() async {
  await dotenv.load(fileName: '.env');
  GetERData();
  HttpOverrides.global = AvoidHttpCertErr();
  runApp(const MyApp());
}

class AvoidHttpCertErr extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void GetERData() async {
  late XmlDocument apiData;
  ERdata erData = ERdata();

  String apiKey = dotenv.get('API_KEY');
  String url =
      'https://apis.data.go.kr/B552657/ErmctInfoInqireService/getEmrrmRltmUsefulSckbdInfoInqire?serviceKey=$apiKey&STAGE1=서울특별시&STAGE2=&pageNo=1&numOfRows=10';
  var response = await get(Uri.parse(url));
  apiData = XmlDocument.parse(utf8.decode(response.bodyBytes));
  final datas = apiData.findAllElements('item');

  if (apiData
          .getElement('response')!
          .getElement('header')!
          .getElement('resultCode')!
          .text !=
      '00') {
    print('API Error');
  }
  datas.forEach((element) {
    erData = ERdata(
        erId: element.getElement('hpid')!.text,
        erName: element.getElement('dutyName')!.text,
        erCall: element.getElement('dutyTel3')!.text,
        updateDate: element.getElement('hvidate')!.text,
        availableER: element.getElement('hvec')!.text, // 응급실
        availableOR: element.getElement('hvoc')!.text, // 수술실
        availableRM: element.getElement('hvgc')!.text, // 입원실
        availableMICU: element.getElement('hv2')!.text, // 내과중환
        availableSICU: element.getElement('hv3')!.text, // 외과중환
        availableNSCICU: element.getElement('hv6')!.text, // 신경중환
        ctYN: element.getElement('hvctayn')!.text, // CT
        agYN: element.getElement('hvangioayn')!.text, // 조영촬영
        mriYN: element.getElement('hvmriayn')!.text, // MRI
        ventYN: element.getElement('hvamyn')!.text // 인공호흡기
        );
    erList.add(erData);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'rescueER',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late XmlDocument apiData;
  ERdata erData = ERdata();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('rescueER'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: 8,
        itemBuilder: (context, index) {
          return const ListTile(
            leading: Icon(Icons.local_hospital),
            title: Text('asdfasdfasdf'),
          );
        },
      ),
    );
  }
}

class ERTile extends StatelessWidget {
  ERTile(this._erData);
  final ERdata _erData;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.local_hospital),
      title: Text(_erData.erName),
      trailing: Text('응급실: ${_erData.availableER}'),
    );
  }
}

class BuildERTile extends StatelessWidget {
  const BuildERTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: erList.length,
      itemBuilder: (context, index) {
        return ERTile(erList[index]);
      },
    );
  }
}
