import 'package:aplikasi_kasir/modules/layout/main_screen.view.dart';
import 'package:aplikasi_kasir/modules/restaurant/models/restaurant_info.model.dart';
import 'package:aplikasi_kasir/modules/restaurant/restaurant.service.dart';
import 'package:aplikasi_kasir/modules/setup/widgets/setup_form.widget.dart';
import 'package:aplikasi_kasir/modules/staff/models/staff.model.dart';
import 'package:aplikasi_kasir/modules/staff/staff.service.dart';
import 'package:flutter/material.dart';
import 'dto/onboarding_item.dto.dart';

class SetupView extends StatefulWidget {
  const SetupView({super.key});

  @override
  State<SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends State<SetupView> {
  final PageController _pageController = PageController();
  final RestaurantService _restaurantService = RestaurantService();
  final StaffService _staffService = StaffService();

  int _currentPage = 0;
  bool _showForm = false;

  final List<OnboardingItemDTO> _pages = [
    OnboardingItemDTO(
      title: 'Halo, Selamat Datang!',
      description:
          'Aplikasi kasir pintar untuk membantu operasional restoran Anda menjadi lebih profesional.',
      icon: Icons.storefront_rounded,
    ),
    OnboardingItemDTO(
      title: 'Kelola Stok & Staff',
      description:
          'Pantau persediaan barang secara real-time dan atur tim Anda dalam satu aplikasi.',
      icon: Icons.inventory_2_rounded,
    ),
    OnboardingItemDTO(
      title: 'Siap Memulai?',
      description:
          'Sedikit lagi! Kita hanya perlu mengatur identitas restoran dan akun admin Anda.',
      icon: Icons.settings_suggest_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We use AnimatedSwitcher for a smooth fade transition
      // when switching from Onboarding to the Form
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _showForm
              ? SetupForm(onSave: _handleSave)
              : Column(
                  key: const ValueKey(
                    'onboarding_column',
                  ), // Key needed for AnimatedSwitcher
                  children: [
                    // 1. The Sliding Content
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _pages.length,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemBuilder: (context, index) {
                          return _buildPage(_pages[index]);
                        },
                      ),
                    ),

                    // 2. The Bottom Navigation (Dots & Lanjut/Mulai Button)
                    _buildBottomControls(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItemDTO item) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // The Icon acting as a placeholder for an image
          Icon(item.icon, size: 120, color: Colors.blueAccent),
          const SizedBox(height: 40),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page Indicators (Dots)
          Row(
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          // Action Button
          ElevatedButton(
            onPressed: () {
              if (_currentPage < _pages.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                setState(() => _showForm = true);
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(_currentPage == _pages.length - 1 ? 'Mulai' : 'Lanjut'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave(
    String resName,
    String resPhone,
    String staffName,
  ) async {
    try {
      // 1. Create and Save Restaurant Info
      final newRes = RestaurantInfo(name: resName, phone: resPhone);
      await _restaurantService.saveRestaurantInfo(newRes);

      // 2. Create and Save Admin Staff
      final adminStaff = Staff(
        name: staffName,
        role: 'Admin',
        avatar: 'default_admin', // For now we use a string constant
      );
      await _staffService.saveStaff(adminStaff);

      // 3. Success! Go to the Main Dashboard
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      // Handle error (e.g., show a SnackBar)
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    }
  }
}
