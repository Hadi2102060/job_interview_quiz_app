import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'quiz_screen.dart';

/// Persisted bookmarks of quiz topics the user wants to revisit.
class SavedQuizzesScreen extends StatefulWidget {
  const SavedQuizzesScreen({super.key});

  @override
  State<SavedQuizzesScreen> createState() => _SavedQuizzesScreenState();
}

class _SavedQuizzesScreenState extends State<SavedQuizzesScreen>
    with SingleTickerProviderStateMixin {
  static const _storageKey = 'saved_quiz_topics';

  late final AnimationController _anim;
  late final Animation<double> _fade;

  List<_SavedTopic> _items = [];
  String _query = '';
  String _filter = 'All';
  bool _loading = true;

  final _filters = const ['All', 'Flutter', 'Dart', 'Android', 'Behavioral', 'Other'];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _load();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    final parsed = <_SavedTopic>[];

    for (final entry in raw) {
      try {
        final map = jsonDecode(entry) as Map<String, dynamic>;
        parsed.add(_SavedTopic.fromMap(map));
      } catch (_) {}
    }

    // Seed a few samples on first visit so the screen feels alive.
    if (parsed.isEmpty) {
      parsed.addAll(_defaultSaved);
      await _persist(parsed);
    }

    if (!mounted) return;
    setState(() {
      _items = parsed;
      _loading = false;
    });
    _anim.forward();
  }

  Future<void> _persist(List<_SavedTopic> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      items.map((e) => jsonEncode(e.toMap())).toList(),
    );
  }

  List<_SavedTopic> get _visible {
    return _items.where((t) {
      final matchFilter =
          _filter == 'All' || t.category.toLowerCase() == _filter.toLowerCase();
      final q = _query.trim().toLowerCase();
      final matchQuery = q.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q);
      return matchFilter && matchQuery;
    }).toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  Future<void> _remove(String id) async {
    HapticFeedback.mediumImpact();
    setState(() => _items.removeWhere((e) => e.id == id));
    await _persist(_items);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed from saved', style: GoogleFonts.poppins()),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _togglePin(String id) async {
    HapticFeedback.selectionClick();
    setState(() {
      final i = _items.indexWhere((e) => e.id == id);
      if (i >= 0) {
        _items[i] = _items[i].copyWith(pinned: !_items[i].pinned);
      }
      _items.sort((a, b) {
        if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
        return b.savedAt.compareTo(a.savedAt);
      });
    });
    await _persist(_items);
  }

  void _openQuiz(_SavedTopic topic) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuizScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final pinnedCount = _items.where((e) => e.pinned).length;

    return Scaffold(
      backgroundColor: const Color(0xFFEAEEF6),
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              count: _items.length,
              pinned: pinnedCount,
              onBack: () => Navigator.pop(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _SearchField(
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = _filters[i];
                  final selected = f == _filter;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _filter = f);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF4F46E5)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        f,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : FadeTransition(
                      opacity: _fade,
                      child: visible.isEmpty
                          ? _EmptyState(
                              onExplore: () => Navigator.pop(context),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                              itemCount: visible.length,
                              itemBuilder: (_, i) {
                                final topic = visible[i];
                                return TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: 1),
                                  duration: Duration(
                                      milliseconds: 280 + (i * 40).clamp(0, 240)),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 16 * (1 - value)),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _SavedCard(
                                    topic: topic,
                                    onOpen: () => _openQuiz(topic),
                                    onRemove: () => _remove(topic.id),
                                    onPin: () => _togglePin(topic.id),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int count;
  final int pinned;
  final VoidCallback onBack;

  const _Header({
    required this.count,
    required this.pinned,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDDE7FF), Color(0xFFF8FAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: const Color(0xFF0F172A),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved Quizzes',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '$count saved · $pinned pinned',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.bookmark_rounded,
                color: Color(0xFF4F46E5), size: 22),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search saved quizzes…',
          hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8)),
          prefixIcon:
              const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  final _SavedTopic topic;
  final VoidCallback onOpen;
  final VoidCallback onRemove;
  final VoidCallback onPin;

  const _SavedCard({
    required this.topic,
    required this.onOpen,
    required this.onRemove,
    required this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: topic.pinned
                    ? const Color(0xFF4F46E5).withValues(alpha: 0.35)
                    : const Color(0xFFE2E8F0),
              ),
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
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: topic.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(topic.icon, color: topic.color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  topic.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              if (topic.pinned) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.push_pin_rounded,
                                    size: 14, color: Color(0xFF4F46E5)),
                              ],
                            ],
                          ),
                          Text(
                            topic.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Chip(label: topic.category, color: topic.color),
                    const SizedBox(width: 8),
                    _Chip(
                      label: topic.difficulty,
                      color: const Color(0xFF64748B),
                    ),
                    const Spacer(),
                    Text(
                      '${topic.questionCount} Qs',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onOpen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: Text(
                          'Continue',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _IconAction(
                      icon: topic.pinned
                          ? Icons.push_pin_rounded
                          : Icons.push_pin_outlined,
                      color: const Color(0xFF4F46E5),
                      onTap: onPin,
                    ),
                    const SizedBox(width: 6),
                    _IconAction(
                      icon: Icons.delete_outline_rounded,
                      color: const Color(0xFFEF4444),
                      onTap: onRemove,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onExplore;
  const _EmptyState({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark_border_rounded,
                  size: 48, color: Color(0xFF4F46E5)),
            ),
            const SizedBox(height: 18),
            Text(
              'No saved quizzes yet',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bookmark topics from Home to revisit them here anytime.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF64748B),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onExplore,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text('Explore topics',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedTopic {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final int questionCount;
  final IconData icon;
  final Color color;
  final DateTime savedAt;
  final bool pinned;

  const _SavedTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.questionCount,
    required this.icon,
    required this.color,
    required this.savedAt,
    this.pinned = false,
  });

  _SavedTopic copyWith({bool? pinned}) => _SavedTopic(
        id: id,
        title: title,
        description: description,
        category: category,
        difficulty: difficulty,
        questionCount: questionCount,
        icon: icon,
        color: color,
        savedAt: savedAt,
        pinned: pinned ?? this.pinned,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'difficulty': difficulty,
        'questionCount': questionCount,
        'iconKey': _iconKeyFor(icon),
        'color': color.toARGB32(),
        'savedAt': savedAt.toIso8601String(),
        'pinned': pinned,
      };

  factory _SavedTopic.fromMap(Map<String, dynamic> map) {
    return _SavedTopic(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Other',
      difficulty: map['difficulty'] as String? ?? 'Beginner',
      questionCount: map['questionCount'] as int? ?? 10,
      icon: _iconFromKey(map['iconKey'] as String?),
      color: Color(map['color'] as int? ?? 0xFF4F46E5),
      savedAt: DateTime.tryParse(map['savedAt'] as String? ?? '') ??
          DateTime.now(),
      pinned: map['pinned'] as bool? ?? false,
    );
  }
}

String _iconKeyFor(IconData icon) {
  if (icon == Icons.flutter_dash) return 'flutter';
  if (icon == Icons.people_alt_rounded) return 'people';
  if (icon == Icons.code_rounded) return 'code';
  if (icon == Icons.animation) return 'animation';
  if (icon == Icons.account_tree) return 'tree';
  return 'quiz';
}

IconData _iconFromKey(String? key) {
  switch (key) {
    case 'flutter':
      return Icons.flutter_dash;
    case 'people':
      return Icons.people_alt_rounded;
    case 'code':
      return Icons.code_rounded;
    case 'animation':
      return Icons.animation;
    case 'tree':
      return Icons.account_tree;
    default:
      return Icons.quiz_rounded;
  }
}

final _defaultSaved = [
  _SavedTopic(
    id: 'flutter_basics',
    title: 'Flutter Basics',
    description: 'Widgets, State Management, Lifecycle',
    category: 'Flutter',
    difficulty: 'Beginner',
    questionCount: 25,
    icon: Icons.flutter_dash,
    color: Colors.blue,
    savedAt: DateTime.now().subtract(const Duration(hours: 3)),
    pinned: true,
  ),
  _SavedTopic(
    id: 'hr_interview',
    title: 'HR Interview',
    description: 'Behavioral questions & soft skills',
    category: 'Behavioral',
    difficulty: 'Intermediate',
    questionCount: 20,
    icon: Icons.people_alt_rounded,
    color: Colors.orange,
    savedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  _SavedTopic(
    id: 'dart_prog',
    title: 'Dart Programming',
    description: 'OOP, Async, Null Safety',
    category: 'Dart',
    difficulty: 'Intermediate',
    questionCount: 22,
    icon: Icons.code_rounded,
    color: Colors.teal,
    savedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];
