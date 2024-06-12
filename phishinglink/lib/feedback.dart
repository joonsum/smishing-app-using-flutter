import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();

  Future<void> _saveFeedback() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/feedback.txt');
    final dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final feedback = '${dateTime}, ${_feedbackController.text}\n';
    await file.writeAsString(feedback, mode: FileMode.append);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Successfully submitted'))
    );

    Navigator.pop(context); // Navigate back to the settings page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Feedback', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("data/Background.jpg"),
            fit: BoxFit.cover,
            colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop), // Adjust transparency here
          ),
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _feedbackController,
                  decoration: InputDecoration(
                    labelText: 'Enter your feedback',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your feedback';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _saveFeedback();
                  }
                },
                child: Text('Submit'),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}