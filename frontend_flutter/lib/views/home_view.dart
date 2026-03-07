import 'package:flutter/material.dart';
import 'dashboard_view.dart';
import 'member_center_view.dart';
import 'notifications_view.dart';
import 'settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0; // 用來記錄目前點到哪一格

  // 1. 定義分頁列表：首頁、會員中心(借貸資訊)、推播、設定
  final List<Widget> _pages = [
    const DashboardView(),
    const MemberCenterView(),
    const NotificationsView(),
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // 保持深色背景
      // 2. 主體內容：根據選中的索引顯示對應頁面
      body: _pages[_selectedIndex],

      // 3. 底部導航欄：這就是你消失的那四格
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // 目前選中的 Index
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // 點擊時更新 Index，畫面會自動重繪
          });
        },
        type: BottomNavigationBarType.fixed, // 確保四個按鈕寬度平均分配
        backgroundColor: const Color(0xFF161B22), // 導航欄深色背景
        selectedItemColor: Colors.blueAccent, // 選中時變藍色
        unselectedItemColor: Colors.grey, // 未選中灰色
        showUnselectedLabels: true, // 顯示未選中的標籤文字
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '首頁訊息'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '會員中心',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: '推播通知',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: '設定',
          ),
        ],
      ),
    );
  }
}
