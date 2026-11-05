# FP Meter

iOS 전용 Function Point (기능 점수) 계산기. SwiftUI로 작성.

## 특징

- **IFPUG 4.3.1** 복잡도 매트릭스 (ILF, EIF, EI, EO, EQ 전체)
- **VAF (Value Adjustment Factor)** — 14개 GSC 기반 조정
- **맨먼스(Man-Month) 추정** — 3단계 생산성 범위
- **프로젝트/트랜잭션 복제** — 길게 눌러서 사용
- **Quick Add 템플릿** — CRUD / 인증 / 보고 모듈 프리셋
- **다국어** — English / 한국어 / 日本語 (시스템 언어 자동 감지 + 수동 전환)
- **햅틱 피드백** — 복잡도 변화 시 진동
- **완전 오프라인** — 기기에만 저장, 서버 전송 없음
- **네이티브 SwiftUI** — npm install / CocoaPods 필요 없음

---

## Xcode에서 여는 방법

1. zip 압축 해제
2. **`FPMeter.xcodeproj` 더블클릭**
3. Xcode가 열리면 상단 툴바에서 시뮬레이터 (예: iPhone 15 Pro) 선택
4. **▶️ (재생) 버튼** 또는 **⌘R** 누르기

그게 끝이에요. `npm install`, `pod install`, Ruby, Node.js — **전부 필요 없음**.

## 요구 사항

- macOS 13 이상
- Xcode 15 이상
- iOS 16 이상 (시뮬레이터 또는 실제 기기)

---

## 앱스토어 제출

### 1. 개발자 계정
Apple Developer Program ($99/년)에 가입: https://developer.apple.com/programs/

### 2. Xcode에서 서명 설정
1. `FPMeter.xcodeproj`를 열고 프로젝트 네비게이터에서 **FPMeter** 클릭
2. **TARGETS → FPMeter → Signing & Capabilities** 탭
3. **Team** 드롭다운에서 본인 Apple 팀 선택
4. **Bundle Identifier**가 `com.fpmeter.app`인지 확인 (필요 시 고유한 값으로 변경)

### 3. 아카이브 및 업로드
1. 상단 타겟 기기를 **Any iOS Device (arm64)** 로 변경
2. **Product → Archive**
3. 완료 후 열리는 Organizer에서 **Distribute App → App Store Connect → Upload**

### 4. App Store Connect
https://appstoreconnect.apple.com 에 가서:
- 앱 기본 정보 입력 (카테고리: Developer Tools)
- 스크린샷 업로드 (iPhone 6.7" / 6.5" / iPad 12.9")
- 설명 입력 (3개 언어 모두 지원 — 앱이 `CFBundleLocalizations`에 en/ko/ja 선언됨)
- 개인정보처리방침 URL (필수)
- **App Privacy**: "Data Not Collected" 선택 (이 앱은 로컬 저장만 함)
- Export Compliance: Info.plist에 `ITSAppUsesNonExemptEncryption: false`로 이미 선언됨
- **제출**

---

## 프로젝트 구조

```
FPMeter/
├── FPMeter.xcodeproj/         # Xcode 프로젝트
├── FPMeter/
│   ├── FPMeterApp.swift       # @main 진입점
│   ├── AppState.swift         # 전역 상태 (ObservableObject)
│   ├── Info.plist
│   ├── Assets.xcassets
│   ├── Models/
│   │   ├── Transaction.swift
│   │   ├── Project.swift      # GSC 정의 포함
│   │   └── Evaluation.swift
│   ├── Services/
│   │   ├── ComplexityService.swift      # IFPUG 3개 매트릭스
│   │   ├── FPCalculatorService.swift    # VAF/AFP 계산
│   │   ├── MMEstimatorService.swift     # 맨먼스 추정
│   │   ├── QuickAddService.swift        # 템플릿 번들
│   │   └── HapticsService.swift
│   ├── Persistence/
│   │   ├── PersistentStore.swift        # Codable + FileManager
│   │   └── AppSettings.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── DashboardView.swift          # 프로젝트 목록
│   │   ├── ProjectViews.swift           # 상세 + VAF 탭
│   │   ├── TransactionFormView.swift    # 라이브 복잡도 프리뷰
│   │   ├── ResultView.swift             # FP 결과 + M/M
│   │   ├── GlossaryView.swift           # 13개 용어 + 매트릭스
│   │   ├── SettingsView.swift
│   │   └── Theme.swift
│   └── Resources/
│       ├── en.lproj/Localizable.strings
│       ├── ko.lproj/Localizable.strings
│       └── ja.lproj/Localizable.strings
```

**모든 데이터는 기기의 Documents 디렉터리에 JSON으로 저장됩니다.** 외부 데이터베이스, 네트워크 요청, 트래킹 SDK 등이 일절 없습니다.

---

## 라이선스

개인 프로젝트. 배포 금지.
