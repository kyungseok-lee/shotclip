import XCTest
@testable import CaptureCore
final class PermissionTests:XCTestCase {
    func testOnlyEffectiveAccessEnablesCapture() {
        for signing in [true,false,nil] as [Bool?] {
            XCTAssertTrue(PermissionPresentation(accessEffective:true,adHoc:signing).canCapture)
            let notReady=PermissionPresentation(accessEffective:false,adHoc:signing)
            XCTAssertEqual(notReady.state,.reviewNeeded);XCTAssertFalse(notReady.canCapture)
            XCTAssertTrue(notReady.explanation.contains("자동으로 구분할 수 없습니다"))
        }
    }
    func testSigningDoesNotImplyPermission() {
        let temporary=PermissionPresentation(accessEffective:true,adHoc:true)
        XCTAssertEqual(temporary.signing,.temporary);XCTAssertEqual(temporary.state,.ready)
        XCTAssertTrue(temporary.identityAdvice.contains("다시 허용"))
        let signed=PermissionPresentation(accessEffective:false,adHoc:false)
        XCTAssertEqual(signed.signing,.nonAdHoc);XCTAssertEqual(signed.state,.reviewNeeded)
        let unknown=PermissionPresentation(accessEffective:false,adHoc:nil)
        XCTAssertEqual(unknown.signing,.unknown);XCTAssertTrue(unknown.identityAdvice.contains("확인하지 못했습니다"))
    }
}
