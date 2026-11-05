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

**모든 데이터는 기기의 Documents 디렉터리에 JSON으로 저장됩니다.** 외부 데이터베이스, 네트워크 요청, 트래킹 SDK 등이 일절 없습니다.

---

## 라이선스

개인 프로젝트. 배포 금지.
