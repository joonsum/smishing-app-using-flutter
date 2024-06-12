import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'showhistory.dart';

class LinkInput extends StatefulWidget {
  @override
  _LinkInputState createState() => _LinkInputState();
}

class _LinkInputState extends State<LinkInput> {
  final myController = TextEditingController();
  Future<String> result = Future.value('No link classified yet');

  Future<String> classifyLink(String link) async {
    var response = await http.post(
      Uri.parse('http://10.0.2.2:8000/predict'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'link': link,
      }),
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data is Map && data.containsKey('prediction')) {
        String prediction = data['prediction'];

        var now = DateTime.now();
        var formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
        String formattedDate = formatter.format(now);

        final directory = await getApplicationDocumentsDirectory();

        final txtFile = File('${directory.path}/link_scans.txt');
        String fileContent = 'Date: $formattedDate, Link: $link, Result: $prediction\n';
        if (await txtFile.exists()) {
          await txtFile.writeAsString(fileContent, mode: FileMode.append);
        } else {
          await txtFile.writeAsString(fileContent);
        }

        return prediction;
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to classify link');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('data/AppIcon.jpg', height: 20, width: 20),
        ),
        title: Text('Link Classification', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('data/Background.jpg'),
          fit: BoxFit.cover,
          colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
        ),
      ),
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            TextField(
              controller: myController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Link',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]')),
              ],
              onChanged: (value) {
                if (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]').hasMatch(value)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid input. Please do not enter symbols.'),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blueGrey,
              ),
              onPressed: () async {
                try {
                  setState(() {
                    result = classifyLink(myController.text);
                    myController.clear();
                  });
                } catch (e) {
                  print('Error: $e');
                }
              },
              child: Text('Classify'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blueGrey,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShowHistoryPage()),
                );
              },
              child: Text('View History'),
            ),
            SizedBox(height: 10),
            FutureBuilder<String>(
              future: result,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  if (snapshot.data == 'bad') {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Alert'),
                            content: Text('The link you entered is a bad link!'),
                            actions: <Widget>[
                              ElevatedButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    });
                  } else if (snapshot.data == 'good') {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Safe Link'),
                            content: Text('The link is safe to be used.'),
                            actions: <Widget>[
                              ElevatedButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    });
                  }
                  return Text('Result: ${snapshot.data ?? 'No result'}');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}