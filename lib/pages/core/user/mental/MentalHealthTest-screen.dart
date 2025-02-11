import 'package:flutter/material.dart';

class MentalHealthTestScreen extends StatefulWidget {
  const MentalHealthTestScreen({super.key});

  @override
  State<MentalHealthTestScreen> createState() => _MentalHealthTestScreenState();
}

class _MentalHealthTestScreenState extends State<MentalHealthTestScreen> {
  int _currentQuestionIndex = 0;
  List<int> _answers = [];
  bool _showResult = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question':
          'Seberapa sering Anda merasa cemas atau khawatir berlebihan dalam 2 minggu terakhir?',
      'options': [
        'Tidak pernah',
        'Beberapa hari',
        'Lebih dari setengah hari',
        'Hampir setiap hari'
      ]
    },
    {
      'question':
          'Seberapa sering Anda merasa sulit untuk rileks atau beristirahat?',
      'options': [
        'Tidak pernah',
        'Beberapa hari',
        'Lebih dari setengah hari',
        'Hampir setiap hari'
      ]
    },
    {
      'question':
          'Apakah Anda mengalami kesulitan tidur atau perubahan pola tidur?',
      'options': [
        'Tidak pernah',
        'Beberapa hari',
        'Lebih dari setengah hari',
        'Hampir setiap hari'
      ]
    },
    {
      'question': 'Seberapa sering Anda merasa sedih atau tidak bersemangat?',
      'options': [
        'Tidak pernah',
        'Beberapa hari',
        'Lebih dari setengah hari',
        'Hampir setiap hari'
      ]
    },
    {
      'question':
          'Apakah Anda merasa kehilangan minat atau kesenangan dalam melakukan aktivitas sehari-hari?',
      'options': [
        'Tidak pernah',
        'Beberapa hari',
        'Lebih dari setengah hari',
        'Hampir setiap hari'
      ]
    }
  ];

  void _answerQuestion(int score) {
    setState(() {
      _answers.add(score);
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _showResult = true;
      }
    });
  }

  void _restartTest() {
    setState(() {
      _currentQuestionIndex = 0;
      _answers = [];
      _showResult = false;
    });
  }

  Widget _buildResultCard() {
    final totalScore = _answers.reduce((a, b) => a + b);
    String resultText;
    Color resultColor;
    String recommendation;

    if (totalScore <= 5) {
      resultText = 'Risiko Rendah';
      resultColor = Colors.green;
      recommendation =
          'Tetap jaga kesehatan mental Anda dengan melakukan aktivitas yang menyenangkan dan meditasi rutin.';
    } else if (totalScore <= 10) {
      resultText = 'Risiko Sedang';
      resultColor = Colors.orange;
      recommendation =
          'Disarankan untuk berbicara dengan keluarga atau teman terdekat tentang perasaan Anda dan melakukan konsultasi dengan profesional kesehatan.';
    } else {
      resultText = 'Risiko Tinggi';
      resultColor = Colors.red;
      recommendation =
          'Sangat disarankan untuk segera berkonsultasi dengan profesional kesehatan mental untuk mendapatkan bantuan yang tepat.';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hasil Tes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                resultText,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: resultColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Rekomendasi:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              recommendation,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _restartTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B57D2),
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Ulangi Tes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tes Kesehatan Mental',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6B57D2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _showResult
              ? _buildResultCard()
              : Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value:
                              (_currentQuestionIndex + 1) / _questions.length,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6B57D2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Pertanyaan ${_currentQuestionIndex + 1} dari ${_questions.length}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _questions[_currentQuestionIndex]['question'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ...List.generate(
                          _questions[_currentQuestionIndex]['options'].length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ElevatedButton(
                              onPressed: () => _answerQuestion(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF6B57D2),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                    color: Color(0xFF6B57D2),
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 20,
                                ),
                              ),
                              child: Text(
                                _questions[_currentQuestionIndex]['options']
                                    [index],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
