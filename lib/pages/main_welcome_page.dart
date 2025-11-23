import 'package:flutter/material.dart';

class MainWelcomePage extends StatelessWidget {
  const MainWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Добро пожаловать!", style: TextStyle(fontSize: 22)),
    );
  }
}
