import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_sms_listener/flutter_sms_listener.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'showhistorymes.dart';

class MessageScanner extends StatefulWidget {
  @override
  _MessageScannerState createState() => _MessageScannerState();
}

class _MessageScannerState extends State<MessageScanner> {
  final myController = TextEditingController();
  Future<Map<String, dynamic>> result = Future.value({'result': 'No message classified yet', 'keywords': []});
  FlutterSmsListener _smsListener = FlutterSmsListener();
  List<SmsMessage> _messagesCaptured = <SmsMessage>[];


  @override
  void initState() {
    super.initState();
    _beginListening();
  }

  void _beginListening() {
    _smsListener.onSmsReceived!.listen((message) {
      _messagesCaptured.add(message);
    });
  }

  void _scanMessage() {
    if (_messagesCaptured.isNotEmpty) {
      setState(() {
        myController.text = _messagesCaptured.last.body ?? '';
        result = Future.value({'result': 'No message classified yet', 'keywords': []}); // Reset the result
      });
    }
  }

  Future<Map<String, dynamic>> classifyMessage(String message) async {
    var response = await http.post(
      Uri.parse('http://10.0.2.2:5000/classifyMessage'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'message': message,
      }),
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data is Map && data.containsKey('result')) {
        String result = data['result'];
        List<String> keywords = List<String>.from(data['keywords'].map((item) => item.toString()));

        // Get the current date and time
        var now = DateTime.now();
        var formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
        String formattedDate = formatter.format(now);

        // Get the path to the documents directory
        final directory = await getApplicationDocumentsDirectory();

        // Write to the text file
        final txtFile = File('${directory.path}/message_scans.txt');
        String fileContent = 'Date: $formattedDate, Message: $message, Result: $result\n';
        if (await txtFile.exists()) {
          await txtFile.writeAsString(fileContent, mode: FileMode.append);
        } else {
          await txtFile.writeAsString(fileContent);
        }

        return {'result': result, 'keywords': keywords};
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to classify message');
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
        title: Text('Message Classification'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("data/Background.jpg"),
            fit: BoxFit.cover,
            colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: myController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your message',
                  filled: true,
                  fillColor: Colors.white70,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    result = classifyMessage(myController.text);
                    myController.clear();
                  });
                },
                child: Text('Classify'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                ),
              ),            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blueGrey,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShowHistoryMesPage()),
                );
              },
              child: Text('View History'),
            ),
              SizedBox(height: 10),
              ScanNewMessageButton(_scanMessage),
              SizedBox(height: 10),
              FutureBuilder<Map<String, dynamic>>(
                future: result,
                builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    if (snapshot.data != null && snapshot.data?['result'] == 'smish') {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Alert'),
                              content: Text('This message may be a smishing attempt! \n Keywords: ${snapshot.data?['keywords']?.join('\n')}'),
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
                    } else if (snapshot.data?['result'] == 'ham') {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Safe Message'),
                              content: Text('This message is safe.'),
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
                    return Column(
                      children: <Widget>[
                        Text('Result: ${snapshot.data?['result'] ?? 'No result'}'),
                        if (snapshot.data?['keywords'] != null)
                          Text('Keywords: ${snapshot.data?['keywords']?.join(', ')}'),
                        ],
                      );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScanNewMessageButton extends StatelessWidget {
  final VoidCallback scanMessage;

  ScanNewMessageButton(this.scanMessage);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        scanMessage();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scanned new message')),
        );
      },
      child: Text('Scan New Message'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.blueGrey   ),
    );
  }
}