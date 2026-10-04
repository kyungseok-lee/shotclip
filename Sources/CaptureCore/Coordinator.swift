import Foundation

@MainActor public final class CaptureCoordinator<Image> {
    public enum State { case idle, selecting, processing }
    public enum Entry { case opened, bringForward, ignored, permissionDenied }
    public private(set) var state: State = .idle
    private var session: UUID?
    private var stopTimeout: (() -> Void)?
    private var task: Task<Void,Never>?
    public var onFinish: (() -> Void)?
    public var onError: ((Error) -> Void)?
    public init() {}
    public func begin(permission: Bool) -> Entry {
        if state == .selecting { return .bringForward }
        if state == .processing { return .ignored }
        guard permission else { return .permissionDenied }
        session=UUID();state = .selecting;return .opened
    }
    public func cancel() { task?.cancel();task=nil;stopTimeout?();stopTimeout=nil;session=nil;state = .idle;onFinish?() }
    public func confirm(capture: @escaping () async throws -> Image, commit: @escaping (Image) throws -> Void, schedule: (@escaping () -> Void) -> (() -> Void)) {
        guard state == .selecting,let id=session else { return }
        state = .processing
        stopTimeout=schedule { [weak self] in
            guard let self,self.session == id else { return };self.cancel();self.onError?(CoordinatorError.timeout)
        }
        task=Task { @MainActor [weak self] in
            do {
                let image=try await capture()
                guard let self,self.session == id else { return }
                try commit(image);self.cancel()
            } catch {
                guard let self,self.session == id else { return }
                self.cancel();self.onError?(error)
            }
        }
    }
}
public enum CoordinatorError: LocalizedError {
    case timeout
    public var localizationKey: String { "capture.timeout" }
    public var errorDescription: String? { "Capture timed out. Try again." }
}
