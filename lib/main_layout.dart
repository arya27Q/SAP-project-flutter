import 'package:flutter/material.dart';
import 'constants.dart';
import 'sidebar_widget.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String currentView = "Dashboard";
  
  // Variabel penanda status login (nanti bisa dihubungkan ke sistem login asli)
  bool isLoggedIn = true; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: Row(
        children: [
          SidebarWidget(
            currentView: currentView,
            onViewChanged: (view) => setState(() => currentView = view),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // HEADER DENGAN DROPDOWN PROFIL
                  _buildTopProfileHeader(),

                  Expanded(
                    child: Center(
                      child: Text(
                        "Halaman $currentView",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Jika belum login, tampilkan teks saja atau tombol login biasa
          if (!isLoggedIn)
            TextButton(
              onPressed: () => setState(() => currentView = "Login"),
              child: const Text("Sign In"),
            ),

          // Jika sudah login, tampilkan profil dengan dropdown
          if (isLoggedIn)
            PopupMenuButton<String>(
              offset: const Offset(0, 50), // Posisi dropdown muncul di bawah
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'logout') {
                  setState(() {
                    isLoggedIn = false;
                    currentView = "Dashboard";
                  });
                } else {
                  setState(() => currentView = value);
                }
              },
              // Tombol pemicu dropdown
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'Profile',
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 20, color: Colors.black87),
                      SizedBox(width: 10),
                      Text("Profile"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, size: 20, color: Colors.red),
                      SizedBox(width: 10),
                      Text("Logout", style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Admin SAP",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        "Super User",
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Avatar Profil
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryIndigo,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  // ICON PANAH BAWAH (Penanda Dropdown)
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
        ],
      ),
    );
  }
}