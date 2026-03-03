import 'package:flutter/material.dart';

class DebugConsole extends StatefulWidget {
  final bool visible;
  final List<String> logs;
  final Function(String) onLog;

  const DebugConsole({
    super.key,
    this.visible = false,
    required this.logs,
    required this.onLog,
  });

  @override
  State<DebugConsole> createState() => _DebugConsoleState();
}

class _DebugConsoleState extends State<DebugConsole> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleInput(String input) {
    if (input.trim().isNotEmpty) {
      widget.onLog(input);
      _inputController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          border: Border.all(color: Colors.blueAccent, width: 2),
        ),
        child: Column(
          children: [
            Container(
              color: Colors.blueAccent,
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Text(
                    'DEBUG CONSOLE',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      // This will be handled by the parent
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.logs.length,
                reverse: true,
                itemBuilder: (context, index) {
                  final log = widget.logs[widget.logs.length - 1 - index];
                  return Container(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      log,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter command...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                      ),
                      onSubmitted: _handleInput,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _handleInput(_inputController.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}