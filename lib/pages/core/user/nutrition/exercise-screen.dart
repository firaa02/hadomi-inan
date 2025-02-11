import 'package:flutter/material.dart';

class ExerciseGuideScreen extends StatelessWidget {
  const ExerciseGuideScreen({super.key});

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
          'Latihan Fisik yang Aman',
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
            _buildExerciseCategories(),
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
        'Panduan lengkap latihan fisik yang aman untuk ibu hamil',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildExerciseCategories() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildExerciseCategory(
            title: 'Latihan Pernapasan',
            description: 'Teknik pernapasan untuk kehamilan dan persalinan',
            icon: Icons.air,
            color: Colors.blue,
            exercises: [
              Exercise(
                name: 'Pernapasan Dalam',
                duration: '5-10 menit',
                steps: [
                  'Duduk dengan nyaman atau berbaring miring',
                  'Tarik napas dalam melalui hidung selama 4 hitungan',
                  'Tahan napas selama 2 hitungan',
                  'Hembuskan perlahan melalui mulut selama 4 hitungan',
                  'Ulangi 5-10 kali'
                ],
                benefits:
                    'Menenangkan pikiran, mengurangi stres, dan meningkatkan oksigenasi',
                precautions: 'Hentikan jika merasa pusing atau tidak nyaman',
              ),
              Exercise(
                name: 'Pernapasan Persalinan',
                duration: '10-15 menit',
                steps: [
                  'Mulai dengan posisi duduk nyaman',
                  'Tarik napas pendek dan cepat melalui hidung',
                  'Hembuskan dengan cepat melalui mulut',
                  'Lakukan dengan ritme teratur',
                  'Praktikkan selama kontraksi'
                ],
                benefits: 'Persiapan menghadapi kontraksi saat persalinan',
                precautions: 'Lakukan secara bertahap dan tidak terburu-buru',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildExerciseCategory(
            title: 'Yoga Prenatal',
            description: 'Gerakan yoga yang aman untuk ibu hamil',
            icon: Icons.self_improvement,
            color: Colors.purple,
            exercises: [
              Exercise(
                name: 'Pose Kucing dan Sapi',
                duration: '5-10 menit',
                steps: [
                  'Mulai dengan posisi merangkak',
                  'Saat menarik napas, lengkungkan punggung ke bawah',
                  'Saat menghembuskan napas, bulatkan punggung ke atas',
                  'Gerakkan kepala dan leher dengan lembut',
                  'Ulangi 5-8 kali'
                ],
                benefits:
                    'Meredakan nyeri punggung dan melenturkan tulang belakang',
                precautions: 'Hindari gerakan yang terlalu ekstrem',
              ),
              Exercise(
                name: 'Pose Bersila Modifikasi',
                duration: '10-15 menit',
                steps: [
                  'Duduk dengan bantal di bawah panggul',
                  'Luruskan punggung perlahan',
                  'Tarik napas dalam dan rilekskan bahu',
                  'Fokus pada pernapasan',
                  'Tambahkan stretching ringan jika nyaman'
                ],
                benefits:
                    'Meningkatkan fleksibilitas panggul dan menenangkan pikiran',
                precautions: 'Gunakan bantal untuk kenyamanan',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildExerciseCategory(
            title: 'Jalan Kaki',
            description: 'Panduan berjalan kaki yang aman',
            icon: Icons.directions_walk,
            color: Colors.green,
            exercises: [
              Exercise(
                name: 'Jalan Kaki Ringan',
                duration: '15-30 menit',
                steps: [
                  'Pilih waktu yang sejuk (pagi/sore)',
                  'Gunakan sepatu yang nyaman',
                  'Mulai dengan pemanasan ringan',
                  'Jalan dengan kecepatan nyaman',
                  'Akhiri dengan pendinginan'
                ],
                benefits: 'Meningkatkan stamina dan sirkulasi darah',
                precautions: 'Hindari jalan di permukaan tidak rata atau licin',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildExerciseCategory(
            title: 'Latihan Kegel',
            description: 'Penguatan otot dasar panggul',
            icon: Icons.fitness_center,
            color: Colors.orange,
            exercises: [
              Exercise(
                name: 'Kegel Dasar',
                duration: '5-10 menit',
                steps: [
                  'Identifikasi otot dasar panggul',
                  'Kencangkan otot selama 5 detik',
                  'Rilekskan selama 5 detik',
                  'Ulangi 10 kali',
                  'Lakukan 3 set per hari'
                ],
                benefits: 'Mencegah inkontinensia dan mempersiapkan persalinan',
                precautions: 'Jangan menahan napas saat melakukan latihan',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSafetyTips(),
        ],
      ),
    );
  }

  Widget _buildExerciseCategory({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<Exercise> exercises,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
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
                    ),
                  ),
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
        children: exercises
            .map((exercise) => _buildExerciseItem(exercise, color))
            .toList(),
      ),
    );
  }

  Widget _buildExerciseItem(Exercise exercise, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Durasi: ${exercise.duration}',
                  style: TextStyle(color: color),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildExerciseSection('Langkah-langkah:', exercise.steps, color),
          const SizedBox(height: 12),
          _buildBenefitsAndPrecautions(exercise, color),
        ],
      ),
    );
  }

  Widget _buildExerciseSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
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
                    child: Text(item),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildBenefitsAndPrecautions(Exercise exercise, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Manfaat: ${exercise.benefits}',
                  style: TextStyle(color: color),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Perhatian: ${exercise.precautions}',
                  style: TextStyle(color: color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyTips() {
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
                  Icons.safety_check,
                  color: Color(0xFF6B57D2),
                ),
                SizedBox(width: 8),
                Text(
                  'Tips Keamanan',
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
                'Konsultasikan dengan dokter sebelum memulai program latihan'),
            _buildTipItem('Hindari olahraga dengan risiko jatuh atau benturan'),
            _buildTipItem(
                'Perhatikan tanda-tanda tubuh dan jangan memaksakan diri'),
            _buildTipItem('Pastikan ruangan berventilasi baik dan suhu nyaman'),
            _buildTipItem(
                'Minum air yang cukup sebelum, selama, dan setelah latihan'),
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

class Exercise {
  final String name;
  final String duration;
  final List<String> steps;
  final String benefits;
  final String precautions;

  Exercise({
    required this.name,
    required this.duration,
    required this.steps,
    required this.benefits,
    required this.precautions,
  });
}
