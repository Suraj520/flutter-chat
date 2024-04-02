import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Channel Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChannelScreen(),
    );
  }
}

class ChannelScreen extends StatefulWidget {
  @override
  _ChannelScreenState createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  TextEditingController _channelNameController = TextEditingController();
  List<String> _channels = ["General"]; // Default General channel
  String _currentChannel = "General"; // Default current channel
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  void initSocket() {
    // Initialize socket
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
  }

  void switchChannel(String channelName) {
    setState(() {
      _currentChannel = channelName;
    });
  }

  void createChannel() {
    setState(() {
      String newChannel = _channelNameController.text;
      if (newChannel.isNotEmpty && !_channels.contains(newChannel)) {
        _channels.add(newChannel);
        _currentChannel = newChannel;
        _channelNameController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _channels.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Channel Chat'),
          bottom: TabBar(
            isScrollable: true,
            tabs: _channels.map((channel) {
              return Tab(
                text: channel,
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: _channels.map((channel) {
            return ChatScreen(
              socket: socket,
              currentChannel: channel,
            );
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Create New Channel'),
                content: TextField(
                  controller: _channelNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter channel name',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: createChannel,
                    child: Text('Create'),
                  ),
                ],
              ),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final IO.Socket socket;
  final String currentChannel;

  ChatScreen({required this.socket, required this.currentChannel});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    widget.socket.on('message', (data) {
      setState(() {
        _messages.add(data);
      });
    });
  }

  void sendMessage() {
    if (_messageController.text.isNotEmpty &&
        _usernameController.text.isNotEmpty) {
      widget.socket.emit('message',
          '${_usernameController.text} (${widget.currentChannel}): ${_messageController.text}');
      setState(() {
        _messages.add(
            '${_usernameController.text} (${widget.currentChannel}): ${_messageController.text}');
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_messages[index]),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Enter message...',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: sendMessage,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              hintText: 'Enter username...',
            ),
          ),
        ),
      ],
    );
  }
}
