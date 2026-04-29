# Vibe Receipt — 공간 무드 영수증

> 지금 이 공간, 어떤 바이브인가요?

스마트폰 센서(조도, 소음)와 현재 시간을 조합해 공간의 분위기를 측정하고,
감성 영수증 이미지로 출력·저장·공유하는 Flutter 앱입니다.

---

## 1. 프로젝트 개요

| 항목 | 내용 |
|---|---|
| 프로젝트명 | Vibe Receipt (바이브 영수증) |
| 한 줄 소개 | 빛·소음·시간을 영수증 한 장으로 시각화하는 공간 무드 아카이빙 앱 |
| 플랫폼 | Android (Flutter 3.x) |
| 개발 방식 | Vibe Coding — AI 페어 프로그래밍 + 직접 구현 |
| 아키텍처 | Serverless, 디바이스 센서 + 로컬 연산만 사용 |
| 상태관리 | Riverpod (StateNotifier) |
| 최소 SDK | Android API 21 (Lollipop) |

기존의 환경 측정 앱이 지나치게 기술적이고 건조하다는 문제 인식에서 출발해,
보이지 않는 물리적 환경 데이터(빛, 소음, 시간)를 타이포그래피 중심의 영수증이라는
아날로그 감성 포맷으로 시각화한 유틸리티입니다.

---

## 2. 어떻게 작동하나요?

```
[홈 화면]
  장소 입력 (필수)  +  테마 선택  +  사진·한 마디 (선택, 토글로 접힘)
                          │
                          ▼ 바이브 측정하기 (화면 하단 고정)
                          │
               조도·소음·시간대 센서 측정 (4초)
                          │
                          ▼
               무드 매칭 (6가지 카테고리)
                          │
                          ▼
     감성 영수증 발급  →  저장 / 공유 / 아카이브
```

---

## 3. 주요 기능

### 3-1. 온보딩

첫 실행 시 3장의 슬라이드로 앱의 핵심 기능을 소개합니다.
완료 후 다시 표시되지 않으며, 홈 화면 좌측 상단 `?` 버튼 또는 설정에서 재열람할 수 있습니다.

| 슬라이드 | 내용 |
|---|---|
| SENSE | 조도·소음·시간으로 공간 분위기 분석 |
| RECEIPT | 6가지 무드 중 하나로 감성 영수증 발급 |
| ARCHIVE | 영수증 자동 저장 및 컬렉션 완성 |

### 3-2. 홈 화면 (Progressive Disclosure)

불필요한 요소를 줄이고 핵심 입력에 집중한 미니멀 구성입니다.

| 영역 | 설명 |
|---|---|
| 장소 입력 | 항상 노출, 필수 입력 |
| 영수증 테마 | 미니 카드 형태의 시각적 선택기 (항상 노출) |
| 사진 · 한 마디 | 토글 버튼으로 접고 펼침 — 내용이 있으면 점(●)으로 표시 |
| 바이브 측정 버튼 | 화면 하단 고정 — 스크롤과 무관하게 항상 접근 가능 |
| ? 버튼 | 좌측 상단 고정 — 온보딩 재열람 |

### 3-3. 측정 및 매칭

| 기능 | 설명 |
|---|---|
| 공간 센서 측정 | 조도(lux) + 소음(dB) + 시간대를 조합해 무드 분석 |
| 마이크 권한 폴백 | 마이크 권한 거부 시 소음을 조용한 환경으로 처리하고 측정 계속 진행 |
| 6가지 무드 | 감성 / 즐거움 / 차분 / 활기 / 몽환 / 집중 |
| 희귀도 시스템 | 무드별 출현 빈도에 따라 Common / Uncommon / Rare 등급 부여 |
| 감성 문구 | 무드별 8개 문구 중 측정 시각 시드 기반 랜덤 출력 |

### 3-4. 영수증 테마 (시각적 선택)

업계 표준(Canva·Unfold 방식)의 미니 영수증 카드로 테마를 선택합니다.
각 카드는 실제 테마의 paper 색상과 영수증 라인을 축소 미리보기로 보여줍니다.
선택 시 카드에 테두리·체크 배지·그림자 애니메이션이 적용됩니다.

| 테마 | 미리보기 | 특징 |
|---|---|---|
| 기본 (Classic) | 무드 그라디언트 대표색 | 측정 무드에 따라 파스텔 그라데이션 배경 |
| 다크 (Dark) | 차콜 `#1C1C1E` | 다크 페이퍼, 라이트 텍스트 |
| 크래프트 (Kraft) | 브라운 `#CEA882` | 크래프트지 느낌 |

선택한 테마는 기기에 영구 저장됩니다.

### 3-5. 로딩 애니메이션

센서 측정 중 영수증 프린터 모형 애니메이션이 재생됩니다.
단계별 상태 텍스트(조도 감지 → 소음 측정 → 무드 매칭)로 측정 과정을 시각적으로 전달합니다.

### 3-6. 공유

| 방식 | 설명 |
|---|---|
| 이미지 공유 | 영수증을 PNG로 캡처해 SNS에 공유 |
| 스토리 형식 공유 | 9:16 비율 프레임으로 캡처 — 인스타 스토리 최적화 |
| 텍스트 공유 | 이모지 영수증 카드 텍스트로 공유 |
| 갤러리 저장 | 기기 갤러리의 'Vibe Receipt' 앨범에 저장 |

### 3-7. 히스토리 아카이브

발급된 영수증은 자동 저장(최대 50건)되며, 바텀 네비게이션의 아카이브 탭에서 확인할 수 있습니다.

| 탭 | 내용 |
|---|---|
| 시간순 | 최신순 영수증 목록 / 조회 / 재공유 / 삭제 |
| 장소별 | 장소명 기준 그룹핑 / 방문 횟수 / 주요 무드 / 무드 다양성 |
| 컬렉션 | 무드 도장판 6종 + 연속 측정 스트릭 + 마일스톤 4단계 + 통계 |

**연속 측정 스트릭**: 날짜 기준 연속 측정일을 계산해 🔥 배너로 표시.

**마일스톤 배지**: 총 발급 수에 따라 4단계 배지 잠금 해제, 달성 시 축하 다이얼로그 표시.

| 배지 | 조건 |
|---|---|
| ✦ Drifter | 첫 번째 영수증 발급 |
| ✦ Seeker | 10장 달성 |
| ✦ Keeper | 25장 달성 |
| ✦ Oracle | 50장 달성 |

### 3-8. 알림

측정 완료 후 다음 날 저녁 8시에 스트릭 유지 알림이 예약됩니다.
오늘 측정하면 알림이 하루 뒤로 자동 재예약됩니다.

### 3-9. 설정

| 항목 | 설명 |
|---|---|
| 온보딩 다시 보기 | 앱 소개 슬라이드 재확인 (플래그 초기화 후 재실행) |
| 오픈소스 라이선스 | 사용된 패키지 라이선스 전체 열람 (`showLicensePage`) |

---

## 4. 무드 × 색상 × 희귀도 매핑

| 무드 | 색상 | 희귀도 | 매칭 조건 |
|---|---|---|---|
| 감성 SENTIMENTAL | 라벤더 → 더스티 로즈 | Uncommon (18%) | 저녁, 어두움, 조용함 |
| 즐거움 JOYFUL | 버터 옐로우 → 피치 | Common | 낮, 밝음, 소란스러움 |
| 차분 CALM | 민트 → 스카이블루 | Common | 새벽 / 아침, 조용함 |
| 활기 ENERGETIC | 코랄 → 살몬 핑크 | Uncommon (15%) | 저녁 / 심야, 시끌벅적 |
| 몽환 DREAMY | 라일락 → 베이비 핑크 | Rare (10%) | 심야, 어두움 |
| 집중 FOCUSED | 크림 → 라이트 그레이 | Uncommon (22%) | 낮, 밝음, 조용함 |

매칭 로직: `lib/data/services/vibe_matcher.dart`

---

## 5. 시작하기

```bash
# 의존성 설치
flutter pub get

# 실행 (Android 실기기 권장 — 에뮬레이터는 조도 센서 미지원)
flutter run

# 릴리즈 빌드
flutter build apk --release
```

> 마이크 권한을 거부해도 조도·시간 기반으로 측정이 계속 진행됩니다.

---

## 6. 프로젝트 구조

```
lib/
├── main.dart                          # 앱 진입점, 알림 서비스 초기화
├── app.dart                           # 온보딩 완료 여부 분기 라우팅
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # 앱 전체 색상 상수
│   │   ├── receipt_themes.dart        # 영수증 테마 (Classic / Dark / Kraft)
│   │   └── vibe_phrases.dart          # 무드별 문구·그라데이션·희귀도 정의
│   ├── theme/app_theme.dart           # MaterialTheme + 영수증 폰트 헬퍼
│   └── utils/
│       ├── permission_helper.dart     # 권한 요청 유틸
│       └── time_helper.dart           # 시간대 5구간 분류
├── data/
│   ├── models/
│   │   ├── vibe_data.dart             # 센서 원본 데이터 (직렬화 지원)
│   │   └── receipt_model.dart         # 최종 영수증 모델 (직렬화 지원)
│   └── services/
│       ├── light_service.dart         # 조도 센서 평균 측정
│       ├── noise_service.dart         # 소음 평균 측정
│       ├── vibe_matcher.dart          # 무드 매칭 알고리즘
│       ├── history_service.dart       # 히스토리 로컬 저장 / 불러오기 / 사진 복사
│       ├── image_export_service.dart  # 갤러리 저장 / 이미지 공유 / 텍스트 카드 생성
│       └── notification_service.dart  # 스트릭 유지 알림 예약
├── providers/
│   ├── vibe_provider.dart             # 측정 상태 관리 (StateNotifier)
│   ├── history_provider.dart          # 히스토리 상태 관리
│   └── receipt_theme_provider.dart    # 테마 설정 (영구 저장)
└── presentation/
    ├── screens/
    │   ├── home_shell.dart            # 바텀 네비게이션 셸 (홈 / 아카이브 / 설정)
    │   ├── onboarding_screen.dart     # 첫 실행 온보딩 (3슬라이드, 리뷰 모드 지원)
    │   ├── main_screen.dart           # 홈 탭 — 장소·테마 입력, 옵션 토글, 하단 고정 CTA
    │   ├── loading_screen.dart        # 프린터 애니메이션 + 센서 측정
    │   ├── result_screen.dart         # 영수증 결과 / 희귀도 배너 / 공유 / 마일스톤
    │   ├── history_screen.dart        # 아카이브 탭 (시간순 / 장소별 / 컬렉션)
    │   └── settings_screen.dart       # 설정 탭 (온보딩 재실행 / OSS 라이선스)
    └── widgets/
        ├── receipt_widget.dart        # 영수증 본체 (테마 대응)
        ├── story_frame_widget.dart    # 9:16 스토리 프레임
        ├── barcode_painter.dart       # 무드별 고유 패턴 바코드 (CustomPainter)
        └── zigzag_edge_painter.dart   # 지그재그 절취선 (CustomPainter)
```

---

## 7. 본인이 구현한 부분

전체 시스템 설계 / 매칭 로직 / 확장 기능은 직접 구현했고,
초기 코드 골격 일부는 AI 페어 프로그래밍(Vibe Coding)으로 작성한 뒤 본인이 검토·수정·확장했습니다.

| 영역 | 직접 구현 / 설계 항목 |
|---|---|
| 기획 | 6가지 무드 카테고리 정의, 무드별 색상(파스텔 그라데이션) 결정, 영수증 정보 구성, UX 플로우 전체 |
| 매칭 알고리즘 | 시간대 5구간 × 조도 3단계 × 소음 3단계 조합 매칭 룰, 무드별 감성 문구 48개 직접 작성 |
| 희귀도 시스템 | 무드별 Common / Uncommon / Rare 등급, 희귀 무드 출현 시 결과 화면 배너 연출 |
| 영수증 디자인 | 영수증 위젯 레이아웃, 지그재그 절취선 / 무드별 바코드 패턴 CustomPainter, 모노스페이스 폰트 |
| 테마 시스템 | 3가지 영수증 테마 및 미니 카드 시각 선택기 (Canva 방식), 테마 영구 저장 |
| UI / UX 개선 | 바텀 네비게이션, Progressive Disclosure 홈 화면, 하단 고정 CTA, ? 버튼 온보딩 접근 |
| 폰트 개선 | 게임풍 VT323 → Playfair Display (감성 세리프) 브랜딩 폰트 교체 |
| 공유 기능 | 9:16 스토리 프레임, 이모지 텍스트 카드, 공유 방식 선택 바텀시트, 스토리 캡처 버그 수정 |
| 히스토리 기능 | SharedPreferences 기반 직렬화 저장, 사진 타임스탬프 고유 복사, 아카이브 화면 구현 |
| 컬렉션 시스템 | 무드 도장판(6종), 연속 측정 스트릭 계산, 마일스톤 4단계(Drifter → Oracle) |
| 온보딩 | 첫 실행 감지, 3슬라이드 + 페이지 도트, 리뷰 모드(pop vs pushReplacement 분기) |
| 마이크 권한 폴백 | 권한 거부 시 앱 블로킹 없이 소음을 조용한 값으로 처리하고 측정 계속 진행 |
| 알림 | 스트릭 유지 push notification 예약 (측정 완료 후 다음 날 저녁 8시) |
| Android 설정 | minSdkVersion 21, 앱 아이콘(ic_logo) / 스플래시(ic_splash) 분리 적용, core library desugaring |
| 코드 안정성 | 권한 플로우 검증, 스토리 캡처 예외 처리, 사진 파일 존재성 체크, `flutter analyze` 이슈 0 |

---

## 8. AI 활용 여부 및 범위 (Vibe Coding)

본 프로젝트는 Vibe Coding(AI 페어 프로그래밍) 방식으로 진행되었습니다.
AI는 코드 생성을 보조하는 도구로 활용했으며, 모든 결과물은 본인이 검토·수정·재구성한 뒤 커밋했습니다.

### 8-1. AI를 활용한 범위

| 항목 | 활용 정도 | 설명 |
|---|---|---|
| 폴더 구조 / 아키텍처 제안 | 보조 | core / data / presentation 레이어 분리 초안을 AI에게 제안받고 본인이 확정 |
| Riverpod StateNotifier 보일러플레이트 | 보조 | VibeNotifier, HistoryNotifier 기본 패턴 생성 후 본인이 수정 |
| CustomPainter (바코드 / 지그재그) | 보조 | 그리는 로직 초안 작성 후 디자인 톤에 맞게 본인이 조정 |
| Flutter 패키지 사용법 / API | 참고 | noise_meter, gal, screenshot 등 신규 패키지 사용 예 참고 |
| 무드 카테고리 / 색상 / 문구 | 직접 | 6가지 무드 컨셉, 그라데이션 컬러, 감성 문구 48개 모두 본인이 작성 |
| 매칭 알고리즘 룰 | 직접 | 조도 / 소음 / 시간대 분기 조건과 임계값 본인이 설계 |
| UI / UX 플로우 | 직접 | 입력 → 로딩 → 결과 → 공유 → 아카이브 흐름과 화면 구성 본인이 결정 |

### 8-2. 검증 절차

- AI가 생성한 코드는 반드시 빌드 / 실행 후 동작 확인 후 반영
- 외부 패키지 사용 시 pub.dev에서 라이선스 / 유지보수 점수 / 사용량 확인
- 보안에 영향이 있는 권한 요청 / 파일 저장 로직은 본인이 직접 검토

---

## 9. 라이센스 (License)

### 9-1. 본 프로젝트 라이선스

본 프로젝트는 MIT License 하에 배포됩니다.
전문은 저장소의 LICENSE 파일을 참고해 주세요.

```
Copyright (c) 2026 Vibe Receipt
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

### 9-2. 사용 패키지 라이선스 (Third-Party Notices)

> Flutter 앱 배포 시 모든 외부 패키지의 라이선스를 명시하는 것은 개발자 / 배포자의 의무입니다.

본 프로젝트는 다음 오픈소스 패키지를 사용하며, 각 패키지의 라이선스 조건을 준수합니다.
모든 사용 패키지는 Permissive 계열(MIT / BSD / Apache-2.0)로 상업적 사용이 가능합니다.
GPL / LGPL 계열 패키지는 사용하지 않습니다.

| 패키지 | 용도 | 라이선스 (SPDX) |
|---|---|---|
| flutter | 프레임워크 | BSD-3-Clause |
| cupertino_icons | iOS 스타일 아이콘 | MIT |
| flutter_riverpod | 상태 관리 | MIT |
| light_sensor | 조도 센서 | MIT |
| noise_meter | 소음 측정 | MIT |
| permission_handler | 권한 처리 | MIT |
| image_picker | 카메라 / 갤러리 선택 | Apache-2.0 / BSD-3-Clause |
| path_provider | 경로 조회 | BSD-3-Clause |
| path | 경로 유틸 | BSD-3-Clause |
| google_fonts | 폰트 (Playfair Display, Courier Prime, Noto Sans KR) | Apache-2.0 |
| screenshot | 위젯 캡처 | MIT |
| gal | 갤러리 저장 | BSD-3-Clause |
| share_plus | 시스템 공유 시트 | BSD-3-Clause |
| intl | 국제화 / 날짜 포맷 | BSD-3-Clause |
| shared_preferences | 로컬 키-값 저장 | BSD-3-Clause |
| flutter_local_notifications | 로컬 푸시 알림 | BSD-3-Clause |
| timezone | 시간대 처리 (알림용) | BSD-2-Clause |
| flutter_lints | 린트 규칙 (dev) | BSD-3-Clause |
| flutter_launcher_icons | 앱 아이콘 생성 (dev) | MIT |
| flutter_native_splash | 스플래시 화면 생성 (dev) | MIT |

### 9-3. 폰트 라이선스

본 앱에 사용된 모든 폰트는 google_fonts 패키지를 통해 런타임에 로드되며, 다음 라이선스를 따릅니다.

| 폰트 | 용도 | 라이선스 |
|---|---|---|
| Playfair Display | 브랜딩 타이틀 / AppBar | SIL Open Font License 1.1 |
| Courier Prime | 영수증 본문 (모노스페이스) | SIL Open Font License 1.1 |
| Noto Sans KR | 한국어 UI 텍스트 | SIL Open Font License 1.1 |

### 9-4. 앱 내 라이선스 표시

Flutter 표준 `showLicensePage()` API를 통해 앱 내 설정 화면에서 모든 의존성의 라이선스를 확인할 수 있습니다.

### 9-5. 라이선스 컴플라이언스 점검 절차

1. 패키지 추가 전 pub.dev의 License 필드와 GitHub LICENSE 원문 검토
2. `flutter pub deps`로 transitive dependency까지 확인
3. 라이선스 화이트리스트 — MIT / BSD / Apache-2.0 / OFL만 허용
4. GPL / LGPL 계열 패키지 사용 금지
5. 고지 위치 — README 본 섹션 + 앱 내 `showLicensePage()`

---

## 10. Android 요구사항

- minSdkVersion 21 (Android 5.0 Lollipop)
- 권한: `RECORD_AUDIO`, `CAMERA`, `READ_MEDIA_IMAGES`, `WRITE_EXTERNAL_STORAGE` (≤ API 29)
- 조도 센서 / 마이크가 탑재된 실기기 사용 권장 (에뮬레이터는 조도 센서 미지원)
- 마이크 권한 없이도 조도 + 시간 기반 측정은 정상 동작
- 앱 아이콘: `ic_logo.png` / 스플래시 화면: `ic_splash.png` (별도 이미지 사용)

---

## 11. 문의

이슈 / 개선 제안은 저장소 Issues 탭에 남겨 주세요.
