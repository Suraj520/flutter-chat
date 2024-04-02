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
  List<Map<String, dynamic>> _messages = [];

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
      Map<String, dynamic> messageData = {
        'sender': _usernameController.text,
        'message': _messageController.text,
        'time': DateTime.now(),
      };
      widget.socket.emit('message', messageData);
      setState(() {
        _messages.add(messageData);
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
            reverse: true, // Start from bottom
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return MessageBubble(
                sender: message['sender'],
                message: message['message'],
                time: message['time'],
                isMe: message['sender'] == _usernameController.text,
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
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
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
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String message;
  final DateTime time;
  final bool isMe;

  const MessageBubble({
    required this.sender,
    required this.message,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Material(
            elevation: 5.0,
            borderRadius: BorderRadius.only(
              topLeft: isMe ? Radius.circular(30.0) : Radius.circular(0.0),
              topRight: isMe ? Radius.circular(0.0) : Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                message,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            '$sender • ${time.hour}:${time.minute}',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
