import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/local_storage_service.dart';
import '../routes/appRoutes.dart';
import '../state/app_state.dart';

/// App settings: notifications, appearance, language, data, account.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _haptics = true;
  bool _sound = true;
  bool _dailyReminder = true;
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadLocal();
  }

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _haptics = prefs.getBool('pref_haptics') ?? true;
      _sound = prefs.getBool('pref_sound') ?? true;
      _dailyReminder = prefs.getBool('pref_daily_reminder') ?? true;
      _phone = prefs.getString('userPhone') ??
          prefs.getString('lastPhoneNumber') ??
          '';
    });
  }

  Future<void> _setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'You will need to verify your phone number again to continue.',
          style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (ok == true) await _logout();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userPhone');
    try {
      await Get.find<LocalStorageService>().logout();
    } catch (_) {
      await prefs.setBool('isLoggedIn', false);
    }
    Get.offAllNamed(AppRoutes.phoneRoute);
  }

  Future<void> _clearCache() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_quiz_topics');
    await prefs.remove('favorite_tip_ids');
    await prefs.remove('read_tip_ids');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Local cache cleared', style: GoogleFonts.poppins()),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _pickLanguage(AppState state) {
    final languages = ['English', 'বাংলা'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Language',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...languages.map((lang) {
                  final selected = state.preferences.language == lang;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(lang, style: GoogleFonts.poppins()),
                    trailing: selected
                        ? const Icon(Icons.check_circle, color: Color(0xFF4F46E5))
                        : null,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      state.updatePreferences(
                        state.preferences.copyWith(language: lang),
                      );
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final maskedPhone = _phone.length >= 11
        ? '${_phone.substring(0, 3)}****${_phone.substring(7)}'
        : (_phone.isEmpty ? 'Not set' : _phone);

    return Scaffold(
      backgroundColor: const Color(0xFFEAEEF6),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEDE7FF), Color(0xFFF8FAFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: const Color(0xFF0F172A),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Tune QuizForge to your style',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.settings_rounded,
                        color: Color(0xFF7C3AED), size: 22),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _AccountCard(phone: maskedPhone, name: state.userName),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Preferences',
                    children: [
                      _SwitchRow(
                        icon: Icons.notifications_active_outlined,
                        iconColor: const Color(0xFF2563EB),
                        title: 'Push notifications',
                        subtitle: 'Streak reminders & tips',
                        value: state.preferences.notificationsEnabled,
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          state.updatePreferences(
                            state.preferences.copyWith(notificationsEnabled: v),
                          );
                        },
                      ),
                      _SwitchRow(
                        icon: Icons.alarm_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        title: 'Daily practice reminder',
                        subtitle: 'Gentle nudge at evening',
                        value: _dailyReminder,
                        onChanged: (v) {
                          setState(() => _dailyReminder = v);
                          _setBool('pref_daily_reminder', v);
                        },
                      ),
                      _SwitchRow(
                        icon: Icons.dark_mode_outlined,
                        iconColor: const Color(0xFF7C3AED),
                        title: 'Dark mode',
                        subtitle: 'Easier on the eyes at night',
                        value: state.preferences.darkMode,
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          state.updatePreferences(
                            state.preferences.copyWith(darkMode: v),
                          );
                        },
                      ),
                      _NavRow(
                        icon: Icons.language_rounded,
                        iconColor: const Color(0xFF059669),
                        title: 'Language',
                        trailing: state.preferences.language,
                        onTap: () => _pickLanguage(state),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Experience',
                    children: [
                      _SwitchRow(
                        icon: Icons.vibration_rounded,
                        iconColor: const Color(0xFF0EA5E9),
                        title: 'Haptic feedback',
                        subtitle: 'Vibrate on taps & actions',
                        value: _haptics,
                        onChanged: (v) {
                          setState(() => _haptics = v);
                          _setBool('pref_haptics', v);
                          if (v) HapticFeedback.selectionClick();
                        },
                      ),
                      _SwitchRow(
                        icon: Icons.volume_up_outlined,
                        iconColor: const Color(0xFFEC4899),
                        title: 'Sound effects',
                        subtitle: 'Quiz correct / wrong cues',
                        value: _sound,
                        onChanged: (v) {
                          setState(() => _sound = v);
                          _setBool('pref_sound', v);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Data & support',
                    children: [
                      _NavRow(
                        icon: Icons.cleaning_services_outlined,
                        iconColor: const Color(0xFF64748B),
                        title: 'Clear local cache',
                        trailing: 'Saved & tips',
                        onTap: _clearCache,
                      ),
                      _NavRow(
                        icon: Icons.info_outline_rounded,
                        iconColor: const Color(0xFF4F46E5),
                        title: 'About QuizForge',
                        trailing: 'v1.0.0',
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'QuizForge',
                            applicationVersion: '1.0.0',
                            applicationLegalese:
                                'Interview prep for Robi/Airtel subscribers.',
                          );
                        },
                      ),
                      _NavRow(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: const Color(0xFF14B8A6),
                        title: 'Privacy policy',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Privacy policy coming soon',
                                  style: GoogleFonts.poppins()),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _confirmLogout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFFECACA)),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final String phone;
  final String name;
  const _AccountCard({required this.phone, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Premium',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
        ),
        trailing: Switch.adaptive(
          value: value,
          activeThumbColor: const Color(0xFF4F46E5),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  const _NavRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null)
              Text(
                trailing!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
