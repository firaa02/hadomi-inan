import 'package:flutter/material.dart';
import '../pages/core/user/dashboard/dashboard-screen.dart';
import '../pages/core/user/education/education-screen.dart';
import '../pages/core/user/nutrition/nutrition-screen.dart';
import '../pages/core/user/mental/mental-screen.dart';
import '../pages/core/user/delivery/delivery.dart';
import '../pages/core/user/postpartum/postpartum-screen.dart';
import '../pages/core/user/kalkulator/kalkulator.dart';
import '../pages/core/user/reminder/reminder-screen.dart';
import '../pages/core/user/community/community-screen.dart';

class BurgerNavBar extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String currentRoute; // Add this parameter

  const BurgerNavBar({
    super.key,
    required this.scaffoldKey,
    required this.currentRoute, // Add this parameter
  });

  @override
  State<BurgerNavBar> createState() => _BurgerNavBarState();
}

class _BurgerNavBarState extends State<BurgerNavBar> {
  // Remove selectedIndex since we'll use currentRoute instead

  final List<Map<String, dynamic>> menuItems = const [
    {
      'title': 'Dashboard',
      'icon': '🏠',
      'description': 'Pantau perkembangan kehamilan Anda',
      'route': '/dashboard'
    },
    {
      'title': 'Edukasi Kesehatan',
      'icon': '📚',
      'description': 'Informasi lengkap seputar kehamilan',
      'route': '/education'
    },
    {
      'title': 'Nutrisi & Olahraga',
      'icon': '🥗',
      'description': 'Panduan gizi dan aktivitas fisik',
      'route': '/nutrition'
    },
    {
      'title': 'Kesehatan Mental',
      'icon': '🧘‍♀️',
      'description': 'Jaga kesehatan mental & emosional',
      'route': '/mental'
    },
    {
      'title': 'Komunitas',
      'icon': '👥',
      'description': 'Bergabung dengan komunitas ibu hamil',
      'route': '/community'
    },
    {
      'title': 'Persiapan Persalinan',
      'icon': '👶',
      'description': 'Panduan persiapan persalinan',
      'route': '/delivery-prep'
    },
    {
      'title': 'Pasca Melahirkan',
      'icon': '🌸',
      'description': 'Perawatan ibu & bayi pasca melahirkan',
      'route': '/postpartum'
    },
    {
      'title': 'Pengingat',
      'icon': '⏰',
      'description': 'Atur jadwal pemeriksaan & kegiatan',
      'route': '/reminder'
    },
    {
      'title': 'Kalkulator Kehamilan',
      'icon': '🔢',
      'description': 'Hitung usia kehamilan dan perkiraan lahir',
      'route': '/calculator'
    },
  ];

  void _navigateToPage(BuildContext context, String route) {
    Navigator.pop(context); // Tutup drawer

    // Dapatkan parent Navigator
    final NavigatorState navigator = Navigator.of(context);

    // Cek route saat ini untuk menghindari navigasi ke halaman yang sama
    if (widget.currentRoute != route) {
      Widget nextScreen;

      switch (route) {
        case '/dashboard':
          nextScreen = const DashboardScreen();
          break;
        case '/education':
          nextScreen = const EducationScreen();
          break;
        case '/nutrition':
          nextScreen = NutritionScreen();
          break;
        case '/mental':
          nextScreen = MentalHealthScreen();
          break;
        case '/delivery-prep':
          nextScreen = DeliveryPrepScreen();
          break;
        case '/postpartum':
          nextScreen = PostpartumScreen();
          break;
        case '/calculator':
          nextScreen = PregnancyCalculatorScreen();
          break;
        case '/reminder':
          nextScreen = ReminderScreen();
          break;
        case '/community':
          nextScreen = CommunityForumScreen();
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Halaman $route sedang dalam pengembangan')),
          );
          return;
      }

      // Gunakan pushReplacement pada parent Navigator
      navigator.pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 200),
          settings: RouteSettings(name: route),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildMenuList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
        left: 0,
        right: 0,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF6B57D2),
      ),
      child: Column(
        children: [
          // Ganti logo dengan ikon kehamilan
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.pregnant_woman, // Ikon kehamilan bawaan Flutter
              size: 70,
              color: const Color(0xFF6B57D2), // Warna ikon
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Hadomi Inan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'cr: Hadidja Ali hosman',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        final isSelected =
            widget.currentRoute == item['route']; // Update this line

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6B57D2).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6B57D2)
                    : const Color(0xFF6B57D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  item['icon']!,
                  style: TextStyle(
                    fontSize: 20,
                    color: isSelected ? Colors.white : null,
                  ),
                ),
              ),
            ),
            title: Text(
              item['title']!,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: const Color(0xFF2D3142),
              ),
            ),
            subtitle: Text(
              item['description']!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            selected: isSelected,
            onTap: () {
              _navigateToPage(context, item['route']);
            },
          ),
        );
      },
    );
  }
}
