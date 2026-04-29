import 'package:flutter/material.dart';

enum VibeMood {
  sentimental,
  joyful,
  calm,
  energetic,
  dreamy,
  focused,
}

enum VibeRarity { common, uncommon, rare }

class VibeMoodStyle {
  final String label;
  final String englishLabel;
  final Color gradientStart;
  final Color gradientEnd;
  final List<String> phrases;
  final VibeRarity rarity;
  final String rarityStars;
  final String rarityPercent;

  const VibeMoodStyle({
    required this.label,
    required this.englishLabel,
    required this.gradientStart,
    required this.gradientEnd,
    required this.phrases,
    required this.rarity,
    required this.rarityStars,
    required this.rarityPercent,
  });

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gradientStart, gradientEnd],
      );
}

const Map<VibeMood, VibeMoodStyle> vibeMoodStyles = {
  VibeMood.sentimental: VibeMoodStyle(
    label: '감성',
    englishLabel: 'SENTIMENTAL',
    gradientStart: Color(0xFFE8D5F2),
    gradientEnd: Color(0xFFFAD4D4),
    rarity: VibeRarity.uncommon,
    rarityStars: '★★',
    rarityPercent: '전체 측정 중 약 18%만 나와요',
    phrases: [
      '창밖의 노을이 조용히 번지는 순간',
      '오래된 LP가 생각나는 잔잔한 공기',
      '마음이 말캉해지는 저녁의 끝자락',
      '조명 아래 감정이 한 뼘 깊어지는 시간',
      '이 순간만 영원했으면 하는 기분',
      '스며드는 음악과 나누는 혼잣말',
      '흐릿한 조명, 또렷해지는 감정',
      '천천히 식어가는 커피 한 잔의 여운',
    ],
  ),
  VibeMood.joyful: VibeMoodStyle(
    label: '즐거움',
    englishLabel: 'JOYFUL',
    gradientStart: Color(0xFFFFF3B0),
    gradientEnd: Color(0xFFFFCFA5),
    rarity: VibeRarity.common,
    rarityStars: '★',
    rarityPercent: '자주 만날 수 있는 무드예요',
    phrases: [
      '햇살이 쏟아지는 완벽한 오후',
      '웃음이 절로 새어 나오는 시간',
      '기분 좋은 소란스러움 속에서',
      '비타민 같은 하루의 한 장면',
      '창문 너머 반짝이는 일상',
      '이유 없이 기분 좋아지는 순간',
      '가벼운 발걸음이 어울리는 공기',
      '오늘이 조금 특별해지는 찰나',
    ],
  ),
  VibeMood.calm: VibeMoodStyle(
    label: '차분',
    englishLabel: 'CALM',
    gradientStart: Color(0xFFD6F2E6),
    gradientEnd: Color(0xFFCDE7F5),
    rarity: VibeRarity.common,
    rarityStars: '★',
    rarityPercent: '자주 만날 수 있는 무드예요',
    phrases: [
      '숨이 깊어지는 조용한 시간',
      '잔잔한 물결 같은 오전의 공기',
      '마음이 가지런해지는 순간',
      '고요함이 가장 사치스럽게 느껴질 때',
      '생각이 천천히 흐르는 풍경',
      '적당한 온도의 평온함',
      '세상이 숨을 고르는 시간',
      '정돈된 공기 속의 작은 여백',
    ],
  ),
  VibeMood.energetic: VibeMoodStyle(
    label: '활기',
    englishLabel: 'ENERGETIC',
    gradientStart: Color(0xFFFFC2B4),
    gradientEnd: Color(0xFFFFA5C0),
    rarity: VibeRarity.uncommon,
    rarityStars: '★★',
    rarityPercent: '전체 측정 중 약 15%만 나와요',
    phrases: [
      '심장 박동이 음악에 맞춰지는 밤',
      '에너지가 공기 중에 팽팽한 순간',
      '오늘 밤의 주인공이 된 기분',
      '불빛과 소음이 만드는 해방감',
      '한껏 들뜬 공기의 한가운데',
      '모두가 살아있는 이 시간',
      '내일은 모르겠고, 지금을 살 것',
      '짜릿함이 피부에 닿는 순간',
    ],
  ),
  VibeMood.dreamy: VibeMoodStyle(
    label: '몽환',
    englishLabel: 'DREAMY',
    gradientStart: Color(0xFFE0C9F5),
    gradientEnd: Color(0xFFFAD0E8),
    rarity: VibeRarity.rare,
    rarityStars: '★★★',
    rarityPercent: '전체 측정 중 약 10%만 나와요',
    phrases: [
      '꿈과 현실의 경계가 흐려지는 새벽',
      '별이 가라앉는 듯한 어두운 공기',
      '현실감이 옅어지는 푸른 시간',
      '스크린 속 장면 같은 밤의 한 컷',
      '조도가 낮은 세상에서의 독백',
      '마음이 물속처럼 느려지는 시간',
      '필름 그레인 같은 질감의 새벽',
      '깊은 밤이 건네는 혼잣말',
    ],
  ),
  VibeMood.focused: VibeMoodStyle(
    label: '집중',
    englishLabel: 'FOCUSED',
    gradientStart: Color(0xFFF5F1E8),
    gradientEnd: Color(0xFFDDE1E5),
    rarity: VibeRarity.uncommon,
    rarityStars: '★★',
    rarityPercent: '전체 측정 중 약 22%만 나와요',
    phrases: [
      '키보드 소리만이 존재감을 가지는 시간',
      '몰입의 결이 가장 선명한 공간',
      '생각의 흐름이 끊기지 않는 풍경',
      '커피 한 잔, 노트북 한 대의 세계',
      '타이머를 끄고 싶지 않은 몰입',
      '머릿속이 깨끗하게 정돈되는 공기',
      '조용한 도서관의 무게감',
      '나와 작업만 남은 고요',
    ],
  ),
};
