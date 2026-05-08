import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Import semua view menu kamu di sini
import 'package:ruang_sisa/app/modules/home/views/home_view.dart';
import 'package:ruang_sisa/app/modules/add_product/views/add_product_view.dart';
import 'package:ruang_sisa/app/modules/donation/views/donation_view.dart';
import 'package:ruang_sisa/app/modules/profile/views/profile_view.dart';
import 'package:ruang_sisa/app/modules/home/controllers/navigation_controller.dart';

class MainWrapperView extends StatelessWidget {
  const MainWrapperView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller di sini sekali saja
    final NavigationController navBarController = Get.put(NavigationController());

    // Daftar halaman yang akan ditampilkan sesuai index
    final List<Widget> screens = [
      const HomeView(),
      const AddProductView(),
      const DonationView(),
      const ProfileView(),
    ];

    return Scaffold(
      // Obx akan memantau perubahan index dan mengganti body secara otomatis
      body: Obx(() => IndexedStack(
            index: navBarController.currentIndex.value,
            children: screens,
          )),
      
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: navBarController.currentIndex.value,
            selectedItemColor: const Color(0xFF2D6A4F),
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            onTap: (index) => navBarController.currentIndex.value = index,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_box_outlined),
                activeIcon: Icon(Icons.add_box),
                label: 'Tambah',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.volunteer_activism_outlined),
                activeIcon: Icon(Icons.volunteer_activism),
                label: 'Donasi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}