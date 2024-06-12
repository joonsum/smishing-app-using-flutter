import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MyAccount extends StatefulWidget {
  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  String username = '';
  String password = '';
  bool showPassword = false;

  @override
  void initState() {
    super.initState();
    loadCredentials();
  }

  void loadCredentials() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/credentials.txt');

    if (await file.exists()) {
      final lines = await file.readAsLines();

      for (var line in lines) {
        if (line.contains(':')) {
          final credentialsList = line.split(':');

          setState(() {
            username = credentialsList[0];
            password = credentialsList[1];
          });

          break;
        }
      }
    }
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
        title: Text('My Account', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("data/Background.jpg"),
            fit: BoxFit.cover,
            colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop), // Adjust transparency here

          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Username: $username', style: TextStyle(fontSize: 20, color: Colors.black)),
              SizedBox(height: 20),
              Text('Password: ${showPassword ? password : '*' * password.length}', style: TextStyle(fontSize: 20, color: Colors.black)),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey, // This is the button color
                ),
                child: Text('Show Password', style: TextStyle(color: Colors.white)), // This is the text color
                onPressed: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}