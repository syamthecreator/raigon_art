import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:raigon_art/core/constants/asset_constants.dart';
import 'package:raigon_art/core/theme/app_colors.dart';
import 'package:raigon_art/core/theme/app_palette.dart';
import 'package:raigon_art/core/widgets/app_snackbar.dart';

// ───────────────────────── Model + store ─────────────────────────

class ShopSettings {
  const ShopSettings({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    this.logo,
  });

  final String name;
  final String phone;
  final String email;
  final String address;

  /// null = default bundled logo.
  final Uint8List? logo;

  static const ShopSettings defaults = ShopSettings(
    name: 'Raigon Arts',
    phone: '+91 8921348433',
    email: 'orders@raigonarts.com',
    address: 'Main Workshop, MG Road, Overbridge Junction, Trivandrum, Kerala -695001',
  );
}

/// Holds the last *saved* settings so they survive navigating between screens.
class ShopSettingsStore {
  ShopSettingsStore._();

  static final ValueNotifier<ShopSettings> settings =
      ValueNotifier<ShopSettings>(ShopSettings.defaults);

  static void save(ShopSettings s) => settings.value = s;
}

// ───────────────────────── Screen ─────────────────────────

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  Uint8List? _logo;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final s = ShopSettingsStore.settings.value;
    _name = TextEditingController(text: s.name);
    _phone = TextEditingController(text: s.phone);
    _email = TextEditingController(text: s.email);
    _address = TextEditingController(text: s.address);
    _logo = s.logo;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  // ───────────── validation ─────────────

  bool get _nameOk => _name.text.trim().isNotEmpty;
  bool get _phoneOk => _phone.text.replaceAll(RegExp(r'\D'), '').length >= 10;
  bool get _emailOk =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim());
  bool get _addressOk => _address.text.trim().isNotEmpty;

  // ───────────── actions ─────────────

  Future<void> _pickLogo() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
      );

      if (files.isEmpty) return;

      final file = files.first;
      final bytes = await file.readAsBytes();

      if (!mounted) return;

      setState(() {
        _logo = bytes;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the image picker.')),
      );
    }
  }

  void _reset() {
    const d = ShopSettings.defaults;
    setState(() {
      _name.text = d.name;
      _phone.text = d.phone;
      _email.text = d.email;
      _address.text = d.address;
      _logo = null;
      _submitted = false;
    });
    AppSnackBar.success(context, 'Settings reset to default.');
  }

  void _save() {
    setState(() => _submitted = true);
    if (!(_nameOk && _phoneOk && _emailOk && _addressOk)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields correctly.'),
        ),
      );
      return;
    }
    ShopSettingsStore.save(
      ShopSettings(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        address: _address.text.trim(),
        logo: _logo,
      ),
    );
    AppSnackBar.success(context, 'Settings saved successfully.');
  }

  // ───────────── build ─────────────

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
                      _field(
                        p,
                        controller: _name,
                        invalid: _submitted && !_nameOk,
                      ),
                    );
                    final phoneField = _labeled(
                      p,
                      'Business Phone',
                      _field(
                        p,
                        controller: _phone,
                        keyboard: TextInputType.phone,
                        invalid: _submitted && !_phoneOk,
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
                    controller: _email,
                    keyboard: TextInputType.emailAddress,
                    invalid: _submitted && !_emailOk,
                  ),
                ),
                const SizedBox(height: 18),
                _labeled(
                  p,
                  'Physical Workshop Address',
                  _field(
                    p,
                    controller: _address,
                    multiline: true,
                    invalid: _submitted && !_addressOk,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _titleRow(AppPalette p) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
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
                style: TextStyle(fontSize: 14.5, color: p.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _GradientButton(
          icon: Icons.save,
          label: 'Save All Changes',
          onTap: _save,
          fontSize: 15.5,
          vPad: 14,
        ),
      ],
    );
  }

  // ───────────── section header ─────────────

  Widget _sectionHeader(AppPalette p) {
    final fg = p.isDark ? AppColors.gold : p.textPrimary;
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: p.isDark
            ? AppColors.gold.withValues(alpha: 0.2)
            : p.tableHeaderBg,
        border: const Border(left: BorderSide(color: AppColors.gold, width: 3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Icon(Icons.domain, size: 18, color: fg),
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

  // ───────────── logo card ─────────────

  Widget _logoCard(AppPalette p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        color: p.isDark ? const Color(0xFF383A52) : p.surface,
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
                      constraints: const BoxConstraints(maxWidth: 470),
                      child: Text(
                        'Upload your high-res shop logo for invoices, framing job slips, customer receipts, and workshop headers.',
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

          final buttons = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _GradientButton(
                icon: Icons.cloud_upload,
                label: 'Upload New Logo',
                onTap: _pickLogo,
                fontSize: 15,
                vPad: 12,
                radius: 8,
              ),
              const SizedBox(width: 12),
              _resetButton(p),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [info, const SizedBox(height: 18), buttons],
            );
          }
          return Row(
            children: [
              Expanded(child: info),
              buttons,
            ],
          );
        },
      ),
    );
  }

  Widget _logoTile(AppPalette p) {
    return GestureDetector(
      onTap: _pickLogo,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
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
                  child: _logo != null
                      ? Image.memory(_logo!, fit: BoxFit.cover)
                      : Image.asset(
                          AssetConstants.raigonLogo,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1B25),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resetButton(AppPalette p) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _reset,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: p.isDark ? const Color(0xFF40425A) : p.softButtonFill,
          borderRadius: BorderRadius.circular(8),
          border: p.isDark ? Border.all(color: p.border) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restart_alt, size: 19, color: p.textPrimary),
            const SizedBox(width: 8),
            Text(
              'Reset Default',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: p.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────── fields ─────────────

  Widget _labeled(AppPalette p, String label, Widget field) {
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
                style: TextStyle(color: Color(0xFFE5484D)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        field,
      ],
    );
  }

  Widget _field(
    AppPalette p, {
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
    bool multiline = false,
    bool invalid = false,
  }) {
    final fill = p.isDark ? p.surface : p.pageBg;
    final base = p.isDark ? Colors.white.withValues(alpha: 0.92) : p.border;
    const red = Color(0xFFE5484D);
    OutlineInputBorder b(Color c, [double w = 1.2]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: c, width: w),
    );
    return SizedBox(
      height: multiline ? 80 : 46,
      child: TextField(
        controller: controller,
        keyboardType: multiline ? TextInputType.multiline : keyboard,
        maxLines: multiline ? null : 1,
        expands: multiline,
        textAlignVertical: multiline ? TextAlignVertical.top : null,
        cursorColor: p.textPrimary,
        onChanged: (_) {
          if (_submitted) setState(() {});
        },
        style: TextStyle(fontSize: 15, color: p.textPrimary),
        decoration: InputDecoration(
          filled: true,
          fillColor: fill,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: multiline ? 14 : 13,
          ),
          enabledBorder: b(invalid ? red : base),
          focusedBorder: b(invalid ? red : AppColors.gold, 1.4),
        ),
      ),
    );
  }
}

// ───────────────────────── Gradient button ─────────────────────────

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onTap,
    required this.icon,
    this.fontSize = 15,
    this.vPad = 13,
    this.radius = 10,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double fontSize;
  final double vPad;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: AppColors.darkGradient,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: vPad),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
