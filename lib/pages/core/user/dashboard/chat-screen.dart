import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:async';

// Gemini API Configuration
class GeminiConfig {
  static const String apiKey = 'AIzaSyBChxu0c0MRdq4IPO5CTp3YZFjNj3DkUGQ';
  static GenerativeModel? _model;
  static ChatSession? _chatSession;

  static Future<void> initialize() async {
    try {
      // Initialize the generative model
      _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
      );

      // Start a new chat session with an empty history
      _chatSession = _model!.startChat(history: []);
    } catch (e) {
      debugPrint('Gemini initialization error: $e');
      rethrow;
    }
  }

  static Future<String> generateResponse(String prompt) async {
    try {
      // Ensure the chat session is initialized
      if (_chatSession == null) {
        await initialize();
      }

      final response = await _chatSession!.sendMessage(
        Content.text(prompt),
      );

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini');
      }

      return response.text!;
    } catch (e) {
      debugPrint('Gemini response error: $e');
      return 'Maaf, terjadi kesalahan dalam memproses pesan. Silakan coba lagi nanti. (Error: $e)';
    }
  }

  // Method to reset the chat session if needed
  static void resetChatSession() {
    _chatSession = null;
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Stream<QuerySnapshot> _messagesStream;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
    _messagesStream = _firestore
        .collection('ai_chat_messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _clearChatHistory();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _clearChatHistory();
    }
  }

  Future<void> _clearChatHistory() async {
    try {
      // Delete all existing messages in the chat collection
      final querySnapshot =
          await _firestore.collection('ai_chat_messages').get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error clearing chat history: $e');
    }
  }

  Future<void> _initializeServices() async {
    try {
      setState(() => _isLoading = true);
      await GeminiConfig.initialize();
      await _initializeChat();
      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _initializeChat() async {
    // Add initial welcome message
    await _firestore.collection('ai_chat_messages').add({
      'isBot': true,
      'message':
          'Halo! Saya adalah **Asisten Kesehatan** yang siap membantu Anda!',
      'showFeatures': true,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _handleSendMessage() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon tunggu inisialisasi sistem...')),
      );
      return;
    }

    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isLoading = true);
    _messageController.clear();

    try {
      // Add user message
      await _firestore.collection('ai_chat_messages').add({
        'isBot': false,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Get response from Gemini
      final response = await GeminiConfig.generateResponse(message);

      // Add bot response
      await _firestore.collection('ai_chat_messages').add({
        'isBot': true,
        'message': response,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Custom method to parse bold text
  List<TextSpan> _parseMessageWithBold(String message, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');

    // Find all matches of bold text
    final matches = boldRegex.allMatches(message);

    // Keep track of the last end index
    int lastEnd = 0;

    for (final match in matches) {
      // Add text before the bold section
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: message.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      // Add bold text
      spans.add(TextSpan(
        text: match.group(1),
        style: baseStyle.copyWith(fontWeight: FontWeight.bold),
      ));

      // Update last end index
      lastEnd = match.end;
    }

    // Add any remaining text after the last match
    if (lastEnd < message.length) {
      spans.add(TextSpan(
        text: message.substring(lastEnd),
        style: baseStyle,
      ));
    }

    // If no matches found, return the entire message as a single span
    return spans.isEmpty ? [TextSpan(text: message, style: baseStyle)] : spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            _clearChatHistory(); // Clear chat when navigating back
            Navigator.of(context).pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Asisten Kesehatan',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              _isLoading ? 'Mengetik...' : 'Online',
              style: TextStyle(
                fontSize: 12,
                color: _isLoading ? Colors.yellow[400] : Colors.green[400],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF6B57D2),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Terjadi kesalahan'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                        messages[index].data() as Map<String, dynamic>;
                    return _buildMessageItem(messageData);
                  },
                );
              },
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(
              backgroundColor: Color(0xFF6B57D2),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    return Column(
      crossAxisAlignment:
          message['isBot'] ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: message['isBot'] ? Colors.white : const Color(0xFF6B57D2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: _parseMessageWithBold(
                    message['message'],
                    TextStyle(
                      color: message['isBot'] ? Colors.black87 : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ketik pesan Anda...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => _handleSendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _handleSendMessage,
            icon: const Icon(Icons.send),
            color: const Color(0xFF6B57D2),
          ),
        ],
      ),
    );
  }
}
