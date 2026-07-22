import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../core/services/local_storage_service.dart';
import '../core/theme.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../routes/appRoutes.dart';
import '../state/app_state.dart';

/// Profile tab — header with avatar/level/XP, stats row, achievement grid,
/// settings list, share, rate, sign-out.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final bool _emailDigest = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // Derived: level number from xp (500 xp / level)
    final lvl = (state.xp ~/ 500) + 1;
    final xpInLevel = state.xp % 500;
    final progress = xpInLevel / 500;

    // Derived accuracy (0..100) across all categories
    final accuracy = state.accuracyByCategory.isEmpty
        ? 0.0
        : state.accuracyByCategory.values
                .fold<double>(0, (a, b) => a + b) /
            state.accuracyByCategory.length *
            100;

    final unlockedBadges =
        state.achievements.take(state.badges).map((a) => a).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 120),
          child: Column(
            children: [
              _HeaderCard(
                userName: state.userName,
                email: state.userEmail,
                xp: state.xp,
                level: lvl,
                progress: progress,
                xpInLevel: xpInLevel,
              ),
              const SizedBox(height: AppSpacing.lg),
              _StatsRow(
                totalQuizzes: state.quizzesTaken,
                streak: state.streakDays,
                badges: state.badges,
                accuracy: accuracy,
              ),
              const SizedBox(height: AppSpacing.lg),
              _Card(
                title: 'Achievements',
                subtitle: '${unlockedBadges.length}/${state.achievements.length} unlocked',
                child: _AchievementGrid(
                  achievements: state.achievements,
                  unlockedCount: state.badges,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Card(
                title: 'Preferences',
                subtitle: 'Tailor your experience',
                child: Column(
                  children: [
                    _SwitchTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark mode',
                      subtitle: 'Easier on the eyes',
                      value: state.preferences.darkMode,
                      onChanged: (_) {
                        HapticFeedback.selectionClick();
                        state.updatePreferences(
                            state.preferences.copyWith(darkMode: !state.preferences.darkMode));
                      },
                    ),
                    const _Divider(),
                    _SwitchTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Push notifications',
                      subtitle: 'Daily streaks & quizzes',
                      value: state.preferences.notificationsEnabled,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        state.updatePreferences(
                            state.preferences.copyWith(notificationsEnabled: v));
                      },
                    ),
                    const _Divider(),
                    const _Divider(),
                    _NavTile(
                      icon: Icons.language_rounded,
                      title: 'Language',
                      trailing: Text(
                        state.preferences.language,
                        style: AppText.body(13, color: AppColors.textSecondary),
                      ),
                      onTap: () => _openLanguageSheet(context, state),
                    ),
                    const _Divider(),
                    _NavTile(
                      icon: Icons.edit_outlined,
                      title: 'Edit profile',
                      onTap: () => _openEditProfileSheet(context, state),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ActionRow(),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmSignOut(context),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Sign out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign out?'),
        content: const Text('You can sign back in anytime.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await _performSignOut(context);
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  Future<void> _performSignOut(BuildContext context) async {
    // 1) Wipe the persisted session through the repository.
    //    (Wraps `LocalStorageService.logout()` + clears in-memory state.)
    try {
      // Use whatever AuthCubit is currently provided up the tree. The
      // main app shell doesn't provide one, so fall back to the factory.
      final cubit = context.mounted ? context.read<AuthCubit>() : null;
      if (cubit != null) {
        await cubit.logout();
      } else {
        final factory = Get.find<AuthCubitFactory>();
        // We don't need a long-lived cubit — invoke the use case directly
        // via the repository so storage is wiped regardless.
        await Get.find<LocalStorageService>().logout();
        // Drop the temp cubit immediately.
        factory.create();
      }
    } catch (_) {
      // Fallback: directly wipe local storage so the user is at least
      // forced to re-authenticate on the next session.
      await Get.find<LocalStorageService>().logout();
    }

    // 2) Hop them back to the phone OTP entry — onboarding is preserved.
    Get.offAllNamed(AppRoutes.phoneRoute);
  }

  void _openLanguageSheet(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select language',
                    style: AppText.headline(18, weight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.md),
                ...kLanguages.map((lang) => RadioListTile<String>(
                      title: Text(lang, style: AppText.body(14)),
                      value: lang,
                      groupValue: state.preferences.language,
                      activeColor: AppColors.primary,
                      onChanged: (v) {
                        if (v != null) {
                          state.updatePreferences(
                              state.preferences.copyWith(language: v));
                        }
                        Navigator.pop(ctx);
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openEditProfileSheet(BuildContext context, AppState state) {
    final nameCtl = TextEditingController(text: state.userName);
    final emailCtl = TextEditingController(text: state.userEmail);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit profile',
                style: AppText.headline(18, weight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: nameCtl,
              decoration: const InputDecoration(
                labelText: 'Display name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: emailCtl,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  state.updateName(nameCtl.text.trim());
                  state.updateEmail(emailCtl.text.trim());
                  Navigator.pop(ctx);
                },
                child: const Text('Save',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------- Header card -------------------------

class _HeaderCard extends StatelessWidget {
  final String userName;
  final String email;
  final int xp;
  final int level;
  final double progress;
  final int xpInLevel;
  const _HeaderCard({
    required this.userName,
    required this.email,
    required this.xp,
    required this.level,
    required this.progress,
    required this.xpInLevel,
  });

  @override
  Widget build(BuildContext context) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppGradients.header,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white,
                  child: Text(
                    initial,
                    style: AppText.headline(32,
                        weight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 14, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(userName,
              style: AppText.headline(22, weight: FontWeight.bold, color: Colors.white)),
          Text(email,
              style: AppText.body(13, color: Colors.white70)),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 10, AppSpacing.md, 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Level $level progress',
                        style: AppText.body(12, color: Colors.white)),
                    Text('$xpInLevel / 500 XP',
                        style: AppText.body(12,
                            weight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total XP',
                        style: AppText.body(11, color: Colors.white70)),
                    Text('$xp',
                        style: AppText.body(11,
                            weight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------- Stats row -------------------------

class _StatsRow extends StatelessWidget {
  final int totalQuizzes;
  final int streak;
  final int badges;
  final double accuracy;
  const _StatsRow({
    required this.totalQuizzes,
    required this.streak,
    required this.badges,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniStat(
            icon: Icons.quiz, value: '$totalQuizzes', label: 'Quizzes'),
        const SizedBox(width: AppSpacing.md),
        _MiniStat(
            icon: Icons.local_fire_department,
            value: '$streak',
            label: 'Day streak',
            color: const Color(0xFFFF6B35)),
        const SizedBox(width: AppSpacing.md),
        _MiniStat(
            icon: Icons.workspace_premium,
            value: '$badges',
            label: 'Badges',
            color: AppColors.accent),
        const SizedBox(width: AppSpacing.md),
        _MiniStat(
            icon: Icons.percent,
            value: '${accuracy.toStringAsFixed(0)}%',
            label: 'Accuracy',
            color: AppColors.success),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: AppText.headline(15, weight: FontWeight.bold)),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppText.body(10, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------- Achievement grid -------------------------

class _AchievementGrid extends StatelessWidget {
  final List<Achievement> achievements;
  final int unlockedCount;
  const _AchievementGrid({
    required this.achievements,
    required this.unlockedCount,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 0.75,
      children: List.generate(achievements.length, (i) {
        final badge = achievements[i];
        final isUnlocked = i < unlockedCount;
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isUnlocked ? badge.color.withValues(alpha: 0.08) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isUnlocked ? badge.color : AppColors.border,
              width: isUnlocked ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: isUnlocked ? 1 : 0.3,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: badge.color.withValues(alpha: 0.18),
                      ),
                      child: Icon(badge.icon, color: badge.color, size: 22),
                    ),
                  ),
                  if (!isUnlocked)
                    const Icon(Icons.lock, color: Colors.grey, size: 16),
                ],
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  badge.title,
                  style: AppText.body(10,
                      weight: FontWeight.w600,
                      color: isUnlocked
                          ? AppColors.textPrimary
                          : AppColors.textSecondary),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ------------------------- Reusable widgets -------------------------

class _Card extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  const _Card({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: AppText.headline(15, weight: FontWeight.bold)),
              ),
              if (subtitle != null)
                Text(subtitle!,
                    style: AppText.body(11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.body(14, weight: FontWeight.w600)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: AppText.body(11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  const _NavTile({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: Text(title,
                    style: AppText.body(14, weight: FontWeight.w600))),
            ?trailing,
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(height: 1, color: AppColors.border),
    );
  }
}

class _ActionRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _ActionButton(
                icon: Icons.share, label: 'Share', onTap: () => _snack(context, 'Share app'))),
        const SizedBox(width: AppSpacing.md),
        Expanded(
            child: _ActionButton(
                icon: Icons.star_rate, label: 'Rate us', onTap: () => _snack(context, 'Rate on Play Store'))),
      ],
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        elevation: 0,
      ),
    );
  }
}

// ------------------------- Data -------------------------

const List<String> kLanguages = [
  'English',
  'বাংলা',
  'हिन्दी',
  'Español',
  'Français',
  'Deutsch',
];