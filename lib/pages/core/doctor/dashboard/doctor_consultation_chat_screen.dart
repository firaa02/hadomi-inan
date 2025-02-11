import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class ChatMessage {
  final String text;
  final bool isDoctor;
  final DateTime timestamp;
  final String? imageUrl;

  ChatMessage({
    required this.text,
    required this.isDoctor,
    required this.timestamp,
    this.imageUrl,
  });
}

class DoctorConsultationChatScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final String chatRoomId;

  const DoctorConsultationChatScreen({
    Key? key,
    required this.user,
    required this.chatRoomId,
  }) : super(key: key);

  @override
  State<DoctorConsultationChatScreen> createState() =>
      _DoctorConsultationChatScreenState();
}

class _DoctorConsultationChatScreenState
    extends State<DoctorConsultationChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isChatEnded = false;

  @override
  void initState() {
    super.initState();
    _fetchExistingMessages();
    _markMessagesAsRead();
  }

  Future<void> _fetchExistingMessages() async {
    final messagesSnapshot = await _firestore
        .collection('chatRooms')
        .doc(widget.chatRoomId)
        .collection('messages')
        .orderBy('timestamp')
        .get();

    setState(() {
      _messages.addAll(
        messagesSnapshot.docs.map((doc) {
          final data = doc.data();
          return ChatMessage(
            text: data['text'] ?? '',
            isDoctor: data['senderId'] == currentUser!.uid,
            timestamp: (data['timestamp'] as Timestamp).toDate(),
            imageUrl: data['imageUrl'],
          );
        }).toList(),
      );
    });
  }

  Future<void> _markMessagesAsRead() async {
    final messagesQuery = await _firestore
        .collection('chatRooms')
        .doc(widget.chatRoomId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: currentUser!.uid)
        .get();

    final batch = _firestore.batch();
    for (var doc in messagesQuery.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> _sendImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        // Batasi ukuran gambar
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 40, // Kompresi yang lebih agresif
      );

      if (image != null) {
        File imageFile = File(image.path);
        List<int> imageBytes = await imageFile.readAsBytes();

        // Batasi ukuran file ke 300KB
        if (imageBytes.length > 300 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gambar terlalu besar. Maksimum 300KB'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }

        String base64Image = base64Encode(imageBytes);

        // Pecah base64 string menjadi chunks jika terlalu panjang
        final int chunkSize = 200 * 1024; // 200KB per chunk
        final List<String> chunks = [];
        for (var i = 0; i < base64Image.length; i += chunkSize) {
          chunks.add(
              base64Image.substring(i, min(i + chunkSize, base64Image.length)));
        }

        // Add message ke Firestore dengan chunks
        await _firestore
            .collection('chatRooms')
            .doc(widget.chatRoomId)
            .collection('messages')
            .add({
          'text': 'Foto',
          'senderId': currentUser!.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'imageUrl': chunks.first, // Simpan chunk pertama sebagai preview
          'imageChunks': chunks, // Simpan semua chunks
          'type': 'image',
          'isRead': false,
        });

        // Update UI setelah berhasil upload
        if (mounted) {
          setState(() {
            _messages.add(
              ChatMessage(
                text: 'Foto',
                isDoctor: true,
                timestamp: DateTime.now(),
                imageUrl: base64Image,
              ),
            );
          });
          _scrollToBottom();
        }

        // Update chat room metadata
        await _firestore.collection('chatRooms').doc(widget.chatRoomId).update({
          'lastMessage': 'Foto',
          'lastMessageTime': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim gambar: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isDoctor: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = false;
    });

    _scrollToBottom();

    await _firestore
        .collection('chatRooms')
        .doc(widget.chatRoomId)
        .collection('messages')
        .add({
      'text': message,
      'senderId': currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
      'isRead': false,
    });

    await _firestore.collection('chatRooms').doc(widget.chatRoomId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
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

  Future<void> _endChat() async {
    // Set state dulu sebelum update Firestore
    if (mounted) {
      setState(() {
        _isChatEnded = true;
      });
    }

    // Update Firestore
    await _firestore.collection('chatRooms').doc(widget.chatRoomId).update({
      'isChatEnded': true,
      'endedAt': FieldValue.serverTimestamp(),
      'endedBy': currentUser!.uid,
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Langsung back tanpa mengakhiri chat
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF6B57D2),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(), // Langsung back
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user['name'] ?? 'Pengguna',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                _isTyping ? 'Mengetik...' : 'Online',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.videocam, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur video call akan segera tersedia'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'end_chat') {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Akhiri Konsultasi'),
                      content: const Text(
                        'Apakah Anda yakin ingin mengakhiri konsultasi ini? Setelah diakhiri, chat tidak dapat dilanjutkan.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await _endChat();
                            if (mounted) {
                              Navigator.pop(context); // Tutup dialog
                              Navigator.pop(
                                  context); // Kembali ke screen sebelumnya
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B57D2),
                          ),
                          child: const Text('Ya, Akhiri'),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'end_chat',
                  child: Row(
                    children: [
                      Icon(Icons.close, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Akhiri Konsultasi',
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isChatEnded)
              Container(
                color: Colors.red[100],
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Konsultasi telah berakhir',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
            // Tampilkan message input hanya jika chat belum berakhir
            if (!_isChatEnded) _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment:
          message.isDoctor ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isDoctor ? const Color(0xFF6B57D2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.imageUrl != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        base64.decode(message.imageUrl!),
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error_outline),
                        ),
                      ),
                    ),
                    if (message.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: message.isDoctor
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                )
              else
                Text(
                  message.text,
                  style: TextStyle(
                    color: message.isDoctor ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: message.isDoctor ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
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
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.photo),
              color: Colors.grey[600],
              onPressed: _sendImage,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan Anda...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              color: const Color(0xFF6B57D2),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
