import 'package:flutter/material.dart';

class HealthQuestionnairePage extends StatefulWidget {
  const HealthQuestionnairePage({super.key});

  @override
  State<HealthQuestionnairePage> createState() =>
      _HealthQuestionnairePageState();
}

class _HealthQuestionnairePageState extends State<HealthQuestionnairePage> {
  int _currentStep = 0;
  bool _isSubmitting = false;
  final Map<String, dynamic> _answers = {};

  final List<Map<String, dynamic>> _questions = [
    {
      'title': 'Kondisi Umum',
      'questions': [
        {
          'id': 'sleep_quality',
          'question': 'Bagaimana kualitas tidur Anda?',
          'type': 'radio',
          'options': ['Baik', 'Cukup', 'Kurang', 'Sangat Kurang'],
        },
        {
          'id': 'appetite',
          'question': 'Bagaimana nafsu makan Anda?',
          'type': 'radio',
          'options': ['Baik', 'Cukup', 'Kurang', 'Sangat Kurang'],
        },
      ],
    },
    {
      'title': 'Gejala Fisik',
      'questions': [
        {
          'id': 'nausea',
          'question': 'Apakah Anda mengalami mual?',
          'type': 'radio',
          'options': ['Tidak Ada', 'Ringan', 'Sedang', 'Berat'],
        },
        {
          'id': 'fatigue',
          'question': 'Seberapa sering Anda merasa lelah?',
          'type': 'radio',
          'options': ['Jarang', 'Kadang-kadang', 'Sering', 'Sangat Sering'],
        },
      ],
    },
    {
      'title': 'Aktivitas Fisik',
      'questions': [
        {
          'id': 'exercise',
          'question': 'Seberapa sering Anda berolahraga?',
          'type': 'radio',
          'options': [
            'Setiap hari',
            '3-4 kali seminggu',
            '1-2 kali seminggu',
            'Tidak pernah'
          ],
        },
        {
          'id': 'daily_activity',
          'question': 'Bagaimana tingkat aktivitas harian Anda?',
          'type': 'radio',
          'options': [
            'Aktif',
            'Cukup Aktif',
            'Kurang Aktif',
            'Sangat Kurang Aktif'
          ],
        },
      ],
    },
  ];

  void _handleSubmit() async {
    setState(() => _isSubmitting = true);

    // Simulasi pengiriman data
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isSubmitting = false);
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hasil Evaluasi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Berdasarkan jawaban Anda, berikut rekomendasi kami:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildRecommendation(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement save result functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B57D2),
            ),
            child: const Text('Simpan Hasil'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRecommendationItem(
          icon: Icons.hotel,
          title: 'Istirahat',
          content:
              'Usahakan tidur 7-8 jam sehari dan berbaring miring ke kiri.',
        ),
        const SizedBox(height: 12),
        _buildRecommendationItem(
          icon: Icons.restaurant,
          title: 'Nutrisi',
          content: 'Konsumsi makanan bergizi seimbang dan banyak minum air.',
        ),
        const SizedBox(height: 12),
        _buildRecommendationItem(
          icon: Icons.directions_walk,
          title: 'Aktivitas',
          content:
              'Lakukan olahraga ringan seperti jalan kaki atau yoga prenatal.',
        ),
      ],
    );
  }

  Widget _buildRecommendationItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6B57D2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF6B57D2),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kuesioner Kesehatan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6B57D2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF6B57D2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Text(
              'Langkah ${_currentStep + 1} dari ${_questions.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < _questions.length - 1) {
                  setState(() => _currentStep++);
                } else {
                  _handleSubmit();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                }
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              _isSubmitting ? null : details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B57D2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  _currentStep == _questions.length - 1
                                      ? 'SELESAI'
                                      : 'LANJUT',
                                ),
                        ),
                      ),
                      if (_currentStep > 0) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: details.onStepCancel,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('KEMBALI'),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
              steps: _questions.map((section) {
                return Step(
                  title: Text(
                    section['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Column(
                    children: (section['questions'] as List).map<Widget>((q) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              q['question'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...q['options'].map<Widget>((option) {
                              return RadioListTile<String>(
                                title: Text(option),
                                value: option,
                                groupValue: _answers[q['id']],
                                onChanged: (value) {
                                  setState(() {
                                    _answers[q['id']] = value;
                                  });
                                },
                                activeColor: const Color(0xFF6B57D2),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  isActive: _currentStep >= _questions.indexOf(section),
                  state: _currentStep > _questions.indexOf(section)
                      ? StepState.complete
                      : StepState.indexed,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
