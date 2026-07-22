import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/topic_progress_bar.dart';

/// Stats tab — overview cards, charts, topic performance and recent attempts.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final accuracy = state.accuracyByCategory.values.fold<double>(0, (a, b) => a + b) /
        state.accuracyByCategory.values.length;
    final sortedEntries = state.accuracyByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final strongest = sortedEntries.isNotEmpty ? sortedEntries.first : null;
    final weakest = sortedEntries.length > 1 ? sortedEntries.last : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
          children: [
            _Header(streak: state.streakDays),
            const SizedBox(height: AppSpacing.md),
            _SummaryGrid(state: state, accuracy: accuracy),
            const SizedBox(height: AppSpacing.lg),
            _WeeklyXpCard(weekly: state.weeklyXp),
            const SizedBox(height: AppSpacing.lg),
            _CategoryBarCard(state: state),
            const SizedBox(height: AppSpacing.lg),
            if (strongest != null)
              _InsightCard(
                title: 'Strongest topic',
                icon: Icons.trending_up,
                color: AppColors.success,
                categoryId: strongest.key,
                value: strongest.value,
              ),
            if (weakest != null) ...[
              const SizedBox(height: AppSpacing.md),
              _InsightCard(
                title: 'Needs practice',
                icon: Icons.trending_down,
                color: AppColors.error,
                categoryId: weakest.key,
                value: weakest.value,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text('Recent activity',
                style: AppText.headline(18, weight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.md),
            ...state.recentAttempts
                .map((a) => _AttemptTile(attempt: a))
                ,
          ],
        ),
      ),
    );
  }
}

// ------------------------- Header -------------------------

class _Header extends StatelessWidget {
  final int streak;
  const _Header({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Stats',
                  style: AppText.headline(24, weight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('$streak day streak — keep going',
                  style: AppText.body(13, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: AppGradients.dailyChallenge,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.local_fire_department, color: Colors.white, size: 24),
        ),
      ],
    );
  }
}

// ------------------------- Summary -------------------------

class _SummaryGrid extends StatelessWidget {
  final AppState state;
  final double accuracy;
  const _SummaryGrid({required this.state, required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _SummaryTile(
        label: 'Quizzes',
        value: '${state.quizzesTaken}',
        icon: Icons.quiz_rounded,
        color: AppColors.primary,
      ),
      _SummaryTile(
        label: 'Avg. accuracy',
        value: '${(accuracy * 100).round()}%',
        icon: Icons.gps_fixed,
        color: AppColors.success,
      ),
      _SummaryTile(
        label: 'Total XP',
        value: '${state.xp}',
        icon: Icons.bolt,
        color: const Color(0xFFFFA726),
      ),
      _SummaryTile(
        label: 'Badges',
        value: '${state.badges}',
        icon: Icons.workspace_premium,
        color: const Color(0xFFEC407A),
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.15,
      children: tiles,
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppText.headline(18, weight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: AppText.body(11, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ------------------------- Weekly XP chart -------------------------

class _WeeklyXpCard extends StatelessWidget {
  final List<double> weekly;
  const _WeeklyXpCard({required this.weekly});

  @override
  Widget build(BuildContext context) {
    final maxY = weekly.fold<double>(0, (a, b) => a > b ? a : b) * 1.2;
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return _Card(
      title: 'Weekly XP',
      subtitle: 'XP earned this week',
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY == 0 ? 100 : maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY == 0 ? 25 : maxY / 4,
              getDrawingHorizontalLine: (_) => FlLine(
                color: AppColors.border,
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: maxY == 0 ? 25 : maxY / 4,
                  getTitlesWidget: (v, _) => Text(
                    v.toInt().toString(),
                    style: AppText.body(10, color: AppColors.textMuted),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: 1,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= days.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(days[i],
                          style: AppText.body(11, color: AppColors.textSecondary)),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (var i = 0; i < weekly.length; i++)
                    FlSpot(i.toDouble(), weekly[i]),
                ],
                isCurved: true,
                curveSmoothness: 0.3,
                gradient: AppGradients.header,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: AppColors.primary,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.30),
                      AppColors.primary.withValues(alpha: 0.0),
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

// ------------------------- Category Bar Chart -------------------------

class _CategoryBarCard extends StatelessWidget {
  final AppState state;
  const _CategoryBarCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final entries = state.accuracyByCategory.entries.toList();
    final maxY = entries.fold<double>(0, (a, b) => a > b.value ? a : b.value);
    return _Card(
      title: 'Accuracy by category',
      subtitle: 'Performance breakdown',
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            maxY: 1.0,
            minY: 0,
            alignment: BarChartAlignment.spaceAround,
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 0.25,
              getDrawingHorizontalLine: (_) => FlLine(
                color: AppColors.border,
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 0.25,
                  getTitlesWidget: (v, _) => Text(
                    '${(v * 100).round()}%',
                    style: AppText.body(10, color: AppColors.textMuted),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                    final id = entries[i].key;
                    final cat = state.findCategory(id);
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        cat?.title.split(' ').first ?? id,
                        style: AppText.body(9, color: AppColors.textSecondary),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < entries.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: entries[i].value,
                      width: 12,
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          (state.findCategory(entries[i].key)?.color ?? AppColors.primary)
                              .withValues(alpha: 0.6),
                          state.findCategory(entries[i].key)?.color ?? AppColors.primary,
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------- Insight Card -------------------------

class _InsightCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String categoryId;
  final double value;
  const _InsightCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.categoryId,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cat = context.read<AppState>().findCategory(categoryId);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.body(12, color: AppColors.textSecondary)),
                Text(
                  cat?.title ?? categoryId,
                  style: AppText.headline(16, weight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 72,
            child: TopicProgressBar(
              topic: '',
              value: value,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------- Recent attempts -------------------------

class _AttemptTile extends StatelessWidget {
  final dynamic attempt; // QuizAttempt
  const _AttemptTile({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final cat = context.read<AppState>().findCategory(attempt.categoryId);
    final color = cat?.color ?? AppColors.primary;
    final pct = attempt.percent.round();
    final good = pct >= 60;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(cat?.icon ?? Icons.quiz, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat?.title ?? attempt.categoryId,
                    style: AppText.headline(14, weight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('${attempt.score}/${attempt.total} • +${attempt.xpEarned} XP',
                    style: AppText.body(12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (good ? AppColors.success : AppColors.error).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$pct%',
              style: AppText.body(12,
                  weight: FontWeight.bold, color: good ? AppColors.success : AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------- Card wrapper -------------------------

class _Card extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _Card({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.headline(15, weight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(subtitle, style: AppText.body(12, color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}