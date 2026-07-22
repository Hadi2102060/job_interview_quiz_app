import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Interactive interview tips library with expand/collapse, favorites, and progress.
class InterviewTipsScreen extends StatefulWidget {
  const InterviewTipsScreen({super.key});

  @override
  State<InterviewTipsScreen> createState() => _InterviewTipsScreenState();
}

class _InterviewTipsScreenState extends State<InterviewTipsScreen> {
  static const _favKey = 'favorite_tip_ids';
  static const _readKey = 'read_tip_ids';

  final Set<String> _favorites = {};
  final Set<String> _read = {};
  String _query = '';
  String _category = 'All';
  String? _expandedId;

  final _categories = const [
    'All',
    'Before',
    'During',
    'Technical',
    'Behavioral',
    'After',
  ];

  @override
  void initState() {
    super.initState();
    _loadMeta();
  }

  Future<void> _loadMeta() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList(_favKey) ?? [];
    final reads = prefs.getStringList(_readKey) ?? [];
    if (!mounted) return;
    setState(() {
      _favorites.addAll(favs);
      _read.addAll(reads);
    });
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favKey, _favorites.toList());
    await prefs.setStringList(_readKey, _read.toList());
  }

  List<_Tip> get _visible {
    return _kTips.where((t) {
      final matchCat = _category == 'All' || t.category == _category;
      final q = _query.trim().toLowerCase();
      final matchQ = q.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          t.summary.toLowerCase().contains(q) ||
          t.body.toLowerCase().contains(q);
      return matchCat && matchQ;
    }).toList();
  }

  void _toggleExpand(_Tip tip) {
    HapticFeedback.selectionClick();
    setState(() {
      _expandedId = _expandedId == tip.id ? null : tip.id;
      if (_expandedId == tip.id) {
        _read.add(tip.id);
      }
    });
    _persist();
  }

  void _toggleFavorite(String id) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
    });
    _persist();
  }

  double get _progress {
    if (_kTips.isEmpty) return 0;
    return _read.length / _kTips.length;
  }

  @override
  Widget build(BuildContext context) {
    final tips = _visible;
    final favCount = _favorites.length;

    return Scaffold(
      backgroundColor: const Color(0xFFEAEEF6),
      body: SafeArea(
        child: Column(
          children: [
            _TipsHeader(
              progress: _progress,
              readCount: _read.length,
              total: _kTips.length,
              favCount: favCount,
              onBack: () => Navigator.pop(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search tips…',
                    hintStyle:
                        GoogleFonts.poppins(color: const Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Color(0xFF64748B)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final c = _categories[i];
                  final selected = c == _category;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _category = c);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                              )
                            : null,
                        color: selected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: selected
                              ? Colors.transparent
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        c,
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
            const SizedBox(height: 8),
            Expanded(
              child: tips.isEmpty
                  ? Center(
                      child: Text(
                        'No tips match your search',
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF64748B)),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                      itemCount: tips.length,
                      itemBuilder: (_, i) {
                        final tip = tips[i];
                        return _TipCard(
                          tip: tip,
                          expanded: _expandedId == tip.id,
                          isFavorite: _favorites.contains(tip.id),
                          isRead: _read.contains(tip.id),
                          onTap: () => _toggleExpand(tip),
                          onFavorite: () => _toggleFavorite(tip.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipsHeader extends StatelessWidget {
  final double progress;
  final int readCount;
  final int total;
  final int favCount;
  final VoidCallback onBack;

  const _TipsHeader({
    required this.progress,
    required this.readCount,
    required this.total,
    required this.favCount,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF3D6), Color(0xFFFFFBF0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
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
                      'Interview Tips',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Master every round with proven advice',
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
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.lightbulb_rounded,
                    color: Color(0xFFF59E0B), size: 22),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Reading progress',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$readCount / $total',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: const Color(0xFFFEF3C7),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFF59E0B)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.favorite_rounded,
                        size: 16, color: Colors.red.shade400),
                    const SizedBox(width: 6),
                    Text(
                      '$favCount favorites',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(progress * 100).round()}% complete',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
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

class _TipCard extends StatelessWidget {
  final _Tip tip;
  final bool expanded;
  final bool isFavorite;
  final bool isRead;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const _TipCard({
    required this.tip,
    required this.expanded,
    required this.isFavorite,
    required this.isRead,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: expanded
                ? tip.color.withValues(alpha: 0.45)
                : const Color(0xFFE2E8F0),
            width: expanded ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: tip.color.withValues(alpha: expanded ? 0.14 : 0.06),
              blurRadius: expanded ? 18 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: tip.color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(tip.icon, color: tip.color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: tip.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    tip.category,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: tip.color,
                                    ),
                                  ),
                                ),
                                if (isRead) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.check_circle,
                                      size: 14, color: Color(0xFF22C55E)),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              tip.title,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tip.summary,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onFavorite,
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: tip.color.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              tip.body,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                height: 1.55,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ),
                          if (tip.checklist.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Quick checklist',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...tip.checklist.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.check_circle_outline,
                                        size: 16, color: tip.color),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.5,
                                          color: const Color(0xFF475569),
                                          height: 1.4,
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
                    crossFadeState: expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 260),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        expanded ? 'Tap to collapse' : 'Tap to expand',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      Icon(
                        expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tip {
  final String id;
  final String title;
  final String summary;
  final String body;
  final String category;
  final IconData icon;
  final Color color;
  final List<String> checklist;

  const _Tip({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.category,
    required this.icon,
    required this.color,
    this.checklist = const [],
  });
}

const _kTips = <_Tip>[
  _Tip(
    id: 'prep_research',
    title: 'Research the company deeply',
    summary: 'Know their product, culture, and recent news before you walk in.',
    body:
        'Spend 30–45 minutes reviewing the company’s website, LinkedIn, Glassdoor, and last two product launches. Prepare one thoughtful question about a recent initiative — interviewers remember candidates who did real homework.',
    category: 'Before',
    icon: Icons.travel_explore_rounded,
    color: Color(0xFF2563EB),
    checklist: [
      'Read “About” and latest blog posts',
      'Note 2–3 competitors and differentiators',
      'Prepare one insight to share in the intro',
    ],
  ),
  _Tip(
    id: 'prep_star',
    title: 'Practice STAR stories',
    summary: 'Structure behavioral answers: Situation, Task, Action, Result.',
    body:
        'Write 5 stories covering conflict, failure, leadership, ownership, and impact. Keep each under 90 seconds. Quantify results (time saved, revenue, users) whenever possible.',
    category: 'Before',
    icon: Icons.auto_stories_rounded,
    color: Color(0xFF7C3AED),
    checklist: [
      'Draft 5 STAR stories',
      'Add metrics to every Result',
      'Rehearse out loud once',
    ],
  ),
  _Tip(
    id: 'during_listen',
    title: 'Listen fully before answering',
    summary: 'Pause 2 seconds. Clarify. Then answer with structure.',
    body:
        'Rushing signals nerves. A short pause shows composure. If a question is vague, restate it: “Just to confirm, you’re asking about…” Then deliver a crisp, structured answer.',
    category: 'During',
    icon: Icons.hearing_rounded,
    color: Color(0xFF059669),
    checklist: [
      'Pause before speaking',
      'Clarify ambiguous questions',
      'Keep answers under 2 minutes',
    ],
  ),
  _Tip(
    id: 'during_energy',
    title: 'Match energy & eye contact',
    summary: 'Warmth + confidence beats perfect wording.',
    body:
        'Smile when greeting, sit upright, and keep natural eye contact. On video calls, look at the camera when speaking. Energy is contagious — interviewers hire people they enjoy talking to.',
    category: 'During',
    icon: Icons.sentiment_satisfied_alt_rounded,
    color: Color(0xFFEA580C),
  ),
  _Tip(
    id: 'tech_think_aloud',
    title: 'Think out loud in coding rounds',
    summary: 'Show how you reason — not just the final code.',
    body:
        'Clarify constraints, propose a brute-force approach, then optimize. Mention time/space complexity. If stuck, narrate what you would try next. Interviewers grade process as much as correctness.',
    category: 'Technical',
    icon: Icons.code_rounded,
    color: Color(0xFF0EA5E9),
    checklist: [
      'Restate the problem',
      'Discuss brute force first',
      'State Big-O of your solution',
    ],
  ),
  _Tip(
    id: 'tech_tradeoffs',
    title: 'Discuss trade-offs clearly',
    summary: 'Senior signal: you know when “perfect” isn’t worth it.',
    body:
        'For system design and Flutter architecture questions, compare 2 options (e.g. Bloc vs Riverpod, REST vs GraphQL) and pick one with a clear reason tied to team size, latency, or maintainability.',
    category: 'Technical',
    icon: Icons.balance_rounded,
    color: Color(0xFF4F46E5),
  ),
  _Tip(
    id: 'behav_conflict',
    title: 'Own conflict without blaming',
    summary: 'Focus on what you did to resolve tension.',
    body:
        'Never trash a teammate. Frame conflict as misaligned goals. Explain how you listened, proposed a compromise, and what you learned. Empathy + ownership is the winning combo.',
    category: 'Behavioral',
    icon: Icons.handshake_rounded,
    color: Color(0xFFDB2777),
  ),
  _Tip(
    id: 'behav_fail',
    title: 'Turn failure into growth',
    summary: 'Show reflection, not perfection.',
    body:
        'Pick a real failure with a clear recovery. Cover: what went wrong, what you owned, the fix, and the lasting process change. Interviewers trust candidates who learn in public.',
    category: 'Behavioral',
    icon: Icons.trending_up_rounded,
    color: Color(0xFF16A34A),
  ),
  _Tip(
    id: 'after_thanks',
    title: 'Send a sharp thank-you note',
    summary: 'Within 24 hours — short, specific, human.',
    body:
        'Reference one topic you discussed and restate why you’re excited. Avoid generic templates. One thoughtful paragraph beats a long essay.',
    category: 'After',
    icon: Icons.mail_outline_rounded,
    color: Color(0xFF6366F1),
    checklist: [
      'Send within 24 hours',
      'Mention one specific discussion point',
      'Reaffirm interest in the role',
    ],
  ),
  _Tip(
    id: 'after_reflect',
    title: 'Debrief every interview',
    summary: 'Write what went well and what to improve next time.',
    body:
        'Right after the call, jot down tough questions and your answers. This builds a personal question bank and reduces anxiety for the next round.',
    category: 'After',
    icon: Icons.edit_note_rounded,
    color: Color(0xFF0891B2),
  ),
];
