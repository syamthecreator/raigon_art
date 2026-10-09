
import 'package:flutter/material.dart';
import 'package:raigon_art/core/constants/asset_constants.dart';
import 'package:raigon_art/core/theme/app_colors.dart';
import 'package:raigon_art/core/theme/app_palette.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String _businessName = 'Raigon Arts';
  static const String _businessPhone = '+91 8921348433';
  static const String _businessEmail = 'orders@raigonarts.com';
  static const String _businessAddress =
      'Main Workshop, MG Road, Overbridge Junction, '
      'Trivandrum, Kerala -695001';

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleRow(p),
          const SizedBox(height: 26),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(26),
            decoration: p.card(radius: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(p),
                const SizedBox(height: 18),
                _logoCard(p),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, c) {
                    final nameField = _labeled(
                      p,
                      'Business Name',
                      _field(p, value: _businessName),
                    );

                    final phoneField = _labeled(
                      p,
                      'Business Phone',
                      _field(
                        p,
                        value: _businessPhone,
                        keyboard: TextInputType.phone,
                      ),
                    );

                    if (c.maxWidth < 700) {
                      return Column(
                        children: [
                          nameField,
                          const SizedBox(height: 18),
                          phoneField,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: nameField),
                        const SizedBox(width: 21),
                        Expanded(child: phoneField),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                _labeled(
                  p,
                  'Business Email Address',
                  _field(
                    p,
                    value: _businessEmail,
                    keyboard: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 18),
                _labeled(
                  p,
                  'Physical Workshop Address',
                  _field(
                    p,
                    value: _businessAddress,
                    multiline: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Title ─────────────────────────

  Widget _titleRow(AppPalette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shop Settings',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: p.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Configure business profile, workshop details, and security credentials',
          style: TextStyle(
            fontSize: 14.5,
            color: p.textMuted,
          ),
        ),
      ],
    );
  }

  // ───────────────────────── Section Header ─────────────────────────

  Widget _sectionHeader(AppPalette p) {
    final fg = p.isDark ? AppColors.gold : p.textPrimary;

    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: p.isDark
            ? AppColors.gold.withValues(alpha: 0.2)
            : p.tableHeaderBg,
        border: const Border(
          left: BorderSide(
            color: AppColors.gold,
            width: 3,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Icon(
            Icons.domain,
            size: 18,
            color: fg,
          ),
          const SizedBox(width: 10),
          Text(
            'BUSINESS & WORKSHOP PROFILE',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Logo Card ─────────────────────────

  Widget _logoCard(AppPalette p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: p.isDark
            ? const Color(0xFF383A52)
            : p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final compact = c.maxWidth < 760;

          final info = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _logoTile(p),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        Text(
                          'Workshop Brand Logo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: p.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(
                              alpha: p.isDark ? 0.28 : 0.16,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'PNG, JPG, WEBP',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: p.isDark
                                  ? AppColors.gold
                                  : AppPalette.statusGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 470,
                      ),
                      child: Text(
                        'Official Raigon Arts logo for invoices, framing job slips, customer receipts, and workshop headers.',
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: p.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          if (compact) {
            return info;
          }

          return Row(
            children: [
              Expanded(child: info),
            ],
          );
        },
      ),
    );
  }

  // ───────────────────────── Logo Tile ─────────────────────────

  Widget _logoTile(AppPalette p) {
    return SizedBox(
      width: 94,
      height: 94,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: p.avatarBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFCFCBF0),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                AssetConstants.raigonLogo,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Labeled Field ─────────────────────────

  Widget _labeled(
    AppPalette p,
    String label,
    Widget field,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: p.textPrimary,
            ),
            children: const [
              TextSpan(
                text: '  *',
                style: TextStyle(
                  color: Color(0xFFE5484D),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        field,
      ],
    );
  }

  // ───────────────────────── Read-only Field ─────────────────────────

  Widget _field(
    AppPalette p, {
    required String value,
    TextInputType keyboard = TextInputType.text,
    bool multiline = false,
  }) {
    final fill = p.isDark ? p.surface : p.pageBg;
    final base = p.isDark
        ? Colors.white.withValues(alpha: 0.92)
        : p.border;

    OutlineInputBorder border(
      Color color, [
      double width = 1.2,
    ]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: color,
          width: width,
        ),
      );
    }

    return SizedBox(
      height: multiline ? 80 : 46,
      child: TextField(
        readOnly: true,
        controller: TextEditingController(text: value),
        keyboardType: multiline
            ? TextInputType.multiline
            : keyboard,
        maxLines: multiline ? null : 1,
        expands: multiline,
        textAlignVertical:
            multiline ? TextAlignVertical.top : null,
        style: TextStyle(
          fontSize: 15,
          color: p.textPrimary,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: fill,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: multiline ? 14 : 13,
          ),
          enabledBorder: border(base),
          focusedBorder: border(base),
        ),
      ),
    );
  }
}
