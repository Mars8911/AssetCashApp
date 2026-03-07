import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/dashboard_design.dart';

/// 通知類別
enum NotificationCategory {
  all('all', '全部通知'),
  payment('payment', '繳款提醒'),
  announcement('announcement', '公告訊息'),
  activity('activity', '活動優惠');

  const NotificationCategory(this.id, this.label);
  final String id;
  final String label;
}

/// 通知資料模型
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.subject,
    required this.description,
    required this.validPeriod,
    required this.category,
    required this.icon,
    required this.isRead,
    this.detailContent,
    this.relatedInfo,
  });

  final int id;
  final String subject;
  final String description;
  final String validPeriod;
  final String category;
  final IconData icon;
  final bool isRead;
  final String? detailContent;
  final List<String>? relatedInfo;
}

/// 推播通知頁（對應 design_assets NotificationsPage.tsx）
class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  NotificationCategory _activeTab = NotificationCategory.all;
  NotificationItem? _selectedNotif;

  static const Color _red500 = Color(0xFFEF4444);
  static const Color _red300 = Color(0xFFFCA5A5);

  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
    NotificationItem(
      id: 1,
      subject: '繳款提醒',
      description: '您本月的還款日為 2026/03/05，請準時繳款以避免產生額外費用',
      validPeriod: '2026/03/01 - 2026/03/05',
      category: 'payment',
      icon: Icons.credit_card_rounded,
      isRead: false,
      detailContent: '親愛的王小明會員，您好！本月應繳金額為 NT\$172,615，繳款日期為每月 5 日。',
      relatedInfo: ['應繳總額：NT\$172,615', '繳款日期：2026/03/05'],
    ),
    NotificationItem(
      id: 2,
      subject: '付款成功通知',
      description: '您於 2026/02/20 的繳款已成功處理，感謝您的準時繳款',
      validPeriod: '2026/02/20',
      category: 'success',
      icon: Icons.check_circle_rounded,
      isRead: false,
      detailContent: '感謝您準時完成繳款！您於 2026/02/20 15:30 透過網路銀行轉帳繳款 NT\$172,615 已成功入帳。',
      relatedInfo: ['繳款金額：NT\$172,615', '繳款時間：2026/02/20 15:30'],
    ),
    NotificationItem(
      id: 3,
      subject: '店家公告',
      description: 'A店家將於 2026/03/10-12 進行系統維護，部分服務暫停',
      validPeriod: '2026/03/10 - 2026/03/12',
      category: 'announcement',
      icon: Icons.campaign_rounded,
      isRead: true,
      detailContent: 'A店家預定於 2026 年 3 月 10 日至 12 日進行系統升級維護作業。',
      relatedInfo: ['維護時間：2026/03/10 00:00 - 03/12 23:59'],
    ),
    NotificationItem(
      id: 4,
      subject: '活動訊息',
      description: '新春特惠活動開跑！3月份準時繳款享 500 元現金回饋',
      validPeriod: '2026/03/01 - 2026/03/31',
      category: 'activity',
      icon: Icons.celebration_rounded,
      isRead: false,
      detailContent: '為感謝會員長期支持，A店家推出新春特惠活動！',
      relatedInfo: ['活動期間：2026/03/01 - 03/31', '回饋金額：NT\$500'],
    ),
    NotificationItem(
      id: 5,
      subject: '優質會員制度',
      description: '恭喜！您已符合優質會員資格，享有專屬優惠與服務',
      validPeriod: '長期有效',
      category: 'membership',
      icon: Icons.workspace_premium_rounded,
      isRead: true,
      detailContent: '親愛的王小明會員，感謝您長期保持良好的還款紀錄！',
      relatedInfo: ['利率優惠：降低 0.5% - 1%', '優先審核：新申請案件優先處理'],
    ),
  ];
  }

  List<NotificationItem> get _filteredNotifications {
    if (_activeTab == NotificationCategory.all) return _notifications;
    return _notifications
        .where((n) => n.category == _activeTab.id)
        .toList();
  }

  int get _unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  void _markAsRead(int id) {
    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        if (_notifications[i].id == id) {
          _notifications[i] = NotificationItem(
            id: _notifications[i].id,
            subject: _notifications[i].subject,
            description: _notifications[i].description,
            validPeriod: _notifications[i].validPeriod,
            category: _notifications[i].category,
            icon: _notifications[i].icon,
            isRead: true,
            detailContent: _notifications[i].detailContent,
            relatedInfo: _notifications[i].relatedInfo,
          );
          break;
        }
      }
    });
  }

  void _onNotificationTap(NotificationItem notif) {
    _markAsRead(notif.id);
    setState(() => _selectedNotif = notif);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: DashboardDesign.backgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  _buildTabs(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        DashboardDesign.spacing4,
                        DashboardDesign.spacing4,
                        DashboardDesign.spacing4,
                        80,
                      ),
                      children: [
                        ..._filteredNotifications.map(
                          (n) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildNotificationCard(n),
                          ),
                        ),
                        if (_filteredNotifications.isEmpty) _buildEmptyState(),
                        const SizedBox(height: 24),
                        _buildNoticeSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedNotif != null) _buildDetailModal(),
        ],
      ),
    );
  }

  /// 頂部：推播通知 + 未讀數量 + 藍色發光鈴鐺 + 紅色數字徽章
  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: DashboardDesign.blurXl,
          sigmaY: DashboardDesign.blurXl,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            DashboardDesign.spacing4,
            DashboardDesign.spacing4,
            DashboardDesign.spacing4,
            DashboardDesign.spacing3,
          ),
          decoration: BoxDecoration(
            color: DashboardDesign.headerSlate800.withOpacity(0.5),
            border: const Border(
              bottom: BorderSide(
                color: DashboardDesign.borderWhite10,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '推播通知',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: DashboardDesign.fontSizeXl,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _unreadCount > 0
                        ? '您有 $_unreadCount 則未讀通知'
                        : '所有通知已讀',
                    style: TextStyle(
                      color: DashboardDesign.textBlue300,
                      fontSize: DashboardDesign.fontSizeXs,
                    ),
                  ),
                ],
              ),
              // 藍色圓形發光背景鈴鐺 + 紅色數字徽章
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: DashboardDesign.accentGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: DashboardDesign.blue500.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  if (_unreadCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _red500,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: DashboardDesign.bgSlate900,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$_unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 分類標籤（可滑動）
  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: DashboardDesign.spacing4,
        vertical: DashboardDesign.spacing3,
      ),
      child: Row(
        children: NotificationCategory.values.map((tab) {
          final isSelected = _activeTab == tab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: DashboardDesign.spacing3,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? DashboardDesign.blue500.withOpacity(0.2)
                      : DashboardDesign.white5,
                  borderRadius:
                      BorderRadius.circular(DashboardDesign.radiusLg),
                  border: Border.all(
                    color: isSelected
                        ? DashboardDesign.blue500.withOpacity(0.3)
                        : DashboardDesign.borderWhite10,
                    width: 1,
                  ),
                ),
                child: Text(
                  tab.label,
                  style: TextStyle(
                    color: isSelected
                        ? DashboardDesign.textBlue300
                        : DashboardDesign.textBlue300.withOpacity(0.8),
                    fontSize: DashboardDesign.fontSizeXs,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 通知卡片：磨砂玻璃 + 左圖示（含紅點）+ 中間內容 + 右側標籤
  Widget _buildNotificationCard(NotificationItem notif) {
    return GestureDetector(
      onTap: () => _onNotificationTap(notif),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DashboardDesign.radius2xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: DashboardDesign.blurXl,
            sigmaY: DashboardDesign.blurXl,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DashboardDesign.spacing4),
            decoration: BoxDecoration(
              color: notif.isRead
                  ? DashboardDesign.white5
                  : DashboardDesign.blue500.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(DashboardDesign.radius2xl),
              border: Border.all(
                color: notif.isRead
                    ? DashboardDesign.borderWhite10
                    : DashboardDesign.blue500.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左側圖示 + 未讀紅點
                _buildIconWithBadge(notif),
                const SizedBox(width: 16),
                // 中間內容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notif.subject,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: DashboardDesign.fontSizeSm,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: DashboardDesign.textBlue300,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notif.description,
                        style: TextStyle(
                          color: DashboardDesign.textBlue200,
                          fontSize: DashboardDesign.fontSizeXs,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: DashboardDesign.textBlue300,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            notif.validPeriod,
                            style: TextStyle(
                              color: DashboardDesign.textBlue300,
                              fontSize: DashboardDesign.fontSizeXs,
                            ),
                          ),
                          const Spacer(),
                          _buildReadStatusPill(notif.isRead),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithBadge(NotificationItem notif) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: notif.isRead
                  ? DashboardDesign.white5
                  : DashboardDesign.blue500.withOpacity(0.2),
              borderRadius:
                  BorderRadius.circular(DashboardDesign.radiusXl),
              border: Border.all(
                color: notif.isRead
                    ? DashboardDesign.borderWhite10
                    : DashboardDesign.blue500.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              notif.icon,
              color: notif.isRead
                  ? DashboardDesign.textBlue300
                  : DashboardDesign.cyan500,
              size: 28,
            ),
          ),
          if (!notif.isRead)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _red500,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: DashboardDesign.bgSlate900,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 未讀：淺紅色藥丸；已讀：灰色藥丸
  Widget _buildReadStatusPill(bool isRead) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isRead
            ? DashboardDesign.white10
            : _red500.withOpacity(0.2),
        borderRadius: BorderRadius.circular(999),
        border: isRead
            ? null
            : Border.all(color: _red500.withOpacity(0.5), width: 1),
      ),
      child: Text(
        isRead ? '已讀' : '未讀',
        style: TextStyle(
          color: isRead ? DashboardDesign.textBlue300 : _red300,
          fontSize: DashboardDesign.fontSizeXs,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: DashboardDesign.white5,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: DashboardDesign.textBlue300.withOpacity(0.5),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '目前沒有通知',
            style: TextStyle(
              color: DashboardDesign.textBlue300,
              fontSize: DashboardDesign.fontSizeSm,
            ),
          ),
        ],
      ),
    );
  }

  /// 通知說明區塊
  Widget _buildNoticeSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DashboardDesign.radiusXl),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: DashboardDesign.blurXl,
          sigmaY: DashboardDesign.blurXl,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DashboardDesign.spacing4),
          decoration: BoxDecoration(
            color: DashboardDesign.white5,
            borderRadius:
                BorderRadius.circular(DashboardDesign.radiusXl),
            border: Border.all(
              color: DashboardDesign.borderWhite10,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '通知說明',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: DashboardDesign.fontSizeSm,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• 重要通知會以紅點標示\n• 點擊通知可查看詳細內容\n• 通知保留時間為 30 天',
                style: TextStyle(
                  color: DashboardDesign.textBlue200,
                  fontSize: DashboardDesign.fontSizeXs,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 通知詳情模態框
  Widget _buildDetailModal() {
    final notif = _selectedNotif!;
    return Positioned.fill(
      child: Stack(
        children: [
          // 背景遮罩
          GestureDetector(
            onTap: () => setState(() => _selectedNotif = null),
            child: Container(
              color: Colors.black54,
            ),
          ),
          // 詳情卡片
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1E293B),
                          Color(0xFF0F172A),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(DashboardDesign.radius2xl * 1.5),
                      border: Border.all(
                        color: DashboardDesign.white20,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 頭部
                        Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: DashboardDesign.accentGradient,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () =>
                                  setState(() => _selectedNotif = null),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                notif.icon,
                                color: Colors.white,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                notif.subject,
                                style: GoogleFonts.lexend(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    color: Color(0xFFBFDBFE),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    notif.validPeriod,
                                    style: const TextStyle(
                                      color: Color(0xFFBFDBFE),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                        ),
                        // 內容
                        Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (notif.detailContent != null) ...[
                              Text(
                                notif.detailContent!,
                                style: TextStyle(
                                  color: DashboardDesign.textBlue200,
                                  fontSize: DashboardDesign.fontSizeSm,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            if (notif.relatedInfo != null &&
                                notif.relatedInfo!.isNotEmpty) ...[
                              Text(
                                '相關資訊',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: DashboardDesign.fontSizeSm,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...notif.relatedInfo!.map(
                                (info) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '• ',
                                        style: TextStyle(
                                          color: DashboardDesign.cyan500,
                                          fontSize:
                                              DashboardDesign.fontSizeSm,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          info,
                                          style: TextStyle(
                                            color:
                                                DashboardDesign.textBlue200,
                                            fontSize:
                                                DashboardDesign.fontSizeSm,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      ),
                        // 確認按鈕
                        Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              setState(() => _selectedNotif = null),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DashboardDesign.blue500,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                DashboardDesign.radiusXl,
                              ),
                            ),
                          ),
                          child: const Text('確認'),
                        ),
                      ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
