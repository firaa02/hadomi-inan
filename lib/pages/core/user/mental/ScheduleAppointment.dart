import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleAppointment extends StatefulWidget {
  final Map<String, dynamic> selectedCounselor;

  const ScheduleAppointment({
    Key? key,
    required this.selectedCounselor,
  }) : super(key: key);

  @override
  State<ScheduleAppointment> createState() => _ScheduleAppointmentState();
}

class _ScheduleAppointmentState extends State<ScheduleAppointment> {
  DateTime selectedDate = DateTime.now();
  String selectedTime = '09:00';
  final List<String> availableTimes = [
    '09:00',
    '10:00',
    '11:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00'
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add this method
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B57D2),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _confirmAppointment() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan login terlebih dahulu')),
        );
        return;
      }

      // Get user data for the appointment
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(currentUser.uid).get();

      // Format date and time for consistency
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

      // Create appointment document
      Map<String, dynamic> appointmentData = {
        'userId': currentUser.uid,
        'patientName': userData['name'] ?? 'Unknown Patient',
        'doctorId': widget.selectedCounselor['id'],
        'doctorName': widget.selectedCounselor['name'],
        'doctorSpecialization': widget.selectedCounselor['specialization'],
        'date': formattedDate,
        'time': selectedTime,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add to appointments collection
      DocumentReference appointmentRef =
          await _firestore.collection('appointments').add(appointmentData);

      // Update doctor's schedule
      await _firestore
          .collection('users')
          .doc(widget.selectedCounselor['id'])
          .update({
        'scheduledAppointments': FieldValue.arrayUnion([
          {
            'appointmentId': appointmentRef.id,
            'userId': currentUser.uid,
            'date': formattedDate,
            'time': selectedTime,
          }
        ])
      });

      // Show success message
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal konsultasi berhasil dibuat'),
          backgroundColor: Color(0xFF6B57D2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Atur Jadwal Konsultasi',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6B57D2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCounselorInfo(),
            const SizedBox(height: 20),
            _buildDateSelection(),
            const SizedBox(height: 20),
            _buildTimeSelection(),
            const SizedBox(height: 30),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCounselorInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: widget.selectedCounselor['profileImage'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        base64Decode(
                          widget.selectedCounselor['profileImage']
                              .split(',')
                              .last,
                        ),
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.person, size: 30, color: Colors.grey),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.selectedCounselor['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.selectedCounselor['specialization'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Tanggal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF6B57D2)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMMM yyyy').format(selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.calendar_today, color: Color(0xFF6B57D2)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Waktu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: availableTimes.map((time) {
            final isSelected = time == selectedTime;
            return InkWell(
              onTap: () {
                setState(() {
                  selectedTime = time;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6B57D2) : Colors.white,
                  border: Border.all(color: const Color(0xFF6B57D2)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF6B57D2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Konfirmasi Jadwal'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dokter: ${widget.selectedCounselor['name']}'),
                  const SizedBox(height: 5),
                  Text(
                      'Spesialisasi: ${widget.selectedCounselor['specialization']}'),
                  const SizedBox(height: 5),
                  Text(
                      'Tanggal: ${DateFormat('dd MMMM yyyy').format(selectedDate)}'),
                  const SizedBox(height: 5),
                  Text('Waktu: $selectedTime'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmAppointment();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B57D2),
                  ),
                  child: const Text('Konfirmasi'),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B57D2),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Konfirmasi Jadwal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
