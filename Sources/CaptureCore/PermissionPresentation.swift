public struct PermissionPresentation {
    public enum State: Equatable { case ready, reviewNeeded }
    public enum Signing: Equatable { case temporary, nonAdHoc, unknown }
    public let state:State
    public let signing:Signing
    public init(accessEffective:Bool,adHoc:Bool?) {
        state=accessEffective ? .ready : .reviewNeeded
        signing=adHoc.map{$0 ? .temporary : .nonAdHoc} ?? .unknown
    }
    public var canCapture:Bool {state == .ready}
    public var title:String { canCapture ? "● 캡처 준비 완료" : "● 화면 기록 권한 확인 필요" }
    public var explanation:String {
        canCapture ? "현재 실행 중인 sshot에 화면 기록 권한이 적용되어 있습니다. 아래에서 캡처 방식을 선택하세요." : "현재 실행 중인 sshot에는 화면 기록 권한이 적용되지 않았습니다. 허용 전·권한 거부·재시작 대기 중 어느 상태인지는 자동으로 구분할 수 없습니다."
    }
    public var identityAdvice:String {
        switch signing {
        case .temporary:return "개발용 임시 서명 앱입니다. 앱을 다시 빌드하거나 교체하면 macOS에서 새 실행 파일로 판단해 권한을 다시 허용해야 할 수 있습니다. 설정의 이름만 보지 말고 아래 실행 위치의 앱을 선택하세요."
        case .unknown:return "이 실행 파일의 서명을 확인하지 못했습니다. 앱을 교체한 뒤 권한이 적용되지 않으면 아래 실행 위치를 확인하고 다시 허용하세요."
        case .nonAdHoc:return "앱 교체 후 권한이 적용되지 않으면 아래 실행 위치를 확인하세요. 동일한 이름의 다른 사본에 권한을 주었을 수 있습니다."
        }
    }
}
