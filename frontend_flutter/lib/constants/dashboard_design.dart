// 設計稿樣式常數（取自 design_assets HomePage.tsx + index.css）
// HEX 顏色、字體大小、圓角、模糊值

import 'package:flutter/material.dart';

/// Dashboard 設計系統常數
abstract class DashboardDesign {
  DashboardDesign._();

  // ---------- 背景與漸層 ----------
  /// 主背景漸層：slate-900 → blue-900 → slate-900
  static const Color bgSlate900 = Color(0xFF0F172A);
  static const Color bgBlue900 = Color(0xFF1E3A8A);
  /// 頂部列：slate-800 → slate-900
  static const Color headerSlate800 = Color(0xFF1E293B);
  static const Color headerSlate900 = Color(0xFF0F172A);

  // ---------- 主色 / 強調色 ----------
  /// blue-500（按鈕、進度條起點）
  static const Color blue500 = Color(0xFF3B82F6);
  /// cyan-500（漸層終點、圖示）
  static const Color cyan500 = Color(0xFF06B6D4);
  /// 次要文字 blue-200 / blue-300
  static const Color textBlue200 = Color(0xFFBFDBFE);
  static const Color textBlue300 = Color(0xFF93C5FD);

  // ---------- 白透明（卡片、邊框） ----------
  static const Color white5 = Color(0x0DFFFFFF);   // bg-white/5  #ffffff0d
  static const Color white10 = Color(0x1AFFFFFF);   // bg-white/10 #ffffff1a
  static const Color white20 = Color(0x33FFFFFF);   // border white/20
  static const Color borderWhite10 = Color(0x1AFFFFFF);

  // ---------- 狀態點顏色（設計稿） ----------
  static const Color orange400 = Color(0xFFFB923C);  // reminder
  static const Color green400 = Color(0xFF4ADE80);   // success
  static const Color blue400 = Color(0xFF60A5FA);     // info

  // ---------- 字體大小（對應 Tailwind） ----------
  static const double fontSizeXs = 12;   // text-xs  0.75rem
  static const double fontSizeSm = 14;   // text-sm  0.875rem
  static const double fontSizeBase = 16; // text-base
  static const double fontSizeLg = 18;   // text-lg
  static const double fontSizeXl = 20;   // text-xl  1.25rem
  static const double fontSize3xl = 30;  // text-3xl 1.875rem

  // ---------- 圓角 Radius ----------
  static const double radiusLg = 8;   // rounded-lg  0.5rem
  static const double radiusXl = 12;   // rounded-xl
  static const double radius2xl = 16; // rounded-2xl 1rem

  // ---------- 模糊（對應 backdrop-blur） ----------
  static const double blurSm = 8;   // backdrop-blur-sm  --blur-sm: 8px
  static const double blurXl = 24;  // backdrop-blur-xl   --blur-xl: 24px

  // ---------- 間距（對應設計稿 p-4, gap-3 等） ----------
  static const double spacing4 = 16;  // p-4
  static const double spacing3 = 12;   // p-3, gap-3
  static const double spacing2 = 8;   // mb-2, gap-2

  /// 主背景漸層（全螢幕）
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgSlate900, bgBlue900, bgSlate900],
    stops: [0.0, 0.5, 1.0],
  );

  /// 頂部列漸層
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [headerSlate800, headerSlate900],
  );

  /// 圖示/按鈕漸層（blue-500 → cyan-500）
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue500, cyan500],
  );

  /// 還款卡片背景漸層（blue-500/20 → cyan-500/20）
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x333B82F6), // blue-500 20%
      Color(0x3306B6D4), // cyan-500 20%
    ],
  );

  /// 進度條漸層
  static const LinearGradient progressGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [blue500, cyan500],
  );
}
