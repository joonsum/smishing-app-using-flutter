import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'themenotifier.dart';

class Display extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Change Theme', style: TextStyle(color: Colors.white)),
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
          child: SwitchListTile(
            title: Text('Dark Mode'),
            activeColor: Colors.blueGrey,
            value: themeNotifier.darkTheme,
            onChanged: (value) {
              themeNotifier.toggleTheme();
            },
          ),
        ),
      ),
    );
  }
}