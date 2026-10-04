# GitHub Releases 업데이트 운영

사용자의 공개 GitHub 배포 요청에 따라 별도 서버 없이 `kyungseok-lee/sshot`의 GitHub Releases를 사용합니다. GitHub Pages는 필요하지 않습니다. 아래는 운영 설계이며 실제 공개 asset 존재·업그레이드 성공은 QA 기록으로 따로 확인합니다.

| 대상 | 경로 |
| --- | --- |
| 앱 내 고정 feed | `https://github.com/kyungseok-lee/sshot/releases/latest/download/appcast.xml` |
| 버전 archive | `https://github.com/kyungseok-lee/sshot/releases/download/v버전/sshot-버전.zip` |
| 공개키 | 앱 Info.plist의 SUPublicEDKey, 개인 키는 Keychain |

고정 feed URL은 최신 공개 release로 이동하므로 매 release에 정확한 `appcast.xml`을 포함해야 합니다. feed 안의 archive URL은 해당 release tag에 고정합니다. draft는 공개 feed로 제공되지 않습니다. 버전 및 build 번호를 증가시키고, feed의 URL·서명·파일 길이·지원 OS와 artifact를 일치시킵니다.

## 배포 순서와 gate

1. 승인된 변경을 코드 검토·빠른 자동 검증 후 commit·push합니다. 캡처 수동 QA는 사용자가 인수하며 코드 push와 공개 앱 배포는 구분합니다. 공개 배포 시 tag가 가리키는 commit과 원격 commit, 빌드에 사용한 commit이 동일한지 확인합니다. dirty worktree나 다른 commit의 artifact를 release하지 않습니다.
2. Developer ID Application 인증서와 기존 notarytool profile을 준비합니다. Ed25519 개인 키는 Keychain에서 유지하고 공개키만 빌드에 주입합니다. 개발용 ad-hoc 앱은 공개 production 배포 gate를 충족하지 않습니다.
3. `scripts/prepare-update.sh`로 서명·공증·staple·검증한 archive와 서명된 appcast를 준비합니다. 이 단계는 key 생성이나 게시를 하지 않습니다.
4. 저장소·tag·target commit과 asset을 검증한 뒤 **draft release**를 생성합니다. `scripts/publish-github-release.sh`는 clean worktree, 현재 HEAD와 로컬·원격 tag commit 일치, production 서명·공증, feed의 archive URL·서명 필드를 확인하고 `--verify-tag --draft`로 생성합니다. tag가 미리 정확한 commit에 push되어 있어야 합니다.
5. draft asset을 내려받아 서명·공증·feed archive URL·버전·길이를 확인합니다. 깨끗한 사용자 환경의 Gatekeeper·권한·캡처 QA, 이전 버전에서 새 버전으로 실제 Sparkle 업데이트와 설정/권한 회귀를 확인합니다.
6. production gate를 만족한 draft만 명시적으로 publish합니다. 인증서·공증·실제 캡처 gate가 없으면 공개 배포하지 않고 미완료 상태를 기록합니다.

```sh
SSHOT_SIGN_IDENTITY='Developer ID Application: Your Name (TEAMID)' \
SSHOT_NOTARY_PROFILE='your-existing-profile' \
SSHOT_RELEASE_TEAM_ID='YOURTEAMID' \
bash scripts/prepare-github-release.sh
SSHOT_RELEASE_TEAM_ID='YOURTEAMID' \
bash scripts/publish-github-release.sh 0.3.0 dist/update-0.3.0.실제출력값
```

준비 스크립트는 기본 0.3.0(build 4)과 저장소의 공개키를 사용합니다. `SSHOT_RELEASE_TEAM_ID`는 실제 Developer ID 서명의 Team ID와 일치해야 합니다. publisher는 archive·appcast·SHA256SUMS·release-manifest.json을 업로드하며 기본은 draft입니다. manifest의 commit/build/key/archive hash와 앱의 봉인된 SSHOTSourceCommit을 HEAD에 연결하고, 로컬·원격·GitHub 저장소 tag 일치, archive Ed25519 및 signed feed 검증을 수행합니다. 세 번째 인자 `--publish`는 검증 후 공개하는 명시적 경로입니다. 이미 생성한 draft를 공개할 때에는 해당 draft의 target·asset과 QA를 재확인한 뒤 `gh release edit v0.3.0 --repo kyungseok-lee/sshot --draft=false --latest`를 사용합니다. 이 예제는 현재 실행·게시 완료 증거가 아닙니다.

## 서로 다른 서명의 역할

Developer ID와 notarization은 macOS 신뢰·Gatekeeper 및 앱 identity에 관련됩니다. 같은 앱 식별자와 Developer ID를 유지하면 개발 ad-hoc 교체로 인한 반복 TCC 허용 문제를 줄이지만 권한 재요청이 전혀 없다고 보장할 수 없습니다.

Sparkle Ed25519 서명은 업데이트 archive 변조 여부를 검사합니다. 공개키를 앱에 넣었거나 개인 키를 생성했다는 사실만으로 Gatekeeper·화면 기록 권한·실제 업데이트 성공이 증명되지 않습니다. 개인 키와 인증정보를 로그·저장소·release asset에 넣지 않습니다. 키 변경은 기존 버전의 신뢰 연결을 검토해야 하므로 임의로 새 키를 만들어 교체하지 않습니다.

## 현재 상태

Keychain account `sshot`에 Ed25519 키를 생성했고 개인 키는 export하지 않았습니다. 공개키와 GitHub stable feed를 포함한 0.2.1(build 3)을 로컬 빌드·서명 검사 후 `/Applications/sshot.app`에 설치했습니다. 설정된 updater 상태와 기본 OFF인 자동 확인 toggle을 실제 UI에서 확인했습니다. Keychain 승인 후 로컬 테스트 archive/appcast 생성, 공식 `sign_update --verify` 및 공개키 기반 manifest/archive 암호 검증이 통과했습니다. 이 artifact는 ad-hoc·미커밋 작업의 로컬 QA용이며 production release가 아닙니다.

설치 앱의 업데이트 확인에서 실제 네트워크 조회를 시작했고 Sparkle 로그는 현재 canonical feed의 HTTP 404를 보고했습니다. 공개 asset이 없으므로 정상 업데이트를 받을 수 없는 상태입니다. 최종 오류 UI는 확인하지 않았으며 앱은 살아 있고 새 crash는 관찰되지 않았습니다. Developer ID 인증서가 없는 현재 환경에서는 production 배포·종단간 업데이트 완료를 주장하지 않습니다. 공개 release·asset·feed는 게시하지 않았습니다.
