import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/dashboard_design.dart';
import '../providers/auth_provider.dart';

/// 個人設定頁（對應 design_assets SettingsPage + 截圖設計稿）
/// 包含：頂部個人卡片、個人資訊列表、安全設定、版本資訊
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  static const _userInfo = _SettingsUserInfo(
    name: '王小明',
    email: 'xiaoming@example.com',
    phone: '0912-345-678',
    idNumber: 'A123456789',
    store: 'A 店家',
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
                      const SizedBox(height: 12),
                      _buildLogoutCard(context),
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

  /// 頁面標題：個人設定 + 管理您的個人資訊
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
                style: GoogleFonts.notoSansTc(
                  color: Colors.white,
                  fontSize: DashboardDesign.fontSizeXl,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '管理您的個人資訊',
                style: GoogleFonts.notoSansTc(
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

  /// 頂部個人卡片：藍色發光頭像（含綠點）+ 姓名 + Email + A 店家標籤
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
                      style: GoogleFonts.notoSansTc(
                        color: Colors.white,
                        fontSize: DashboardDesign.fontSizeLg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userInfo.email,
                      style: GoogleFonts.notoSansTc(
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
                style: GoogleFonts.notoSansTc(
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
        style: GoogleFonts.notoSansTc(
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
        style: GoogleFonts.notoSansTc(
          color: DashboardDesign.textBlue300,
          fontSize: DashboardDesign.fontSizeXs,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 個人資訊列表：姓名、電子郵箱、電話、身分證、所屬店家
  /// 每個項目左側彩色圖示（藍、青、綠、紫、橘），右側「不可更改」
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
          ),
        ],
      ),
    );
  }

  Widget _buildFrostedCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DashboardDesign.radius2xl),
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
                BorderRadius.circular(DashboardDesign.radius2xl),
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
                  style: GoogleFonts.notoSansTc(
                    color: DashboardDesign.textBlue300,
                    fontSize: DashboardDesign.fontSizeXs,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.notoSansTc(
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
            style: GoogleFonts.notoSansTc(
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

  /// 安全設定：更改密碼
  Widget _buildSecurityCard(BuildContext context) {
    return _buildFrostedCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onChangePasswordTap(context),
          borderRadius: BorderRadius.circular(DashboardDesign.radius2xl),
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
                        style: GoogleFonts.notoSansTc(
                          color: Colors.white,
                          fontSize: DashboardDesign.fontSizeSm,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '定期更改密碼保護帳號安全',
                        style: GoogleFonts.notoSansTc(
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

  Widget _buildVersionFooter() {
    return Center(
      child: Column(
        children: [
          Text(
            'TrackMe v2.5.1',
            style: GoogleFonts.notoSansTc(
              color: DashboardDesign.textBlue300,
              fontSize: DashboardDesign.fontSizeXs,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '© 2026 TrackMe Inc.',
            style: GoogleFonts.notoSansTc(
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

  Widget _buildLogoutCard(BuildContext context) {
    return _buildFrostedCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('確認登出'),
                content: const Text('確定要登出帳號嗎？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('登出'),
                  ),
                ],
              ),
            );
            if (ok == true && context.mounted) {
              await context.read<AuthProvider>().logout();
            }
          },
          borderRadius: BorderRadius.circular(DashboardDesign.radius2xl),
          child: Padding(
            padding: const EdgeInsets.all(DashboardDesign.spacing4),
            child: Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: DashboardDesign.textBlue300,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '登出',
                  style: GoogleFonts.notoSansTc(
                    color: Colors.white,
                    fontSize: DashboardDesign.fontSizeSm,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsUserInfo {
  const _SettingsUserInfo({
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
