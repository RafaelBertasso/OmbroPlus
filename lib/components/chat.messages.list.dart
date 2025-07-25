import 'package:flutter/material.dart';

class ChatMessagesList extends StatefulWidget {
  final List<Widget> chatWidgets;
  const ChatMessagesList({super.key, required this.chatWidgets});

  @override
  State<ChatMessagesList> createState() => _ChatMessagesListState();
}

class _ChatMessagesListState extends State<ChatMessagesList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.only(top: 20, bottom: 8),
      children: widget.chatWidgets,
    );
  }
}
