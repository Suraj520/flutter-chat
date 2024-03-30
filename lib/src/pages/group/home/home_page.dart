import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Team Chat App"),
      ),
      body: Center(
        child: TextButton(
            onPressed: showDialog(context: context, builder: builder),
            child: const Text(
              "Initiate Team Chat",
              style: TextStyle(
                color: Colors.teal,
                fontSize: 16,
              ),
            )),
      ),
    );
  }
}
