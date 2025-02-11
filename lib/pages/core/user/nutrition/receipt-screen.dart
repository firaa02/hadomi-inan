import 'package:flutter/material.dart';

class HealthyRecipesScreen extends StatelessWidget {
  const HealthyRecipesScreen({super.key});

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
          'Resep Sehat Ibu Hamil',
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
            _buildRecipeCategories(),
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
        'Koleksi resep makanan bergizi dan sehat untuk ibu hamil',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRecipeCategories() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRecipeCategory(
            title: 'Sarapan Bergizi',
            description: 'Resep sarapan kaya nutrisi',
            icon: Icons.breakfast_dining,
            color: Colors.orange,
            recipes: [
              Recipe(
                name: 'Overnight Oats dengan Buah',
                ingredients: [
                  '1 cup oatmeal',
                  '1 cup susu rendah lemak',
                  'Buah-buahan segar',
                  'Madu secukupnya',
                  'Kacang almond'
                ],
                steps: [
                  'Campurkan oatmeal dengan susu',
                  'Diamkan semalaman di kulkas',
                  'Pagi hari tambahkan buah dan madu',
                  'Taburi dengan kacang almond'
                ],
                nutritionInfo: 'Kaya serat, protein, dan vitamin',
                cookingTime: '10 menit',
              ),
              Recipe(
                name: 'Sandwich Telur Alpukat',
                ingredients: [
                  'Roti gandum utuh',
                  'Telur rebus',
                  'Alpukat',
                  'Selada',
                  'Tomat'
                ],
                steps: [
                  'Panggang roti gandum',
                  'Iris telur rebus dan alpukat',
                  'Susun bahan di atas roti',
                  'Tambahkan sayuran segar'
                ],
                nutritionInfo: 'Tinggi protein dan asam folat',
                cookingTime: '15 menit',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecipeCategory(
            title: 'Makan Siang Sehat',
            description: 'Resep makan siang bernutrisi',
            icon: Icons.lunch_dining,
            color: Colors.green,
            recipes: [
              Recipe(
                name: 'Nasi Merah dengan Ikan Kukus',
                ingredients: [
                  'Nasi merah',
                  'Ikan kakap',
                  'Brokoli',
                  'Wortel',
                  'Bumbu rempah'
                ],
                steps: [
                  'Masak nasi merah',
                  'Kukus ikan dengan bumbu',
                  'Rebus sayuran',
                  'Sajikan bersama'
                ],
                nutritionInfo: 'Tinggi omega-3 dan serat',
                cookingTime: '30 menit',
              ),
              Recipe(
                name: 'Sup Ayam Sayuran',
                ingredients: [
                  'Dada ayam tanpa lemak',
                  'Wortel',
                  'Kentang',
                  'Brokoli',
                  'Kaldu ayam'
                ],
                steps: [
                  'Rebus kaldu ayam',
                  'Masukkan potongan ayam',
                  'Tambahkan sayuran',
                  'Masak hingga matang'
                ],
                nutritionInfo: 'Kaya protein dan vitamin',
                cookingTime: '45 menit',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCookingTips(),
        ],
      ),
    );
  }

  Widget _buildRecipeCategory({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<Recipe> recipes,
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
        children:
            recipes.map((recipe) => _buildRecipeItem(recipe, color)).toList(),
      ),
    );
  }

  Widget _buildRecipeItem(Recipe recipe, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildRecipeSection('Bahan-bahan:', recipe.ingredients, color),
          const SizedBox(height: 8),
          _buildRecipeSection('Cara Membuat:', recipe.steps, color),
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
                  'Waktu Memasak: ${recipe.cookingTime}',
                  style: TextStyle(color: color),
                ),
                const SizedBox(width: 16),
                Icon(Icons.info_outline, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recipe.nutritionInfo,
                    style: TextStyle(color: color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeSection(String title, List<String> items, Color color) {
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

  Widget _buildCookingTips() {
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
                  'Tips Memasak',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B57D2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTipItem('Cuci bahan makanan dengan bersih'),
            _buildTipItem('Masak makanan hingga matang sempurna'),
            _buildTipItem('Hindari penggunaan MSG'),
            _buildTipItem('Gunakan minyak dalam jumlah minimal'),
            _buildTipItem('Simpan makanan dalam wadah tertutup'),
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

class Recipe {
  final String name;
  final List<String> ingredients;
  final List<String> steps;
  final String nutritionInfo;
  final String cookingTime;

  Recipe({
    required this.name,
    required this.ingredients,
    required this.steps,
    required this.nutritionInfo,
    required this.cookingTime,
  });
}
