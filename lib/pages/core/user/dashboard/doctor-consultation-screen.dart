import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../mental/ConsultationChat-screen.dart';

class DoctorConsultationScreen extends StatelessWidget {
  const DoctorConsultationScreen({super.key});

  void _startConsultation(
      BuildContext context, Map<String, dynamic> counselor) async {
    // Create chat session
    DocumentReference chatRef =
        await FirebaseFirestore.instance.collection('chat_sessions').add({
      'doctorId': counselor['id'],
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'startTime': FieldValue.serverTimestamp(),
      'active': true,
      'lastActivity': FieldValue.serverTimestamp(),
    });

    String chatId = chatRef.id;

    if (context.mounted) {
      // Navigate directly to chat screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ConsultationChatScreen(
            counselor: {
              ...counselor,
              'chatId': chatId,
            },
            chatId: chatId,
          ),
        ),
      );
    }
  }

  Widget _buildDoctorCard({
    required BuildContext context,
    required String doctorId,
    required String name,
    required String specialty,
    required String experience,
    required bool available,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        specialty,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 5),
                          Text(
                            experience,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  available ? Colors.green[50] : Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              available ? 'Available' : 'Busy',
                              style: TextStyle(
                                color: available ? Colors.green : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: available
                    ? () => _startConsultation(context, {
                          'id': doctorId,
                          'name': name,
                          'specialization': specialty,
                          'description': description,
                        })
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B57D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  available ? 'Mulai Konsultasi' : 'Tidak Tersedia',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Konsultasi Dokter',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6B57D2),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where('role', isEqualTo: 'doctor')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final doctors = snapshot.data!.docs;

          if (doctors.isEmpty) {
            return const Center(
              child: Text('Tidak ada dokter yang tersedia saat ini'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Dokter',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...doctors.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildDoctorCard(
                    context: context,
                    doctorId: doc.id,
                    name: data['name'] ?? 'Dokter',
                    specialty: data['specialty'] ?? 'Umum',
                    experience: data['experience'] ?? '0 tahun pengalaman',
                    available: data['isAvailable'] ?? false,
                    description: data['description'] ?? '',
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
