import 'package:flutter/material.dart';

class DietProgramScreen extends StatelessWidget {
  const DietProgramScreen({super.key});

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
          'Program Diet Sehat',
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
        'Panduan lengkap nutrisi dan makanan sehat untuk ibu hamil',
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
          _buildExpandedMealSection(
            title: 'Sarapan Sehat',
            description: 'Menu sarapan bergizi untuk memulai hari',
            icon: Icons.wb_sunny,
            color: Colors.orange,
            recommendations: [
              'Oatmeal dengan buah-buahan segar dan madu',
              'Roti gandum utuh dengan telur rebus dan alpukat',
              'Yogurt dengan granola dan potongan buah',
              'Smoothie sayur dan buah dengan susu rendah lemak',
              'Bubur havermut dengan pisang dan kacang almond',
            ],
            notes:
                'Sarapan penting untuk memulai hari dan memberikan energi. Pilih makanan yang kaya serat dan protein.',
          ),
          const SizedBox(height: 16),
          _buildExpandedMealSection(
            title: 'Makan Siang',
            description: 'Pilihan menu makan siang seimbang',
            icon: Icons.restaurant,
            color: Colors.green,
            recommendations: [
              'Nasi merah dengan ikan panggang dan sayur tumis',
              'Sup sayuran dengan potongan daging ayam tanpa lemak',
              'Quinoa dengan tahu, tempe, dan sayuran hijau',
              'Sandwich gandum utuh dengan protein nabati dan selada',
              'Gado-gado dengan telur rebus dan tahu tempe',
            ],
            notes:
                'Makan siang harus mencakup karbohidrat kompleks, protein, dan sayuran untuk energi berkelanjutan.',
          ),
          const SizedBox(height: 16),
          _buildExpandedMealSection(
            title: 'Makan Malam',
            description: 'Menu makan malam ringan dan bergizi',
            icon: Icons.nights_stay,
            color: Colors.blue,
            recommendations: [
              'Ikan panggang dengan sayuran kukus',
              'Sup ayam dengan sayuran dan kentang',
              'Tempe atau tahu bakar dengan sayur tumis',
              'Omelet sayur dengan roti gandum utuh',
              'Salad dengan protein (ayam/ikan) dan alpukat',
            ],
            notes:
                'Pilih porsi yang lebih kecil untuk makan malam dan hindari makanan yang terlalu berat atau berminyak.',
          ),
          const SizedBox(height: 16),
          _buildExpandedMealSection(
            title: 'Camilan Sehat',
            description: 'Pilihan snack sehat di antara waktu makan',
            icon: Icons.apple,
            color: Colors.red,
            recommendations: [
              'Buah-buahan segar (apel, pir, jeruk)',
              'Kacang-kacangan tanpa garam (almond, kenari)',
              'Yogurt dengan potongan buah',
              'Roti gandum dengan selai kacang',
              'Susu atau smoothie buah',
            ],
            notes:
                'Camilan membantu menjaga energi dan gula darah stabil. Pilih camilan sehat dan hindari makanan tinggi gula atau garam.',
          ),
          const SizedBox(height: 24),
          _buildNutritionTips(),
        ],
      ),
    );
  }

  Widget _buildExpandedMealSection({
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
                    'Rekomendasi Menu:',
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

  Widget _buildNutritionTips() {
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
                  'Panduan Nutrisi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B57D2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTipItem('Konsumsi makanan dengan porsi kecil tapi sering'),
            _buildTipItem('Pastikan asupan protein dan karbohidrat seimbang'),
            _buildTipItem('Perbanyak konsumsi sayur dan buah segar'),
            _buildTipItem('Hindari makanan yang digoreng dan tinggi lemak'),
            _buildTipItem('Minum air putih minimal 8 gelas per hari'),
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
