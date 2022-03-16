import 'package:flutter/material.dart';
import 'package:tik_tac_toe/widgets/game.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Tik Tac Toe!"),
      ),
      body: const SizedBox(
        child: Game(),
        height: 400,
      ),
    );
  }
}
