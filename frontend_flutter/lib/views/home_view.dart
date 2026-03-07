// lib/views/home_view.dart — 首頁／導航入口（保留 API 邏輯，成功後顯示新設計 DashboardView）
import 'package:flutter/material.dart';
import '../models/loan_summary.dart';
import '../services/api_service.dart';
import 'dashboard_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // 初始化 API 服務
  final ApiService _apiService = ApiService();

  // 用於存儲非同步抓取的資料狀態
  late Future<LoanSummary> _loanSummaryFuture;

  @override
  void initState() {
    super.initState();
    // 頁面一載入就開始抓資料
    _loanSummaryFuture = _apiService.fetchDashboardSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // 深色背景
      body: SafeArea(
        child: FutureBuilder<LoanSummary>(
          future: _loanSummaryFuture,
          builder: (context, snapshot) {
            // 狀態 1：資料載入中 (顯示旋轉進度條)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );
            }

            // 狀態 2：連線發生錯誤 (例如 Docker 沒開)
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${snapshot.error}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 重新嘗試抓取
                        setState(() {
                          _loanSummaryFuture = _apiService
                              .fetchDashboardSummary();
                        });
                      },
                      child: const Text('重試'),
                    ),
                  ],
                ),
              );
            }

            // 狀態 3：成功抓到資料 → 顯示新設計的 DashboardView（磨砂玻璃、設計稿樣式）
            return DashboardView(summary: snapshot.data);
          },
        ),
      ),
    );
  }
}
