import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/vibe_phrases.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/receipt_model.dart';
import '../../data/services/image_export_service.dart';
import '../../providers/history_provider.dart';
import '../../providers/receipt_theme_provider.dart';
import '../widgets/receipt_widget.dart';
import '../widgets/story_frame_widget.dart';

// ─── 메인 히스토리 화면 (탭 3개) ─────────────────────────────────────

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            '내 영수증 아카이브',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: TabBar(
            labelStyle: GoogleFonts.notoSansKr(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.notoSansKr(fontSize: 13),
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.secondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            tabs: const [
              Tab(text: '시간순'),
              Tab(text: '장소별'),
              Tab(text: '컬렉션'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TimelineTab(history: history, ref: ref),
            _PlaceTab(history: history),
            _CollectionTab(history: history),
          ],
        ),
      ),
    );
  }
}

// ─── 탭 1: 시간순 ────────────────────────────────────────────────────

class _TimelineTab extends StatelessWidget {
  final List<ReceiptModel> history;
  final WidgetRef ref;

  const _TimelineTab({required this.history, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return _emptyState();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      separatorBuilder: (_, i) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final receipt = history[index];
        return _HistoryCard(
          receipt: receipt,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => HistoryDetailScreen(receipt: receipt),
            ),
          ),
          onDelete: () => _confirmDelete(context, ref, receipt.receiptNumber),
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, String receiptNumber) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('영수증 삭제',
            style: GoogleFonts.notoSansKr(fontWeight: FontWeight.w700)),
        content:
            Text('이 영수증을 삭제할까요?', style: GoogleFonts.notoSansKr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              ref.read(historyProvider.notifier).remove(receiptNumber);
              Navigator.of(context).pop();
            },
            child:
                Text('삭제', style: TextStyle(color: Colors.red[400])),
          ),
        ],
      ),
    );
  }
}

// ─── 탭 2: 장소별 ────────────────────────────────────────────────────

class _PlaceTab extends StatelessWidget {
  final List<ReceiptModel> history;

  const _PlaceTab({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return _emptyState();

    // 장소별 그룹핑 (최근 방문순)
    final grouped = <String, List<ReceiptModel>>{};
    for (final r in history) {
      grouped.putIfAbsent(r.data.placeName, () => []).add(r);
    }
    final places = grouped.entries.toList()
      ..sort((a, b) => b.value.first.data.measuredAt
          .compareTo(a.value.first.data.measuredAt));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: places.length,
      separatorBuilder: (_, i) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final entry = places[index];
        return _PlaceCard(
          placeName: entry.key,
          receipts: entry.value,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PlaceDetailScreen(
                placeName: entry.key,
                receipts: entry.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final String placeName;
  final List<ReceiptModel> receipts;
  final VoidCallback onTap;

  const _PlaceCard({
    required this.placeName,
    required this.receipts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 주요 무드 계산
    final moodCounts = <VibeMood, int>{};
    for (final r in receipts) {
      moodCounts[r.mood] = (moodCounts[r.mood] ?? 0) + 1;
    }
    final dominantMood = moodCounts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    final style = vibeMoodStyles[dominantMood]!;
    final lastVisit =
        DateFormat('yyyy.MM.dd').format(receipts.first.data.measuredAt);

    // 방문한 무드 종류
    final moodVariety = moodCounts.keys.length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          gradient: style.gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    placeName,
                    style: AppTheme.receiptFont(
                        size: 15, weight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${receipts.length}번 방문  ·  마지막: $lastVisit',
                    style: AppTheme.receiptFont(
                      size: 11,
                      color: AppColors.primary.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '주로 ${style.label} 무드'
                    '${moodVariety > 1 ? '  ·  $moodVariety가지 무드 경험' : ''}',
                    style: AppTheme.receiptFont(size: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

// ─── 탭 3: 컬렉션 ────────────────────────────────────────────────────

class _CollectionTab extends StatelessWidget {
  final List<ReceiptModel> history;

  const _CollectionTab({required this.history});

  @override
  Widget build(BuildContext context) {
    final moodCounts = <VibeMood, int>{};
    for (final r in history) {
      moodCounts[r.mood] = (moodCounts[r.mood] ?? 0) + 1;
    }
    final uniquePlaces = history.map((r) => r.data.placeName).toSet().length;
    final unlockedCount = moodCounts.keys.length;
    final allUnlocked = unlockedCount == VibeMood.values.length;
    final streak = _computeStreak(history);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 통계 배너
          _StatsRow(
            total: history.length,
            places: uniquePlaces,
            topMood: history.isEmpty
                ? null
                : moodCounts.entries
                    .reduce((a, b) => a.value >= b.value ? a : b)
                    .key,
          ),
          const SizedBox(height: 12),

          // 스트릭 배너
          _StreakBanner(streak: streak),
          const SizedBox(height: 16),

          // 컬렉션 완성 배너
          if (allUnlocked) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8D5F2), Color(0xFFFFF3B0)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '✦  6가지 무드 컬렉션 완성  ✦',
                textAlign: TextAlign.center,
                style: AppTheme.receiptFont(
                  size: 13,
                  weight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 무드 도장판
          Row(
            children: [
              Text(
                '무드 컬렉션',
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$unlockedCount / ${VibeMood.values.length}',
                style: GoogleFonts.notoSansKr(
                  fontSize: 12,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0,
            children: VibeMood.values.map((mood) {
              final count = moodCounts[mood] ?? 0;
              return _MoodStamp(mood: mood, count: count);
            }).toList(),
          ),

          if (history.isEmpty) ...[
            const SizedBox(height: 32),
            Text(
              '바이브를 측정하면\n무드 도장이 채워져요',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansKr(
                fontSize: 13,
                color: AppColors.secondary,
                height: 1.7,
              ),
            ),
          ],

          const SizedBox(height: 28),

          // 마일스톤 배지
          Text(
            '마일스톤',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...milestones.map((m) {
            final unlocked = history.length >= m.count;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: unlocked
                      ? AppColors.surface
                      : AppColors.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: unlocked
                        ? const Color(0xFFE8C96C)
                        : AppColors.divider,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      m.icon,
                      style: TextStyle(
                        fontSize: 24,
                        color: unlocked ? null : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.label,
                            style: GoogleFonts.notoSansKr(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: unlocked
                                  ? AppColors.primary
                                  : AppColors.secondary,
                            ),
                          ),
                          Text(
                            m.desc,
                            style: GoogleFonts.notoSansKr(
                              fontSize: 11,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (unlocked)
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFFE8C96C), size: 20)
                    else
                      Text(
                        '${m.count}장',
                        style: AppTheme.receiptFont(
                          size: 12,
                          color: AppColors.secondary,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StreakBanner extends StatelessWidget {
  final int streak;

  const _StreakBanner({required this.streak});

  @override
  Widget build(BuildContext context) {
    final isActive = streak > 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        gradient: isActive
            ? const LinearGradient(
                colors: [Color(0xFFFFE5B4), Color(0xFFFFF3B0)],
              )
            : null,
        color: isActive ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFFE8C96C) : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Text(
            isActive ? '🔥' : '💤',
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive ? '$streak일 연속 측정 중!' : '오늘의 바이브를 측정해봐요',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                if (isActive)
                  Text(
                    streak >= 7
                        ? '대단해요! 한 주를 꽉 채웠어요'
                        : '매일 측정하면 스트릭이 쌓여요',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 11,
                      color: AppColors.secondary,
                    ),
                  ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8C96C),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$streak',
                style: AppTheme.receiptFont(
                    size: 16, weight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int total;
  final int places;
  final VibeMood? topMood;

  const _StatsRow({
    required this.total,
    required this.places,
    required this.topMood,
  });

  @override
  Widget build(BuildContext context) {
    final topLabel = topMood != null ? vibeMoodStyles[topMood!]!.label : '--';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          _StatCell(value: '$total', label: '총 영수증'),
          _divider(),
          _StatCell(value: '$places', label: '방문 장소'),
          _divider(),
          _StatCell(value: topLabel, label: '최다 무드'),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 32,
        color: AppColors.divider,
      );
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;

  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.receiptFont(size: 20, weight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.notoSansKr(
              fontSize: 11,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodStamp extends StatelessWidget {
  final VibeMood mood;
  final int count;

  const _MoodStamp({required this.mood, required this.count});

  @override
  Widget build(BuildContext context) {
    final style = vibeMoodStyles[mood]!;
    final unlocked = count > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: unlocked ? style.gradient : null,
        color: unlocked ? null : AppColors.divider.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked
              ? Colors.transparent
              : AppColors.divider,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (unlocked)
            Text(
              '$count회',
              style: AppTheme.receiptFont(
                size: 10,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
          if (!unlocked) const SizedBox(height: 14),
          Text(
            style.label,
            style: AppTheme.receiptFont(
              size: 13,
              weight: FontWeight.w700,
              color: unlocked ? AppColors.primary : AppColors.secondary,
            ),
          ),
          Text(
            style.englishLabel,
            style: AppTheme.receiptFont(
              size: 9,
              letterSpacing: 1,
              color: unlocked
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : AppColors.secondary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 마일스톤 정의 ────────────────────────────────────────────────────

const milestones = [
  (count: 1, label: 'Drifter', icon: '✦', desc: '첫 번째 영수증 발급'),
  (count: 10, label: 'Seeker', icon: '✦', desc: '10장 달성'),
  (count: 25, label: 'Keeper', icon: '✦', desc: '25장 달성'),
  (count: 50, label: 'Oracle', icon: '✦', desc: '50장 달성'),
];

// ─── 스트릭 계산 ──────────────────────────────────────────────────────

int _computeStreak(List<ReceiptModel> history) {
  if (history.isEmpty) return 0;

  final dates = history
      .map((r) {
        final d = r.data.measuredAt;
        return DateTime(d.year, d.month, d.day);
      })
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a)); // 최신순

  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final yesterday = todayDate.subtract(const Duration(days: 1));

  // 오늘 또는 어제부터 시작하지 않으면 스트릭 없음
  if (dates.first != todayDate && dates.first != yesterday) return 0;

  int streak = 1;
  for (int i = 1; i < dates.length; i++) {
    final expected = dates[i - 1].subtract(const Duration(days: 1));
    if (dates[i] == expected) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}

// ─── 공통 Empty State ────────────────────────────────────────────────

Widget _emptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.receipt_long_outlined,
            size: 56, color: AppColors.secondary),
        const SizedBox(height: 16),
        Text(
          '아직 발급된 영수증이 없어요',
          style: GoogleFonts.notoSansKr(
              fontSize: 14, color: AppColors.secondary),
        ),
      ],
    ),
  );
}

// ─── 장소별 상세 화면 ─────────────────────────────────────────────────

class PlaceDetailScreen extends ConsumerWidget {
  final String placeName;
  final List<ReceiptModel> receipts;

  const PlaceDetailScreen({
    super.key,
    required this.placeName,
    required this.receipts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 무드 다양성 계산
    final moodCounts = <VibeMood, int>{};
    for (final r in receipts) {
      moodCounts[r.mood] = (moodCounts[r.mood] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          placeName,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // 장소 요약 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: moodCounts.entries.map((entry) {
                  final style = vibeMoodStyles[entry.key]!;
                  return Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: style.gradient,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        style.label,
                        style: AppTheme.receiptFont(size: 10),
                      ),
                      Text(
                        '${entry.value}회',
                        style: AppTheme.receiptFont(
                          size: 10,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          // 영수증 목록
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: receipts.length,
              separatorBuilder: (_, i) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final receipt = receipts[index];
                return _HistoryCard(
                  receipt: receipt,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          HistoryDetailScreen(receipt: receipt),
                    ),
                  ),
                  onDelete: () => _confirmDelete(
                      context, ref, receipt.receiptNumber),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, String receiptNumber) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('영수증 삭제',
            style: GoogleFonts.notoSansKr(fontWeight: FontWeight.w700)),
        content:
            Text('이 영수증을 삭제할까요?', style: GoogleFonts.notoSansKr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              ref.read(historyProvider.notifier).remove(receiptNumber);
              Navigator.of(context).pop();
            },
            child:
                Text('삭제', style: TextStyle(color: Colors.red[400])),
          ),
        ],
      ),
    );
  }
}

// ─── 히스토리 카드 (공통) ─────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final ReceiptModel receipt;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.receipt,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final d = receipt.data;
    final style = receipt.style;
    final date = DateFormat('yyyy.MM.dd HH:mm').format(d.measuredAt);
    final hasPhoto = d.photo != null && d.photo!.existsSync();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: style.gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (hasPhoto)
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12)),
                child: Image.file(
                  d.photo!,
                  width: 72,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.placeName,
                      style: AppTheme.receiptFont(
                          size: 14, weight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      date,
                      style: AppTheme.receiptFont(
                        size: 11,
                        color: AppColors.primary.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${style.label}  ·  "${receipt.phrase}"',
                      style: AppTheme.receiptFont(size: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 히스토리 상세 화면 ───────────────────────────────────────────────

class HistoryDetailScreen extends ConsumerStatefulWidget {
  final ReceiptModel receipt;

  const HistoryDetailScreen({super.key, required this.receipt});

  @override
  ConsumerState<HistoryDetailScreen> createState() =>
      _HistoryDetailScreenState();
}

class _HistoryDetailScreenState
    extends ConsumerState<HistoryDetailScreen> {
  final _screenshotController = ScreenshotController();
  final _exportService = ImageExportService();

  Future<void> _onSave() async {
    final bytes = await _screenshotController.capture(pixelRatio: 3);
    if (bytes == null) return;
    final ok = await _exportService.saveToGallery(bytes);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? '갤러리에 저장되었어요' : '저장에 실패했어요'),
    ));
  }

  void _onShare() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _HistoryShareSheet(
        onImageShare: _shareImage,
        onStoryShare: _shareStory,
        onTextShare: _shareText,
      ),
    );
  }

  Future<void> _shareImage() async {
    Navigator.of(context).pop();
    final bytes = await _screenshotController.capture(pixelRatio: 3);
    if (bytes == null) return;
    await _exportService.share(bytes);
  }

  Future<void> _shareStory() async {
    Navigator.of(context).pop();
    final currentTheme = ref.read(receiptThemeProvider);

    try {
      final bytes = await ScreenshotController().captureFromWidget(
        StoryFrameWidget(receipt: widget.receipt, theme: currentTheme),
        delay: const Duration(milliseconds: 150),
        pixelRatio: 2.0,
        context: context,
      );
      await _exportService.share(bytes,
          text: '나의 오늘 공간 바이브 🧾 #VibeReceipt');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('스토리 이미지 생성에 실패했어요')),
      );
    }
  }

  Future<void> _shareText() async {
    Navigator.of(context).pop();
    await _exportService.shareAsText(widget.receipt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(receiptThemeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.receipt.data.placeName,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 12),
                child: Screenshot(
                  controller: _screenshotController,
                  child: ReceiptWidget(
                    receipt: widget.receipt,
                    theme: theme,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _onSave,
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('저장'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _onShare,
                      icon: const Icon(Icons.ios_share_rounded),
                      label: const Text('공유'),
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

class _HistoryShareSheet extends StatelessWidget {
  final VoidCallback onImageShare;
  final VoidCallback onStoryShare;
  final VoidCallback onTextShare;

  const _HistoryShareSheet({
    required this.onImageShare,
    required this.onStoryShare,
    required this.onTextShare,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '공유 방식 선택',
              style: GoogleFonts.notoSansKr(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _option(Icons.image_outlined, '이미지 공유', onImageShare),
            const SizedBox(height: 12),
            _option(Icons.crop_portrait_rounded, '스토리 형식 공유',
                onStoryShare),
            const SizedBox(height: 12),
            _option(
                Icons.text_snippet_outlined, '텍스트 공유', onTextShare),
          ],
        ),
      ),
    );
  }

  Widget _option(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.notoSansKr(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
