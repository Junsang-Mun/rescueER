import 'dart:convert';
//import 'dart:html';
import 'package:flutter/material.dart';
//import 'package:english_words/english_words.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      home: HomePage(),
    );
  }
}

class ERdata {
  String erName; // 응급실 이름
  String updateDate; // 최신화 날짜
  String availableER; // 가용 응급실 베드 수
  String availableOR; // 가용 수술실 수
  String availableRM; // 가용 입원실 수
  String availableMICU; // 가용 내과중환자실 베드 수
  String availableSICU; // 가용 외과중환자실 베드 수
  String availableNSCICU; // 가용 신경외과중환자실 베드 수
  bool ctYN; // CT 촬영 가용 여부
  bool agYN; // 조영촬영 가용 여부
  bool mriYN; // MRI 촬영 가용 여부
  bool ventYN; //인공호흡기 가용 여부

  ERdata(
      {this.erName = '0',
      this.updateDate = '0',
      this.availableER = '0',
      this.availableOR = '0',
      this.availableRM = '0',
      this.availableMICU = '0',
      this.availableSICU = '0',
      this.availableNSCICU = '0',
      this.ctYN = false,
      this.agYN = false,
      this.mriYN = false,
      this.ventYN = false});
}

class HomePage extends StatefulWidget {
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
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.cloud_sync),
              onPressed: () async {
                const url =
                    'https://apis.data.go.kr/B552657/ErmctInfoInqireService/getEmrrmRltmUsefulSckbdInfoInqire?serviceKey=&STAGE1=%EC%84%9C%EC%9A%B8%ED%8A%B9%EB%B3%84%EC%8B%9C&STAGE2=%EA%B0%95%EB%82%A8%EA%B5%AC&pageNo=1&numOfRows=10';
                var response = await http.get(Uri.parse(url));
                apiData = XmlDocument.parse(utf8.decode(response.bodyBytes));
                final datas = apiData.findAllElements('item');
                print(datas);
                datas.forEach((element) {
                  erData = ERdata(
                    erName: element.getElement('dutyname')!.text,
                    updateDate: element.getElement('hvidate')!.text,
                    availableER: element.getElement('hvec')!.text,
                    availableOR: element.getElement('hvoc')!.text,
                    availableRM: element.getElement('hvgc')!.text,
                    availableMICU: element.getElement('hv2')!.text,
                    availableSICU: element.getElement('hv3')!.text,
                    availableNSCICU: element.getElement('hv6')!.text,
                  );
                  print(erData.erName);
                });
              })
        ],
      ),
    );
  }
}

/*
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Startup Name Generator',
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  RandomWordsState createState() => RandomWordsState();
}

class RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18.0);
  @override
  Widget build(BuildContext context) {
    void _pushSaved() {
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _saved.map(
            (pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ));
    }

    //final wordPair = WordPair.random();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _pushSaved,
            tooltip: 'Saved Suggestions',
          )
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return const Divider(); /*2*/

          final index = i ~/ 2; /*3*/
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10)); /*4*/
          }

          final alreadySaved = _saved.contains(_suggestions[index]);
          return _buildRow(_suggestions[index], alreadySaved, index);
        });
  }

  Widget _buildRow(WordPair pair, bool alreadySaved, int index) {
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
        semanticLabel: alreadySaved ? 'Removed from Saved' : 'Saved',
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(_suggestions[index]);
          } else {
            _saved.add(_suggestions[index]);
          }
        });
      },
    );
  }
}
*/