import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../providers/app_state_provider.dart';

class FarmerAssistantScreen extends StatefulWidget {
  const FarmerAssistantScreen({super.key});

  @override
  State<FarmerAssistantScreen> createState() => _FarmerAssistantScreenState();
}

class _FarmerAssistantScreenState extends State<FarmerAssistantScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Farmer Assistant')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Ask the assistant',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          final text = _messageController.text.trim();
                          if (text.isEmpty) return;
                          await context.read<AppStateProvider>().sendChatMessage(text);
                          _messageController.clear();
                        },
                  child: state.isLoading ? const CircularProgressIndicator() : const Icon(Icons.send),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: state.chatHistory.length,
              itemBuilder: (context, index) {
                final message = state.chatHistory[index];
                return Align(
                  alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: message.isUser ? Colors.green.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(message.text),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                const Text('Language:'),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: state.chatLanguage,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'es', child: Text('Spanish')),
                    DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                    DropdownMenuItem(value: 'bn', child: Text('Bengali')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      context.read<AppStateProvider>().updateChatLanguage(value);
                    }
                  },
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.mic),
                  label: const Text('Voice'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
