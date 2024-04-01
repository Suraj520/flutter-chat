// home_page.dart
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Team Chat App"),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text("Please Enter your name"),
                content: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your name',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (_nameController.text.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              username: _nameController.text,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text("Enter"),
                  )
                ],
              ),
            );
          },
          child: const Text(
            "Initiate Team Chat",
            style: TextStyle(
              color: Colors.teal,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  final String username;

  const ChatPage({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat - $username"),
      ),
      body: Center(
        child: Text("Chat Page for $username"),
      ),
    );
  }
}
