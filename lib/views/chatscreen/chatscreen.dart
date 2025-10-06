import 'package:flutter/material.dart';
import 'package:instagram/data/dummy_data.dart';

class ChatScreen extends StatefulWidget {
  final dynamic user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late List<Map<String, dynamic>> messages;

  @override
  void initState() {
    super.initState();
    // load chat messages for this user
    messages = DummyData.chats[widget.user.id] ?? [];
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      messages.add({
        'text': _messageController.text.trim(),
        'isMe': true,
        'time': 'Now',
        'seen': false,
      });
      _messageController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar same as before ...
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.user.profileImage),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.username,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.user.name,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      body: Column(
        children: [
          // messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isLastMessage = index == messages.length - 1;

                return Column(
                  crossAxisAlignment: msg['isMe']
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: msg['isMe']
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: msg['isMe']
                              ? Colors.blue[600]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          msg['text'],
                          style: TextStyle(
                            color: msg['isMe'] ? Colors.white : Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    if (msg['isMe'] && isLastMessage)
                      Padding(
                        padding: const EdgeInsets.only(top: 2, right: 6),
                        child: Text(
                          msg['seen'] == true ? "Seen" : "Delivered",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // input field
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.image_outlined, color: Colors.grey),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Message...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
