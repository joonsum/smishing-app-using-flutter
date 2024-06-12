import 'package:flutter/material.dart';
import 'displayaccount.dart';
import 'theme.dart';
import 'feedback.dart'; // Import feedback.dart

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
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
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("data/Background.jpg"),
            fit: BoxFit.cover,
            colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop), // Adjust transparency here

          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.account_circle, color: Colors.blueGrey),
                title: Text('My Account'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyAccount()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.brightness_6, color: Colors.blueGrey),
                title: Text('Change Theme'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Display()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.feedback, color: Colors.blueGrey),
                title: Text('Feedback'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FeedbackPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}