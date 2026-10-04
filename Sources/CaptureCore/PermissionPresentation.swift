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
    public var titleKey:String { canCapture ? "permission.ready.title" : "permission.review.title" }
    public var explanationKey:String { canCapture ? "permission.ready.explanation" : "permission.review.explanation" }
    public var identityAdviceKey:String {
        switch signing {
        case .temporary:return "permission.signing.temporary"
        case .unknown:return "permission.signing.unknown"
        case .nonAdHoc:return "permission.signing.nonadhoc"
        }
    }
    public var title:String { canCapture ? "● Ready to capture" : "● Screen Recording access needs review" }
    public var explanation:String {
        canCapture ? "Screen Recording access is effective for this running copy of ShotClip. Choose a capture mode below." : "Screen Recording access is not effective for this running copy of ShotClip. The app cannot distinguish access not yet requested, denied access, or a pending restart."
    }
    public var identityAdvice:String {
        switch signing {
        case .temporary:return "This preview uses a temporary ad-hoc signature. Rebuilding or replacing it may require granting access again. The new ShotClip identity needs its own grant; choose the app at the location below."
        case .unknown:return "The signature of this running copy could not be verified. If access is unavailable after replacement, check the app location below and grant access again."
        case .nonAdHoc:return "If access is unavailable after replacement, check the app location below. Another copy with the same name may have been granted access."
        }
    }
}
