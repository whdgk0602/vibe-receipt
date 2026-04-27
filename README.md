# Vibe Receipt - 공간 무드 영수증

> 지금 이 공간, 어떤 바이브인가요?

스마트폰 센서(조도, 소음)와 현재 시간을 조합해 공간의 분위기를 측정하고,
감성 영수증 이미지로 출력 및 공유하는 Flutter 앱입니다.

---

## 1. 프로젝트 개요

| 항목 | 내용 |
|---|---|
| 프로젝트명 | Vibe Receipt (바이브 영수증) |
| 한 줄 소개 | 빛, 소음, 시간을 영수증 한 장으로 시각화하는 공간 무드 아카이빙 앱 |
| 플랫폼 | Android (Flutter 3.x) |
| 개발 방식 | Vibe Coding - AI 페어 프로그래밍 + 직접 구현 |
| 아키텍처 | Serverless, 디바이스 센서 + 로컬 연산만 사용 |
| 상태관리 | Riverpod |
| 최소 SDK | Android API 21 (Lollipop) |

기존의 환경 측정 앱이 지나치게 기술적이고 건조하다는 문제 인식에서 출발해,
보이지 않는 물리적 환경 데이터(빛, 소음, 시간)를 타이포그래피 중심의 영수증이라는
아날로그 감성 포맷으로 시각화한 유틸리티입니다.

---

## 2. 어떻게 작동하나요?

```
장소 입력  ->  사진 추가(선택)  ->  한 마디 코멘트(선택)  ->  바이브 측정하기
       |
       v
  조도, 소음, 시간대 센서 4초 측정
       |
       v
  무드 매칭 (6가지 카테고리 중 하나)
       |
       v
  감성 영수증 발급  ->  저장 / 공유 / 아카이브
```

---

## 3. 주요 기능 설명

### 3-1. 측정 및 매칭

| 기능 | 설명 |
|---|---|
| 공간 센서 측정 | 조도(lux) + 소음(dB) + 시간대를 조합해 무드 분석 |
| 6가지 무드 | 감성 / 즐거움 / 차분 / 활기 / 몽환 / 집중 |
| 감성 문구 | 무드별 8개 문구 중 측정 시각 시드 기반 랜덤 출력 |
| 사진 첨부 | 카메라 촬영 또는 갤러리에서 선택 (선택) |
| 한 줄 코멘트 | 이 순간을 직접 한 줄로 남기기 (선택, 40자) |

### 3-2. 영수증 테마

| 테마 | 특징 |
|---|---|
| 기본 (Classic) | 무드별 파스텔 그라데이션 배경 |
| 다크 (Dark) | 차콜 블랙 배경, 라이트 텍스트 |
| 크래프트 (Kraft) | 브라운 크래프트지 느낌 |

### 3-3. 공유

| 방식 | 설명 |
|---|---|
| 이미지 공유 | 영수증을 PNG로 캡처해 SNS에 공유 |
| 스토리 형식 공유 | 9:16 비율 프레임으로 캡처 - 인스타 스토리 최적화 |
| 텍스트 공유 | 이모지 영수증 카드 텍스트로 공유 |
| 갤러리 저장 | 기기 갤러리의 'Vibe Receipt' 앨범에 저장 |

### 3-4. 히스토리

발급된 영수증은 자동 저장(최대 50건)되며, 아카이브 화면에서 과거 영수증 목록을
조회 및 재공유할 수 있습니다. 사진은 앱 내부 저장소에 영구 보관됩니다.

---

## 4. 무드 x 색상 매핑

| 무드 | 색상 | 매칭 조건 |
|---|---|---|
| 감성 SENTIMENTAL | 라벤더 -> 더스티 로즈 | 저녁, 어두움, 조용함 |
| 즐거움 JOYFUL | 버터 옐로우 -> 피치 | 낮, 밝음, 소란스러움 |
| 차분 CALM | 민트 -> 스카이블루 | 새벽 / 아침, 조용함 |
| 활기 ENERGETIC | 코랄 -> 살몬 핑크 | 저녁 / 심야, 시끌벅적 |
| 몽환 DREAMY | 라일락 -> 베이비 핑크 | 심야, 어두움 |
| 집중 FOCUSED | 크림 -> 라이트 그레이 | 낮, 밝음, 조용함 |

매칭 로직: lib/data/services/vibe_matcher.dart

---

## 5. 시작하기

```bash
# 의존성 설치
flutter pub get

# 실행 (Android 실기기 권장 - 에뮬레이터는 조도 센서 미지원)
flutter run

# 릴리즈 빌드
flutter build apk --release
```

---

## 6. 프로젝트 구조

```
lib/
  main.dart
  app.dart
  core/
    constants/
      app_colors.dart
      receipt_themes.dart      # 영수증 테마 (기본/다크/크래프트)
      vibe_phrases.dart        # 무드별 문구 + 그라데이션 색상
    theme/app_theme.dart
    utils/
      permission_helper.dart
      time_helper.dart         # 시간대 분류 (새벽/아침/낮/저녁/심야)
  data/
    models/
      vibe_data.dart           # 센서 원본 데이터 + 코멘트
      receipt_model.dart       # 최종 영수증 (직렬화 지원)
    services/
      light_service.dart       # 조도 센서 평균 측정
      noise_service.dart       # 소음 평균 측정
      vibe_matcher.dart        # 무드 매칭 알고리즘
      history_service.dart     # 히스토리 로컬 저장 / 불러오기
      image_export_service.dart # 저장 / 공유 / 텍스트 카드 생성
  providers/
    vibe_provider.dart           # 측정 상태 관리
    history_provider.dart        # 히스토리 상태 관리
    receipt_theme_provider.dart  # 테마 설정 (영구 저장)
  presentation/
    screens/
      main_screen.dart         # 입력 (장소 / 사진 / 코멘트 / 테마)
      loading_screen.dart      # 센서 측정 중
      result_screen.dart       # 영수증 결과 + 공유
      history_screen.dart      # 아카이브 리스트 + 상세
    widgets/
      receipt_widget.dart      # 영수증 본체 (테마 대응)
      story_frame_widget.dart  # 9:16 스토리 프레임
      zigzag_edge_painter.dart
      barcode_painter.dart
```

---

## 7. 본인이 구현한 부분

전체 시스템 설계 / 매칭 로직 / 확장 기능은 직접 구현했고,
초기 코드 골격 일부는 AI 페어 프로그래밍(Vibe Coding)으로 작성한 뒤 본인이 검토, 수정, 확장했습니다.

| 영역 | 직접 구현 / 설계 항목 |
|---|---|
| 기획 | 6가지 무드 카테고리 정의, 무드별 색상(파스텔 그라데이션) 결정, 영수증 정보 구성, UX 플로우 |
| 매칭 알고리즘 | 시간대 5구간 x 조도 3단계 x 소음 3단계 조합 매칭 룰, 무드별 감성 문구 사전 작성 |
| 영수증 디자인 | 영수증 위젯 레이아웃, 지그재그 절취선 / 바코드 CustomPainter, 모노스페이스 폰트 적용 |
| 테마 시스템 | 3가지 영수증 테마(기본 / 다크 / 크래프트) 추가 및 테마별 색상 / 텍스트 처리 |
| 한 줄 코멘트 | 입력 화면 추가, VibeData 모델 확장, 영수증 위젯 / 텍스트 카드 반영 |
| 히스토리 기능 | shared_preferences 기반 로컬 저장, 모델 직렬화, 아카이브 화면 구현 |
| 공유 기능 확장 | 9:16 스토리 프레임, 이모지 텍스트 카드, 공유 방식 선택 바텀시트 |
| Android 설정 | minSdkVersion 21, 권한(RECORD_AUDIO / CAMERA / READ_MEDIA_IMAGES), 앱 아이콘 / 스플래시 설정 |
| 디버깅 / 통합 | 권한 플로우 검증, 위젯 캡처 픽셀비율 튜닝, 사진 파일 존재성 체크 |

---

## 8. AI 활용 여부 및 활용 범위 (Vibe Coding)

본 프로젝트는 Vibe Coding(AI 페어 프로그래밍) 방식으로 진행되었습니다.
AI는 코드 생성을 보조하는 도구로 활용했으며, 모든 결과물은 본인이 검토 / 수정 / 재구성한 뒤 커밋했습니다.

### 8-1. AI를 활용한 범위

| 항목 | 활용 정도 | 설명 |
|---|---|---|
| 폴더 구조 / 아키텍처 제안 | 보조 | core / data / presentation 레이어 분리 초안을 AI에게 제안받고 본인이 확정 |
| Riverpod StateNotifier 보일러플레이트 | 보조 | VibeNotifier, HistoryNotifier의 기본 패턴 코드 생성 후 본인이 수정 |
| CustomPainter (바코드 / 지그재그) | 보조 | 그리는 로직 초안 작성 후 디자인 톤에 맞게 본인이 조정 |
| Flutter 패키지 사용법 / API | 참고 | noise_meter, gal, screenshot 등 신규 패키지의 사용 예 참고 |
| 무드 카테고리 정의 / 색상 / 문구 | 직접 | 6가지 무드 컨셉, 그라데이션 컬러, 감성 문구 48개 모두 본인이 작성 |
| 매칭 알고리즘 룰 | 직접 | 조도 / 소음 / 시간대 분기 조건과 임계값 본인이 설계 |
| UI / UX 플로우 | 직접 | 입력 -> 로딩 -> 결과 -> 공유 -> 아카이브 흐름과 화면 구성 본인이 결정 |

### 8-2. 검증 절차

- AI가 생성한 코드는 반드시 빌드 / 실행 후 동작을 확인한 뒤 반영
- 외부 패키지 사용 시 pub.dev에서 라이선스 / 유지보수 점수 / 사용량 확인
- 보안에 영향이 있는 권한 요청 / 파일 저장 로직은 본인이 직접 작성

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
> (참고: Flutter 패키지 라이선스 가이드, OSS 컴플라이언스)

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
| image_picker | 카메라 / 갤러리 선택 | Apache-2.0 |
| path_provider | 경로 조회 | BSD-3-Clause |
| path | 경로 유틸 | BSD-3-Clause |
| google_fonts | 구글 폰트 (VT323, Courier Prime, Noto Sans KR) | Apache-2.0 |
| screenshot | 위젯 캡처 | MIT |
| gal | 갤러리 저장 | MIT |
| share_plus | 시스템 공유 시트 | BSD-3-Clause |
| intl | 국제화 / 날짜 포맷 | BSD-3-Clause |
| shared_preferences | 로컬 키-값 저장 | BSD-3-Clause |
| flutter_lints | 린트 규칙 (dev) | BSD-3-Clause |
| flutter_launcher_icons | 앱 아이콘 생성 (dev) | MIT |
| flutter_native_splash | 스플래시 화면 생성 (dev) | MIT |

> 라이선스 정보는 각 패키지의 pub.dev 페이지 및 LICENSE 파일을 기준으로 작성되었으며,
> 패키지 버전 업데이트 시 라이선스가 변경될 수 있으므로 배포 전 재확인을 권장합니다.

### 9-3. 폰트 라이선스

본 앱에 사용된 모든 폰트는 google_fonts 패키지를 통해 런타임에 로드되며,
다음 라이선스를 따릅니다.

| 폰트 | 라이선스 |
|---|---|
| VT323 | SIL Open Font License 1.1 |
| Courier Prime | SIL Open Font License 1.1 |
| Noto Sans KR | SIL Open Font License 1.1 |

### 9-4. 앱 내 라이선스 표시

Flutter 표준 showLicensePage() API를 통해 앱 내에서 모든 의존성의 라이선스를 확인할 수 있도록
설정 화면에 OSS 고지 진입점을 마련할 예정입니다.

```dart
// 예시
showLicensePage(
  context: context,
  applicationName: 'Vibe Receipt',
  applicationVersion: '1.0.0',
);
```

### 9-5. 라이선스 컴플라이언스 점검 절차

본 프로젝트는 다음 절차에 따라 라이선스 컴플라이언스를 검증했습니다.

1. 패키지 추가 전 확인 - pub.dev의 License 필드와 GitHub LICENSE 원문 검토
2. 의존성 트리 점검 - flutter pub deps로 transitive dependency까지 확인
3. 라이선스 화이트리스트 - MIT / BSD / Apache-2.0 / OFL만 허용
4. GPL / LGPL 차단 - Copyleft 계열 패키지는 사용하지 않음
5. 고지 위치 - README의 본 섹션 + 앱 내 showLicensePage()

---

## 10. Android 요구사항

- minSdkVersion 21 (Android 5.0 Lollipop)
- 권한: RECORD_AUDIO, CAMERA, READ_MEDIA_IMAGES, WRITE_EXTERNAL_STORAGE (<= API 29)
- 조도 센서 / 마이크가 탑재된 실기기 사용 권장 (에뮬레이터는 조도 센서 미지원)

---

## 11. 문의

이슈 / 개선 제안은 저장소 Issues 탭에 남겨 주세요.
