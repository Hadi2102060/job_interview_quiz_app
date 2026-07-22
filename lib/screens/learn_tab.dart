import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/category_data.dart';
import '../core/theme.dart';
import '../state/app_state.dart';

/// Learn tab — a content hub with topic filters, lesson cards,
/// an interactive flashcard, and a small bookmark list.
class LearnTab extends StatefulWidget {
  const LearnTab({super.key});
  @override
  State<LearnTab> createState() => _LearnTabState();
}

class _Lesson {
  final String title;
  final String meta;
  final String summary;
  final String tag;
  const _Lesson(this.title, this.meta, this.summary, this.tag);
}

class _LearnTabState extends State<LearnTab> {
  String _filter = 'All';

  final Map<String, List<_Lesson>> _lessons = const {
    'flutter_basics': [
      _Lesson('Widgets 101', '15 min • Theory', 'StatelessWidget, StatefulWidget, and the widget tree.', 'Dart'),
      _Lesson('Layouts in Flutter', '20 min • Practical', 'Container, Row, Column, Stack — composition patterns.', 'Dart'),
    ],
    'flutter_advanced': [
      _Lesson('Custom Painting', '18 min • Theory', 'CustomPainter, Canvas, GestureDetector.', 'Dart'),
      _Lesson('Animation Controllers', '22 min • Practical', 'Tween, CurvedAnimation, Hero transitions.', 'Dart'),
    ],
    'state_mgmt': [
      _Lesson('Provider vs Bloc', '12 min • Theory', 'When to choose which pattern.', 'Dart'),
      _Lesson('GetX Patterns', '15 min • Practical', 'Reactive state, navigation, dependency injection.', 'Dart'),
    ],
    'dart_prog': [
      _Lesson('Null Safety', '10 min • Theory', 'Sound null safety in modern Dart.', 'Dart'),
      _Lesson('Async Patterns', '14 min • Practical', 'Futures, Streams, isolates.', 'Dart'),
    ],
    'system_design': [
      _Lesson('Caching Strategies', '18 min • Theory', 'LRU, write-through, write-behind.', 'Concept'),
      _Lesson('Load Balancing', '12 min • Practical', 'Round-robin vs consistent hashing.', 'Concept'),
    ],
    'hr_interview': [
      _Lesson('STAR Answers', '10 min • Theory', 'Structure behavioral answers with Situation, Task, Action, Result.', 'Soft Skill'),
    ],
  };

  List<_Lesson> get _visibleLessons {
    if (_filter == 'All') {
      return _lessons.values.expand((e) => e).toList();
    }
    final cat = kAllCategories
        .where((c) => c.category == _filter)
        .map((c) => c.id)
        .toSet();
    return _lessons.entries
        .where((e) => cat.contains(e.key))
        .expand((e) => e.value)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final categories = _filter == 'All'
        ? kAllCategories
        : kAllCategories.where((c) => c.category == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _LearnHeader(streak: state.streakDays, level: state.level)),
            SliverToBoxAdapter(child: _FilterChips(
              current: _filter,
              onChanged: (v) => setState(() => _filter = v),
            )),
            const SliverToBoxAdapter(child: _FlashcardOfTheDayPlaceholder()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                child: Text(
                  'Topics',
                  style: AppText.headline(18, weight: FontWeight.w600),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, i) {
                    final c = categories[i];
                    final acc = state.accuracyByCategory[c.id] ?? 0.0;
                    return _TopicRing(category: c, accuracy: acc);
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 100),
              sliver: SliverList.separated(
                itemCount: _visibleLessons.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, i) =>
                    _LessonCard(lesson: _visibleLessons[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------- Header -------------------------

class _LearnHeader extends StatelessWidget {
  final int streak;
  final String level;
  const _LearnHeader({required this.streak, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppGradients.header,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learn',
                  style: AppText.headline(22, weight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bite-sized lessons, deep concepts.',
                  style: AppText.body(13, color: Colors.white70),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _PillStat(icon: Icons.local_fire_department, label: '$streak day streak', color: const Color(0xFFFFB74D)),
                    _PillStat(icon: Icons.bolt, label: level, color: const Color(0xFF80DEEA)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.menu_book_rounded, size: 44, color: Colors.white24),
        ],
      ),
    );
  }
}

class _PillStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _PillStat({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: AppText.body(12, weight: FontWeight.w600, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------- Filters -------------------------

class _FilterChips extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;
  const _FilterChips({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: kCategoryFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = kCategoryFilters[i];
          final selected = f == current;
          return ChoiceChip(
            label: Text(f),
            selected: selected,
            onSelected: (_) => onChanged(f),
            labelStyle: AppText.body(13,
                weight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textSecondary),
            selectedColor: AppColors.primary.withValues(alpha: 0.12),
            backgroundColor: Colors.white,
            side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}

// ------------------------- Flashcard -------------------------

class _FlashcardOfTheDayPlaceholder extends StatelessWidget {
  const _FlashcardOfTheDayPlaceholder();
  @override
  Widget build(BuildContext context) => _FlashcardOfTheDay();
}

class _FlashcardOfTheDay extends StatefulWidget {
  @override
  State<_FlashcardOfTheDay> createState() => _FlashcardOfTheDayState();
}

class _FlashcardOfTheDayState extends State<_FlashcardOfTheDay>
    with SingleTickerProviderStateMixin {
  bool _flipped = false;
  late final AnimationController _ctrl;
  late final Animation<double> _turn;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _turn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _flip() {
    HapticFeedback.lightImpact();
    setState(() => _flipped = !_flipped);
    _flipped ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.style, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Flashcard of the day',
                  style: AppText.headline(14, weight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  _flipped ? 'Tap to hide' : 'Tap to flip',
                  style: AppText.body(11, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AnimatedBuilder(
              animation: _turn,
              builder: (context, _) {
                final angle = _turn.value * 3.1416;
                final showBack = angle > 1.57;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015)
                    ..rotateY(angle),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: showBack
                          ? AppColors.success.withValues(alpha: 0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: showBack ? AppColors.success : AppColors.primary,
                      ),
                    ),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: showBack
                          ? (Matrix4.identity()..rotateY(3.1416))
                          : Matrix4.identity(),
                      child: Text(
                        showBack
                            ? 'A widget that listens to a state and rebuilds when it changes.'
                            : 'Q: What is a StatefulWidget in Flutter?',
                        style: AppText.body(14,
                            weight: FontWeight.w500,
                            color: showBack ? AppColors.success : AppColors.textPrimary),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------- Topic Ring -------------------------

class _TopicRing extends StatelessWidget {
  final CategoryMeta category;
  final double accuracy;
  const _TopicRing({required this.category, required this.accuracy});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: accuracy.clamp(0.0, 1.0),
                    strokeWidth: 5,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(category.color),
                  ),
                ),
                Icon(category.icon, color: category.color, size: 22),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppText.body(12, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ------------------------- Lesson Card -------------------------

class _LessonCard extends StatefulWidget {
  final _Lesson lesson;
  const _LessonCard({required this.lesson});

  @override
  State<_LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<_LessonCard> {
  bool _expanded = false;
  bool _bookmarked = false;
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    final l = widget.lesson;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: AppDuration.medium,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: _completed ? AppColors.success : AppColors.border, width: _completed ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.play_circle_outline, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.title, style: AppText.headline(15, weight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(l.meta, style: AppText.body(12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(_bookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: _bookmarked ? AppColors.primary : AppColors.textSecondary),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => _bookmarked = !_bookmarked);
                    },
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textSecondary),
                ],
              ),
              AnimatedCrossFade(
                duration: AppDuration.medium,
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.summary, style: AppText.body(14, color: AppColors.textPrimary).copyWith(height: 1.5)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(l.tag, style: AppText.body(11, weight: FontWeight.w600, color: AppColors.textSecondary)),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            icon: Icon(_completed ? Icons.check_circle : Icons.check_circle_outline,
                                color: _completed ? AppColors.success : AppColors.primary, size: 18),
                            label: Text(_completed ? 'Done' : 'Mark done'),
                            onPressed: () => setState(() => _completed = !_completed),
                          ),
                        ],
                      ),
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
}