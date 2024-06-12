import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ShowHistoryMesPage extends StatefulWidget {
  @override
  _ShowHistoryMesPageState createState() => _ShowHistoryMesPageState();
}

class _ShowHistoryMesPageState extends State<ShowHistoryMesPage> {
  List<String> _lines = [];

  @override
  void initState() {
    super.initState();
    _loadLines();
  }

  Future<void> _loadLines() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/message_scans.txt');
    final lines = await file.readAsLines();
    setState(() {
      _lines = lines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message History'),
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