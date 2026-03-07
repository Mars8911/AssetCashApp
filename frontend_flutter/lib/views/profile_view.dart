import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/dashboard_design.dart';

/// 個人資料／個人設定頁（對應 design_assets SettingsPage：頭像、個人資訊、安全設定、功能選單）
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  // 設計稿範例：不可更改的個人資訊
  static const _userInfo = _ProfileUserInfo(
    name: '王小明',
    email: 'xiaoming@example.com',
    phone: '0912-345-678',
    idNumber: 'A123456789',
    store: 'A店家',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    DashboardDesign.spacing4,
                    DashboardDesign.spacing4,
                    DashboardDesign.spacing4,
                    80,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(),
                      const SizedBox(height: 16),
                      _buildSectionTitle('個人資訊'),
                      const SizedBox(height: 8),
                      _buildPersonalInfoCard(),
                      const SizedBox(height: 16),
                      _buildSectionTitle('安全設定'),
                      const SizedBox(height: 8),
                      _buildSecurityCard(context),
                      const SizedBox(height: 16),
                      _buildSectionTitle('功能'),
                      const SizedBox(height: 8),
                      _buildMenuCard(context),
                      const SizedBox(height: 24),
                      _buildVersionFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 頂部區域：個人設定 + 管理您的個人資訊（design_assets 的 slate-800/50 + border-b）
  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: DashboardDesign.blurXl,
          sigmaY: DashboardDesign.blurXl,
        ),
        child: Container(
          padding: const EdgeInsets.all(DashboardDesign.spacing4),
          decoration: BoxDecoration(
            color: DashboardDesign.headerSlate800.withOpacity(0.5),
            border: const Border(
              bottom: BorderSide(
                color: DashboardDesign.borderWhite10,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '個人設定',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: DashboardDesign.fontSizeXl,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '管理您的個人資訊',
                style: TextStyle(
                  color: DashboardDesign.textBlue300,
                  fontSize: DashboardDesign.fontSizeXs,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 個人資料卡片：大頭貼（含綠點）+ 姓名 + 電子郵箱 + 所屬店家標籤（design_assets 第一張卡）
  Widget _buildProfileCard() {
    return ClipRRect(
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
            gradient: DashboardDesign.cardGradient,
            borderRadius:
                BorderRadius.circular(DashboardDesign.radius2xl),
            border: Border.all(color: DashboardDesign.white20, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildAvatarWithStatus(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userInfo.name,
                      style: GoogleFonts.lexend(
                        color: Colors.white,
                        fontSize: DashboardDesign.fontSizeLg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userInfo.email,
                      style: TextStyle(
                        color: DashboardDesign.textBlue200,
                        fontSize: DashboardDesign.fontSizeXs,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _buildStoreBadge(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarWithStatus() {
    final initial =
        _userInfo.name.isNotEmpty ? _userInfo.name[0] : '?';
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: DashboardDesign.accentGradient,
              borderRadius:
                  BorderRadius.circular(DashboardDesign.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: DashboardDesign.blue500.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.lexend(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: DashboardDesign.green400,
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

  Widget _buildStoreBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: DashboardDesign.blue500.withOpacity(0.2),
        borderRadius:
            BorderRadius.circular(DashboardDesign.radiusLg),
        border: Border.all(
          color: DashboardDesign.blue500.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        _userInfo.store,
        style: TextStyle(
          color: DashboardDesign.textBlue300,
          fontSize: DashboardDesign.fontSizeXs,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: DashboardDesign.textBlue300,
          fontSize: DashboardDesign.fontSizeXs,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 個人資訊區塊：姓名、電子郵箱、電話、身分證、所屬店家（各列左圖示 + 標籤/值 + 不可更改）
  Widget _buildPersonalInfoCard() {
    return _buildFrostedCard(
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            iconGradient: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
            label: '姓名',
            value: _userInfo.name,
          ),
          _buildInfoDivider(),
          _buildInfoRow(
            icon: Icons.mail_outline_rounded,
            iconGradient: const [Color(0xFF06B6D4), Color(0xFF0891B2)],
            label: '電子郵箱',
            value: _userInfo.email,
          ),
          _buildInfoDivider(),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            iconGradient: const [Color(0xFF22C55E), Color(0xFF16A34A)],
            label: '電話號碼',
            value: _userInfo.phone,
          ),
          _buildInfoDivider(),
          _buildInfoRow(
            icon: Icons.badge_outlined,
            iconGradient: const [Color(0xFFA855F7), Color(0xFF9333EA)],
            label: '身分證字號',
            value: _userInfo.idNumber,
          ),
          _buildInfoDivider(),
          _buildInfoRow(
            icon: Icons.store_outlined,
            iconGradient: const [Color(0xFFF97316), Color(0xFFEA580C)],
            label: '所屬店家',
            value: _userInfo.store,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFrostedCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DashboardDesign.radiusXl),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: DashboardDesign.blurXl,
          sigmaY: DashboardDesign.blurXl,
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: DashboardDesign.white5,
            borderRadius:
                BorderRadius.circular(DashboardDesign.radiusXl),
            border: Border.all(
              color: DashboardDesign.borderWhite10,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required List<Color> iconGradient,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(DashboardDesign.spacing4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: iconGradient,
              ),
              borderRadius:
                  BorderRadius.circular(DashboardDesign.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: iconGradient.first.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: DashboardDesign.textBlue300,
                    fontSize: DashboardDesign.fontSizeXs,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: DashboardDesign.fontSizeSm,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '不可更改',
            style: TextStyle(
              color: DashboardDesign.textBlue300,
              fontSize: DashboardDesign.fontSizeXs,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDivider() {
    return Divider(
      height: 1,
      indent: 52,
      endIndent: DashboardDesign.spacing4,
      color: DashboardDesign.white5,
    );
  }

  /// 安全設定：更改密碼列（design_assets Lock + 說明 + Edit2）
  Widget _buildSecurityCard(BuildContext context) {
    return _buildFrostedCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onChangePasswordTap(context),
          borderRadius: BorderRadius.circular(DashboardDesign.radiusXl),
          child: Padding(
            padding: const EdgeInsets.all(DashboardDesign.spacing4),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    ),
                    borderRadius:
                        BorderRadius.circular(DashboardDesign.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '更改密碼',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: DashboardDesign.fontSizeSm,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '定期更改密碼保護帳號安全',
                        style: TextStyle(
                          color: DashboardDesign.textBlue300,
                          fontSize: DashboardDesign.fontSizeXs,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit_outlined,
                  color: DashboardDesign.textBlue300,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 功能選單：聯繫客服、隱私政策、登出
  Widget _buildMenuCard(BuildContext context) {
    return _buildFrostedCard(
      child: Column(
        children: [
          _buildMenuItem(
            context: context,
            icon: Icons.support_agent_outlined,
            iconColor: DashboardDesign.blue500,
            label: '聯繫客服',
            onTap: () => _onSupportTap(context),
          ),
          _buildInfoDivider(),
          _buildMenuItem(
            context: context,
            icon: Icons.privacy_tip_outlined,
            iconColor: DashboardDesign.cyan500,
            label: '隱私政策',
            onTap: () => _onPrivacyTap(context),
          ),
          _buildInfoDivider(),
          _buildMenuItem(
            context: context,
            icon: Icons.logout_rounded,
            iconColor: DashboardDesign.orange400,
            label: '登出',
            isDestructive: true,
            onTap: () => _onLogoutTap(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DashboardDesign.radiusXl),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DashboardDesign.spacing4,
            vertical: DashboardDesign.spacing3,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(DashboardDesign.radiusLg),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isDestructive
                        ? DashboardDesign.orange400
                        : Colors.white,
                    fontSize: DashboardDesign.fontSizeSm,
                    fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }

  Widget _buildVersionFooter() {
    return Center(
      child: Column(
        children: [
          Text(
            'TrackMe v2.5.1',
            style: TextStyle(
              color: DashboardDesign.textBlue300,
              fontSize: DashboardDesign.fontSizeXs,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '© 2026 TrackMe Inc.',
            style: TextStyle(
              color: DashboardDesign.blue400,
              fontSize: DashboardDesign.fontSizeXs,
            ),
          ),
        ],
      ),
    );
  }

  void _onChangePasswordTap(BuildContext context) {
    // TODO: 開啟更改密碼對話框或頁面
  }

  void _onSupportTap(BuildContext context) {
    // TODO: 開啟客服（電話／網頁／郵件）
  }

  void _onPrivacyTap(BuildContext context) {
    // TODO: 開啟隱私政策網頁或內頁
  }

  void _onLogoutTap(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DashboardDesign.radius2xl),
        ),
        title: const Text(
          '確認登出',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '確定要登出帳號嗎？',
          style: TextStyle(color: Color(0xFF93C5FD)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              '取消',
              style: TextStyle(color: DashboardDesign.textBlue300),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // TODO: 呼叫登出 API 並回到登入頁
            },
            child: const Text(
              '登出',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileUserInfo {
  const _ProfileUserInfo({
    required this.name,
    required this.email,
    required this.phone,
    required this.idNumber,
    required this.store,
  });
  final String name;
  final String email;
  final String phone;
  final String idNumber;
  final String store;
}
