import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';

/// Ranks (Leaderboard) tab — global/weekly toggle, podium, ranked list,
/// search and a "Your rank" highlight card.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _search = TextEditingController();
  String _query = '';

  static const List<_Player> _players = [
    _Player('Aarav Sharma', 'aarav', 4820, 124, 4.9, '🇮🇳', true),
    _Player('Sofia Martínez', 'sofia', 4610, 118, 4.8, '🇪🇸', false),
    _Player('Liam O\'Connor', 'liam', 4490, 112, 4.7, '🇮🇪', false),
    _Player('Mei Tanaka', 'mei', 4220, 108, 4.7, '🇯🇵', false),
    _Player('Noah Kim', 'noah', 3980, 102, 4.6, '🇰🇷', false),
    _Player('Aisha Khan', 'aisha', 3850, 98, 4.6, '🇵🇰', false),
    _Player('Lucas Silva', 'lucas', 3720, 94, 4.5, '🇧🇷', false),
    _Player('Emma Becker', 'emma', 3540, 91, 4.5, '🇩🇪', false),
    _Player('Yusuf Demir', 'yusuf', 3380, 87, 4.4, '🇹🇷', false),
    _Player('Hadi Rahman', 'hadi', 3260, 84, 4.4, '🇧🇩', false), // you
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _search.dispose();
    super.dispose();
  }

  List<_Player> get _filtered {
    final list = _players.where((p) {
      if (_query.isEmpty) return true;
      return p.name.toLowerCase().contains(_query.toLowerCase()) ||
          p.handle.toLowerCase().contains(_query.toLowerCase());
    }).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              title: 'Ranks',
              subtitle: 'Compete with learners worldwide',
              tabController: _tabController,
            ),
            const SizedBox(height: AppSpacing.md),
            _SearchBar(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _RankList(players: _filtered, scope: 'All-time'),
                  _RankList(players: _filtered.reversed.toList(), scope: 'This week'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------- Header -------------------------

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final TabController tabController;
  const _Header({
    required this.title,
    required this.subtitle,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppGradients.header,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppText.headline(22, weight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppText.body(13, color: Colors.white70)),
                  ],
                ),
              ),
              const Icon(Icons.emoji_events_rounded, color: Colors.white24, size: 56),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.white70,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: AppText.body(13, weight: FontWeight.w600),
              tabs: const [
                Tab(text: 'All-time'),
                Tab(text: 'Weekly'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------- Search -------------------------

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
            hintText: 'Search players',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
        ),
      ),
    );
  }
}

// ------------------------- Rank list -------------------------

class _RankList extends StatelessWidget {
  final List<_Player> players;
  final String scope;
  const _RankList({required this.players, required this.scope});

  @override
  Widget build(BuildContext context) {
    final top3 = players.take(3).toList();
    final rest = players.skip(3).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
      children: [
        if (top3.length >= 3) _Podium(top3: top3, scope: scope),
        const SizedBox(height: AppSpacing.lg),
        _YourRankCard(player: players.firstWhere((p) => p.isYou, orElse: () => players.first)),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(rest.length, (i) {
          final rank = i + 4; // 1,2,3 on podium; rest starts at 4
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _RankTile(rank: rank, player: rest[i]),
          );
        }),
      ],
    );
  }
}

// ------------------------- Podium -------------------------

class _Podium extends StatelessWidget {
  final List<_Player> top3;
  final String scope;
  const _Podium({required this.top3, required this.scope});

  @override
  Widget build(BuildContext context) {
    final first = top3[0];
    final second = top3[1];
    final third = top3[2];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('$scope top 3',
            style: AppText.body(12, color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 260,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                  child: _PodiumColumn(
                      player: second,
                      height: 110,
                      color: const Color(0xFFB0BEC5),
                      rank: 2)),
              Expanded(
                  child: _PodiumColumn(
                      player: first,
                      height: 150,
                      color: const Color(0xFFFFC107),
                      rank: 1)),
              Expanded(
                  child: _PodiumColumn(
                      player: third,
                      height: 90,
                      color: const Color(0xFFB87333),
                      rank: 3)),
            ],
          ),
        ),
      ],
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final _Player player;
  final double height;
  final Color color;
  final int rank;
  const _PodiumColumn({
    required this.player,
    required this.height,
    required this.color,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Avatar(letter: player.initial, size: 36, color: color),
          const SizedBox(height: 2),
          Text(
            player.handle,
            style: AppText.body(11, weight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${player.xp}',
            style: AppText.body(10, color: AppColors.textSecondary),
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withValues(alpha: 0.85), color.withValues(alpha: 0.55)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '$rank',
              style: AppText.headline(20, weight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------- Your rank card -------------------------

class _YourRankCard extends StatelessWidget {
  final _Player player;
  const _YourRankCard({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppGradients.dailyChallenge,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          _Avatar(letter: player.initial, size: 44, color: Colors.white),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You',
                    style: AppText.body(11, color: Colors.white70)),
                Text(
                  player.name,
                  style: AppText.headline(15, weight: FontWeight.bold, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${player.xp} XP • Lv ${player.level}',
                  style: AppText.body(12, color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share your rank — coming soon')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              minimumSize: const Size(64, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Share', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ------------------------- Rank tile -------------------------

class _RankTile extends StatelessWidget {
  final int rank;
  final _Player player;
  const _RankTile({required this.rank, required this.player});

  @override
  Widget build(BuildContext context) {
    final topTier = rank <= 3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: player.isYou ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: player.isYou ? AppColors.primary : AppColors.border,
          width: player.isYou ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: AppText.headline(13,
                  weight: FontWeight.bold,
                  color: topTier ? AppColors.primary : AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 6),
          _Avatar(letter: player.initial, size: 36, color: _colorFor(rank)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        player.name,
                        style: AppText.headline(13, weight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(player.flag, style: const TextStyle(fontSize: 13)),
                  ],
                ),
                Text(
                  'Lv ${player.level} • ${player.handle}',
                  style: AppText.body(11, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${player.xp}',
                style: AppText.headline(13, weight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text('XP', style: AppText.body(10, color: AppColors.textSecondary)),
            ],
          ),
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 18,
              icon: const Icon(Icons.sports_kabaddi),
              color: AppColors.primary,
              tooltip: 'Cheer',
              onPressed: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cheered ${player.handle}!'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFC107);
      case 2:
        return const Color(0xFFB0BEC5);
      case 3:
        return const Color(0xFFB87333);
      default:
        return AppColors.primary;
    }
  }
}

// ------------------------- Avatar -------------------------

class _Avatar extends StatelessWidget {
  final String letter;
  final double size;
  final Color color;
  const _Avatar({required this.letter, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: AppText.headline(size > 44 ? 18 : 14,
            weight: FontWeight.bold, color: color),
      ),
    );
  }
}

// ------------------------- Player model -------------------------

class _Player {
  final String name;
  final String handle;
  final int xp;
  final int level;
  final double accuracy;
  final String flag;
  final bool isYou;
  const _Player(this.name, this.handle, this.xp, this.level, this.accuracy, this.flag, this.isYou);

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
}