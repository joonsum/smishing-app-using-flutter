import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ShowHistoryPage extends StatefulWidget {
  @override
  _ShowHistoryPageState createState() => _ShowHistoryPageState();
}

class _ShowHistoryPageState extends State<ShowHistoryPage> {
  List<String> _lines = [];

  @override
  void initState() {
    super.initState();
    _loadLines();
  }

  Future<void> _loadLines() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/link_scans.txt');
    final lines = await file.readAsLines();
    setState(() {
      _lines = lines;
    });
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('data/Background.jpg'),
            fit: BoxFit.cover,
            colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
          ),
        ),
        child: ListView.builder(
          itemCount: _lines.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_lines[index]),
            );
          },
        ),
      ),
    );
  }
}