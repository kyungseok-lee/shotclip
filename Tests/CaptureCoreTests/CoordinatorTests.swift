import XCTest
@testable import CaptureCore
@MainActor final class CoordinatorTests: XCTestCase {
    private func wait(_ condition: () -> Bool) async {
        let deadline=Date().addingTimeInterval(2)
        while !condition(),Date() < deadline { await Task.yield() }
        XCTAssertTrue(condition(),"Coordinator did not reach expected state")
    }
    func testPermissionAndReentry() {
        let c=CaptureCoordinator<Int>()
        XCTAssertEqual(c.begin(permission:false),.permissionDenied);XCTAssertEqual(c.state,.idle)
        XCTAssertEqual(c.begin(permission:true),.opened);XCTAssertEqual(c.begin(permission:true),.bringForward)
    }
    func testCancelLateResultAndFreshSession() async {
        let c=CaptureCoordinator<Int>();var completion:CheckedContinuation<Int,Error>?;var writes=[Int]()
        _=c.begin(permission:true)
        c.confirm(capture:{try await withCheckedThrowingContinuation {completion=$0}},commit:{writes.append($0)},schedule:{_ in {}})
        await wait {completion != nil};XCTAssertEqual(c.begin(permission:true),.ignored)
        c.cancel();_=c.begin(permission:true)
        completion?.resume(returning:7)
        c.confirm(capture:{9},commit:{writes.append($0)},schedule:{_ in {}});await wait {c.state == .idle}
        XCTAssertEqual(writes,[9]);XCTAssertEqual(c.state,.idle)
    }
    func testTimeoutAndLateResult() async {
        let c=CaptureCoordinator<Int>();var completion:CheckedContinuation<Int,Error>?;var fire:(()->Void)?;var writes=0;var errors=0
        c.onError={_ in errors+=1};_=c.begin(permission:true)
        c.confirm(capture:{try await withCheckedThrowingContinuation {completion=$0}},commit:{_ in writes+=1},schedule:{fire=$0;return {}})
        await wait {completion != nil};fire?();completion?.resume(returning:1);await wait {c.state == .idle}
        XCTAssertEqual(errors,1);XCTAssertEqual(writes,0);XCTAssertEqual(c.state,.idle)
    }
    func testCancelPropagatesToCaptureTask() async {
        let c=CaptureCoordinator<Int>();var started=false;var cancelled=false;var writes=0
        _=c.begin(permission:true)
        c.confirm(capture:{
            started=true
            do { try await Task.sleep(nanoseconds:30_000_000_000);return 1 }
            catch { cancelled=Task.isCancelled;throw error }
        },commit:{_ in writes+=1},schedule:{_ in {}})
        await wait {started};c.cancel();await wait {cancelled}
        XCTAssertEqual(c.state,.idle);XCTAssertEqual(writes,0)
    }
    func testCaptureAndCommitErrorsRecover() async {
        let c=CaptureCoordinator<Int>();var errors=0;var writes=0;c.onError={_ in errors+=1}
        _=c.begin(permission:true);c.confirm(capture:{throw CoordinatorError.timeout},commit:{_ in writes+=1},schedule:{_ in {}});await wait {c.state == .idle}
        XCTAssertEqual(c.state,.idle);XCTAssertEqual(writes,0)
        _=c.begin(permission:true);c.confirm(capture:{1},commit:{_ in throw CoordinatorError.timeout},schedule:{_ in {}});await wait {c.state == .idle}
        XCTAssertEqual(c.state,.idle);XCTAssertEqual(errors,2)
    }
}
