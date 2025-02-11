import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imageUrl;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageUrl,
  });
}

class ConsultationChatScreen extends StatefulWidget {
  final Map<String, dynamic> counselor;

  const ConsultationChatScreen({
    super.key,
    required this.counselor,
    required String chatId,
  });

  @override
  State<ConsultationChatScreen> createState() => _ConsultationChatScreenState();
}

class _ConsultationChatScreenState extends State<ConsultationChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;
  late String chatRoomId;
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isChatEnded = false;
  StreamSubscription? _chatSubscription;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _setupChatRoom();
    _listenToChatMessages();
  }

  void _listenToChatMessages() {
    _chatSubscription = _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      // Tambahkan pengecekan mounted dan _isDisposed
      if (_isDisposed || !mounted) return;

      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final messageData = change.doc.data() as Map<String, dynamic>;
          final senderId = messageData['senderId'];

          // Pastikan bukan pesan dari user saat ini
          if (senderId != currentUser!.uid) {
            // Proses pesan
            final newMessage = ChatMessage(
              text: messageData['text'] ?? '',
              isUser: false,
              timestamp: (messageData['timestamp'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
              imageUrl: messageData['imageUrl'],
            );

            // Tambahkan pengecekan mounted
            if (mounted) {
              setState(() {
                // Cegah duplikasi pesan
                if (!_messages.any((m) =>
                    m.text == newMessage.text &&
                    m.timestamp == newMessage.timestamp)) {
                  _messages.add(newMessage);
                  _scrollToBottom();
                }
              });
            }
          }
        }
      }
    }, onError: (error) {
      print('Error in chat messages stream: $error');
    });
  }

  Future<void> _setupChatRoom() async {
    if (currentUser != null) {
      chatRoomId = '${currentUser!.uid}_${widget.counselor['id']}';

      DocumentSnapshot chatRoom =
          await _firestore.collection('chatRooms').doc(chatRoomId).get();

      if (!chatRoom.exists) {
        // Create new chat room with simplified status
        await _firestore.collection('chatRooms').doc(chatRoomId).set({
          'userId': currentUser!.uid,
          'doctorId': widget.counselor['id'],
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': null,
          'lastMessageTime': null,
          'isChatEnded': false,
          'lastChatTimestamp': null,
          'isActive': true, // New field untuk tracking active status
        });

        _addInitialMessage();
      } else {
        await _fetchExistingMessages();

        final chatData = chatRoom.data() as Map<String, dynamic>?;
        final wasPreviouslyClosed = chatData?['isChatEnded'] ?? false;
        final lastChatTimestamp = chatData?['lastChatTimestamp'] as Timestamp?;

        // Jika chat sebelumnya ended, reopen dengan status baru
        if (wasPreviouslyClosed) {
          await _firestore.collection('chatRooms').doc(chatRoomId).update({
            'isChatEnded': false,
            'isActive': true,
            'lastChatTimestamp': FieldValue.serverTimestamp(),
          });
          _addReopeningMessage();
        } else if (_shouldSendReopeningGreeting(lastChatTimestamp)) {
          _addReopeningMessage();
        }

        // Selalu update status active saat user membuka chat
        await _firestore.collection('chatRooms').doc(chatRoomId).update({
          'isActive': true,
        });
      }
    }
  }

  Future<void> _sendImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        // Batasi ukuran gambar
        maxWidth: 800, // Ukuran layar rata-rata
        maxHeight: 800,
        imageQuality: 50, // Kompresi kualitas gambar
      );

      if (image != null) {
        File imageFile = File(image.path);
        List<int> imageBytes = await imageFile.readAsBytes();

        // Batasi ukuran file ke 500KB
        if (imageBytes.length > 500 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gambar terlalu besar. Maksimum 500KB'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }

        String base64Image = base64Encode(imageBytes);

        // Add message to local state first
        if (mounted) {
          setState(() {
            _messages.add(
              ChatMessage(
                text: 'Foto',
                isUser: true,
                timestamp: DateTime.now(),
                imageUrl: base64Image,
              ),
            );
          });
        }

        _scrollToBottom();

        // Batasi jumlah gambar dalam satu chat
        final messagesSnapshot = await _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .collection('messages')
            .where('type', isEqualTo: 'image')
            .get();

        if (messagesSnapshot.docs.length >= 20) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Batas maksimum pengiriman gambar tercapai'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          // Remove the message from local state
          setState(() {
            _messages.removeLast();
          });
          return;
        }

        // Then update Firestore
        await _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .collection('messages')
            .add({
          'text': 'Foto',
          'senderId': currentUser!.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'imageUrl': base64Image,
          'type': 'image',
        });

        await _firestore.collection('chatRooms').doc(chatRoomId).update({
          'lastMessage': 'Foto',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastChatTimestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim gambar: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
        // Remove failed message from local state
        setState(() {
          _messages.removeLast();
        });
      }
    }
  }

  bool _shouldSendReopeningGreeting(Timestamp? lastChatTimestamp) {
    if (lastChatTimestamp == null) return false;

    final lastChatDateTime = lastChatTimestamp.toDate();
    final now = DateTime.now();

    return now.difference(lastChatDateTime).inHours > 24;
  }

  void _addReopeningMessage() async {
    final hour = DateTime.now().hour;
    String greeting = '';

    if (hour < 12) {
      greeting = 'Selamat pagi';
    } else if (hour < 15) {
      greeting = 'Selamat siang';
    } else if (hour < 19) {
      greeting = 'Selamat sore';
    } else {
      greeting = 'Selamat malam';
    }

    String messageText =
        "$greeting,\n\nSaya siap membantu Anda kembali berkonsultasi dengan dokter ${widget.counselor['name']}. Ada yang ingin Anda diskusikan?";

    // Add message to Firestore
    await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'text': messageText,
      'senderId': widget.counselor['id'],
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Add message to local list with mounted check
    if (mounted) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: messageText,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }

    // Reset chat ended status and user left status
    await _firestore.collection('chatRooms').doc(chatRoomId).update({
      'isChatEnded': false,
      'lastChatTimestamp': FieldValue.serverTimestamp(),
      'userLeft': false,
      'userLeftAt': null,
    });

    if (mounted) {
      setState(() {});
    }

    // Scroll to bottom after adding message
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  Future<void> _fetchExistingMessages() async {
    final messagesSnapshot = await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp')
        .get();

    setState(() {
      _messages.addAll(
        messagesSnapshot.docs.map((doc) {
          final data = doc.data();
          return ChatMessage(
            text: data['text'] ?? '',
            isUser: data['senderId'] == currentUser!.uid,
            timestamp: (data['timestamp'] as Timestamp).toDate(),
            imageUrl: data['imageUrl'],
          );
        }).toList(),
      );
    });
  }

  void _addInitialMessage() async {
    final hour = DateTime.now().hour;
    String greeting = '';

    if (hour < 12) {
      greeting = 'Selamat pagi';
    } else if (hour < 15) {
      greeting = 'Selamat siang';
    } else if (hour < 19) {
      greeting = 'Selamat sore';
    } else {
      greeting = 'Selamat malam';
    }

    // Check if there are previous messages in this chat room
    final previousMessagesSnapshot = await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .get();

    String messageText;
    if (previousMessagesSnapshot.docs.isEmpty) {
      // First time chat
      messageText =
          "$greeting,\n\nCeritakan Keluhanmu, Saya akan hubungkan segera dengan dokter ${widget.counselor['name']}";
    } else {
      // Continuation of previous chat
      messageText =
          "$greeting,\n\nAda yang ingin Anda konsultasikan lagi dengan dokter ${widget.counselor['name']}?";
    }

    // Add message to Firestore
    await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'text': messageText,
      'senderId': widget.counselor['id'],
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Add message to local list
    setState(() {
      _messages.add(
        ChatMessage(
          text: messageText,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text;

    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Send message to Firestore
    await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'text': message,
      'senderId': currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('chatRooms').doc(chatRoomId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastChatTimestamp': FieldValue.serverTimestamp(),
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
    await _firestore.collection('chatRooms').doc(chatRoomId).update({
      'isChatEnded': true,
      'endedAt': FieldValue.serverTimestamp(),
      'endedBy': currentUser!.uid,
      // Hapus userLeft karena kita tidak akan menggunakannya lagi
    });

    // Add system message indicating user has left
    await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'text': 'Pasien telah mengakhiri sesi konsultasi',
      'senderId': 'system',
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'system',
    });

    if (mounted) {
      setState(() {
        _isChatEnded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isChatEnded) return true;

        // Show confirmation dialog
        bool? shouldEnd = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Akhiri Konsultasi'),
            content: const Text(
              'Apakah Anda yakin ingin mengakhiri konsultasi ini? Anda masih dapat melihat riwayat chat setelah konsultasi berakhir.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Tidak'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _endChat();
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B57D2),
                ),
                child: const Text('Ya, Akhiri'),
              ),
            ],
          ),
        );

        if (shouldEnd ?? false) {
          // Update status before leaving
          await _firestore.collection('chatRooms').doc(chatRoomId).update({
            'isActive': false,
            'lastVisited': FieldValue.serverTimestamp(),
          });
        }

        return shouldEnd ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF6B57D2),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: widget.counselor['profileImage'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.memory(
                          base64.decode(
                              widget.counselor['profileImage'].split(',').last),
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          errorBuilder: (context, error, stackTrace) => Text(
                            widget.counselor['name'].substring(0, 1),
                            style: const TextStyle(
                              color: Color(0xFF6B57D2),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        widget.counselor['name'].substring(0, 1),
                        style: const TextStyle(
                          color: Color(0xFF6B57D2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.counselor['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.counselor['specialization']} • ${_isChatEnded ? 'Konsultasi Selesai' : 'Online'}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
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
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => _buildOptionsSheet(),
                );
              },
            ),
          ],
          bottom: _isChatEnded
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(30),
                  child: Container(
                    color: Colors.amber[100],
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Konsultasi telah berakhir',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        ),
        body: Column(
          children: [
            // Chat messages container
            Expanded(
              child: Container(
                color: Colors.grey[100],
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('chatRooms')
                      .doc(chatRoomId)
                      .collection('messages')
                      .orderBy('timestamp')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      // Handle potentially null timestamp
                      DateTime messageTimestamp;
                      try {
                        final timestamp = data['timestamp'];
                        if (timestamp is Timestamp) {
                          messageTimestamp = timestamp.toDate();
                        } else {
                          messageTimestamp = DateTime.now();
                        }
                      } catch (e) {
                        messageTimestamp = DateTime.now();
                      }

                      return ChatMessage(
                        text: data['text'] ?? '',
                        isUser: data['senderId'] == currentUser!.uid,
                        timestamp: messageTimestamp,
                        imageUrl: data['imageUrl'],
                      );
                    }).toList();

                    if (messages.isEmpty) {
                      return const Center(
                        child: Text(
                          'Belum ada pesan. Mulai konsultasi sekarang!',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(messages[index]);
                      },
                    );
                  },
                ),
              ),
            ),

            // Typing indicator
            if (_isTyping && !_isChatEnded) _buildTypingIndicator(),

            // Message input field
            if (!_isChatEnded) _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            '${widget.counselor['name']} sedang mengetik',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isChatEnded)
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Akhiri Konsultasi'),
              onTap: () async {
                Navigator.pop(context); // Close bottom sheet
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Akhiri Konsultasi'),
                    content: const Text(
                      'Apakah Anda yakin ingin mengakhiri konsultasi ini? Anda masih dapat melihat riwayat chat setelah konsultasi berakhir.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Tidak'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _endChat();
                          Navigator.of(context).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B57D2),
                        ),
                        child: const Text('Ya, Akhiri'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  if (mounted) {
                    Navigator.of(context).pop(); // Pop back to previous screen
                  }
                }
              },
            ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Bantuan'),
            onTap: () {
              Navigator.pop(context);
              // Add help functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFF6B57D2) : Colors.white,
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
                            color:
                                message.isUser ? Colors.white : Colors.black87,
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
                    color: message.isUser ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: message.isUser ? Colors.white70 : Colors.black54,
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
    // Jika chat sudah berakhir, tampilkan pesan
    if (_isChatEnded) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[100],
        child: const Center(
          child: Text(
            'Konsultasi telah berakhir',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Input aktif untuk chat yang masih berjalan
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
            // Tombol untuk mengirim gambar
            IconButton(
              icon: const Icon(Icons.photo),
              color: Colors.grey[600],
              onPressed: () async {
                try {
                  await _sendImage();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error sending image: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),

            // Text field untuk input pesan
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
                  // Tampilkan counter karakter jika mendekati batas
                  counterText: _messageController.text.length > 1000
                      ? '${_messageController.text.length}/2000'
                      : null,
                  // Error state jika melebihi batas
                  errorText: _messageController.text.length > 2000
                      ? 'Pesan terlalu panjang'
                      : null,
                ),
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                maxLength: 2000, // Batasi panjang pesan
                onChanged: (text) {
                  // Update state untuk memaksa rebuild counter
                  setState(() {});
                },
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty && text.length <= 2000) {
                    _sendMessage();
                  }
                },
              ),
            ),

            const SizedBox(width: 8),

            // Tombol kirim pesan
            IconButton(
              icon: const Icon(Icons.send),
              color: _messageController.text.trim().isEmpty ||
                      _messageController.text.length > 2000
                  ? Colors.grey[400] // Disabled state
                  : const Color(0xFF6B57D2), // Enabled state
              onPressed: () {
                if (_messageController.text.trim().isEmpty ||
                    _messageController.text.length > 2000) {
                  return;
                }
                _sendMessage();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Set flag bahwa widget sudah di-dispose
    _isDisposed = true;

    // Batalkan subscription
    _chatSubscription?.cancel();

    // Update status chat room
    if (!_isChatEnded && currentUser != null) {
      _firestore.collection('chatRooms').doc(chatRoomId).update({
        'isActive': false,
        'lastVisited': FieldValue.serverTimestamp(),
      }).catchError((error) {
        print('Error updating chat room status: $error');
      });
    }

    _messageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }
}
