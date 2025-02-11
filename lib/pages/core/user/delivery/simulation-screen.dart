import 'package:flutter/material.dart';

class SimulationScreen extends StatelessWidget {
  const SimulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Simulasi Persalinan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6B57D2),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildContentSections(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF6B57D2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Text(
        'Panduan latihan pernapasan dan posisi tubuh untuk menghadapi persalinan',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildContentSections() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSimulationSection(
            title: 'Latihan Pernapasan Awal',
            description: 'Teknik dasar pernapasan untuk kontraksi ringan',
            icon: Icons.air,
            color: Colors.blue,
            steps: [
              'Duduk dengan nyaman, punggung tegak',
              'Tarik napas perlahan melalui hidung selama 4 hitungan',
              'Tahan napas sejenak (1-2 hitungan)',
              'Hembuskan napas perlahan melalui mulut selama 4 hitungan',
              'Ulangi dengan ritme yang sama 5-10 kali'
            ],
            notes:
                'Latihan ini membantu menenangkan pikiran dan mengontrol pernapasan saat kontraksi ringan.',
            duration: '5-10 min',
            frequency: '3-4 kali sehari',
          ),
          const SizedBox(height: 15),
          _buildSimulationSection(
            title: 'Pernapasan Saat Kontraksi',
            description: 'Teknik pernapasan untuk mengatasi kontraksi kuat',
            icon: Icons.healing,
            color: Colors.green,
            steps: [
              'Mulai dengan posisi yang nyaman (duduk/berbaring)',
              'Saat kontraksi mulai, ambil napas cepat dan dangkal',
              'Fokuskan pernapasan di dada atas',
              'Hembuskan napas dengan suara "huh-huh"',
              'Sesuaikan kecepatan dengan intensitas kontraksi'
            ],
            notes:
                'Teknik ini efektif untuk menghadapi kontraksi yang lebih kuat menjelang persalinan.',
            duration: '60-90 sec',
            frequency: 'Sesuai kontraksi',
          ),
          const SizedBox(height: 16),
          _buildSimulationSection(
            title: 'Posisi Persalinan Aktif',
            description: 'Variasi posisi yang membantu proses persalinan',
            icon: Icons.accessibility_new,
            color: Colors.orange,
            steps: [
              'Posisi jongkok dengan pegangan',
              'Posisi merangkak dengan lutut dan tangan',
              'Berbaring miring ke kiri',
              'Duduk di bola persalinan',
              'Berdiri dengan bersandar pada pendamping'
            ],
            notes:
                'Setiap posisi memiliki manfaat tersendiri. Coba dan pilih yang paling nyaman.',
            duration: '10-15 min',
            frequency: 'Senyamannya',
          ),
          const SizedBox(height: 16),
          _buildSimulationSection(
            title: 'Teknik Relaksasi',
            description: 'Metode relaksasi untuk meredakan ketegangan',
            icon: Icons.spa,
            color: Colors.purple,
            steps: [
              'Atur posisi nyaman dengan bantal pendukung',
              'Pejamkan mata dan fokus pada pernapasan',
              'Visualisasikan tempat yang menenangkan',
              'Relaksasi otot dari kepala hingga kaki',
              'Kombinasikan dengan musik yang menenangkan'
            ],
            notes:
                'Teknik relaksasi membantu mengurangi kecemasan dan ketegangan otot.',
            duration: '15-20 min',
            frequency: '2-3 kali sehari',
          ),
          const SizedBox(height: 24),
          _buildPracticeCard(),
        ],
      ),
    );
  }

  Widget _buildSimulationSection({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<String> steps,
    required String notes,
    required String duration,
    required String frequency,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
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
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer, color: color, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                'Durasi: $duration',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.repeat, color: color, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                frequency,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Langkah-langkah:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...steps.map((step) => Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                step,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF2D3142),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: color,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            notes,
                            style: TextStyle(
                              fontSize: 14,
                              color: color.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildPracticeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: const Color(0xFF6B57D2).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: Color(0xFF6B57D2),
                ),
                SizedBox(width: 8),
                Text(
                  'Tips Latihan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B57D2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTipItem('Latihan secara rutin untuk membiasakan diri'),
            _buildTipItem('Ajak pasangan untuk berlatih bersama'),
            _buildTipItem('Gunakan bantal atau matras untuk kenyamanan'),
            _buildTipItem('Catat teknik yang paling cocok untuk Anda'),
            _buildTipItem('Konsultasikan dengan bidan/dokter jika ada keluhan'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              color: Color(0xFF6B57D2),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3142),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
