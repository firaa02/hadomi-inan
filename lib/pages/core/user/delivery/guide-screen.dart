import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

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
          'Panduan Persiapan Persalinan',
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
        'Panduan lengkap persiapan menghadapi persalinan',
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
          _buildGuideSection(
            title: 'Teknik Pernapasan',
            description: 'Panduan teknik pernapasan untuk meredakan nyeri',
            icon: Icons.air,
            color: Colors.blue,
            recommendations: [
              'Pernapasan dangkal dan cepat saat kontraksi',
              'Pernapasan dalam dan teratur saat relaksasi',
              'Kombinasi pernapasan dengan gerakan tubuh',
              'Latihan pernapasan diafragma',
              'Teknik menghembuskan napas perlahan'
            ],
            notes:
                'Teknik pernapasan yang tepat dapat membantu mengontrol rasa sakit dan memberikan oksigen yang cukup untuk ibu dan bayi.',
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            title: 'Posisi Persalinan',
            description:
                'Berbagai posisi yang dapat membantu proses persalinan',
            icon: Icons.accessibility_new,
            color: Colors.green,
            recommendations: [
              'Posisi berjalan atau berdiri',
              'Posisi merangkak atau berlutut',
              'Posisi miring ke kiri',
              'Posisi setengah duduk',
              'Posisi jongkok dengan dukungan'
            ],
            notes:
                'Setiap posisi memiliki manfaat tersendiri, pilih yang paling nyaman dan sesuai kondisi.',
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            title: 'Tanda-tanda Persalinan',
            description: 'Mengenali tanda awal persalinan',
            icon: Icons.medical_information,
            color: Colors.orange,
            recommendations: [
              'Kontraksi yang teratur dan semakin kuat',
              'Keluarnya lendir bercampur darah',
              'Pecahnya ketuban',
              'Nyeri punggung bawah yang menetap',
              'Perasaan menekan di panggul'
            ],
            notes:
                'Pahami tanda-tanda ini untuk mengetahui kapan harus ke rumah sakit.',
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            title: 'Persiapan Mental',
            description: 'Tips menjaga kesiapan mental',
            icon: Icons.psychology,
            color: Colors.purple,
            recommendations: [
              'Diskusikan rencana persalinan dengan dokter',
              'Ikuti kelas persiapan persalinan',
              'Praktikkan teknik relaksasi',
              'Berbagi kekhawatiran dengan pasangan',
              'Kumpulkan informasi dari sumber terpercaya'
            ],
            notes:
                'Persiapan mental yang baik akan membantu menghadapi proses persalinan dengan lebih tenang.',
          ),
          const SizedBox(height: 24),
          _buildTipsCard(),
        ],
      ),
    );
  }

  Widget _buildGuideSection({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<String> recommendations,
    required String notes,
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
                  const Text(
                    'Panduan:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...recommendations.map((recommendation) => Padding(
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
                                recommendation,
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

  Widget _buildTipsCard() {
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
                  Icons.lightbulb_outline,
                  color: Color(0xFF6B57D2),
                ),
                SizedBox(width: 8),
                Text(
                  'Tips Penting',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B57D2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTipItem(
                'Praktikkan teknik pernapasan secara rutin sebelum persalinan'),
            _buildTipItem('Komunikasikan keinginan Anda dengan tim medis'),
            _buildTipItem(
                'Pilih pendamping persalinan yang dapat memberi dukungan'),
            _buildTipItem(
                'Siapkan musik relaksasi atau aktivitas pengalih perhatian'),
            _buildTipItem('Percaya pada kemampuan tubuh Anda untuk melahirkan'),
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
