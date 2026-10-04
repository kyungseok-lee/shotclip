import XCTest
import CoreGraphics
@testable import CaptureCore
final class CoreTests: XCTestCase {
    func testAllDragDirectionsSelectIdenticalRegion() {
        let bounds = CGRect(x: -100, y: -100, width: 200, height: 200)
        let pairs: [(CGPoint, CGPoint)] = [
            (CGPoint(x: -40, y: -30), CGPoint(x: 60, y: 50)),
            (CGPoint(x: 60, y: 50), CGPoint(x: -40, y: -30)),
            (CGPoint(x: -40, y: 50), CGPoint(x: 60, y: -30)),
            (CGPoint(x: 60, y: -30), CGPoint(x: -40, y: 50))
        ]
        for (start, end) in pairs {
            XCTAssertEqual(SelectionGeometry.rect(from: start, to: end, within: bounds), CGRect(x: -40, y: -30, width: 100, height: 80))
        }
    }
    func testEveryResizeCornerKeepsOppositeAnchorAndClamps() {
        let rect = CGRect(x: 20, y: 20, width: 40, height: 40)
        let bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        let cases: [(SelectionGeometry.Corner, CGSize, CGRect, CGSize, CGRect)] = [
            (.bottomLeft, CGSize(width: -100, height: -100), CGRect(x: 0, y: 0, width: 60, height: 60), CGSize(width: 100, height: 100), CGRect(x: 50, y: 50, width: 10, height: 10)),
            (.bottomRight, CGSize(width: 100, height: -100), CGRect(x: 20, y: 0, width: 80, height: 60), CGSize(width: -100, height: 100), CGRect(x: 20, y: 50, width: 10, height: 10)),
            (.topLeft, CGSize(width: -100, height: 100), CGRect(x: 0, y: 20, width: 60, height: 80), CGSize(width: 100, height: -100), CGRect(x: 50, y: 20, width: 10, height: 10)),
            (.topRight, CGSize(width: 100, height: 100), CGRect(x: 20, y: 20, width: 80, height: 80), CGSize(width: -100, height: -100), CGRect(x: 20, y: 20, width: 10, height: 10))
        ]
        for (corner, outward, expanded, inward, reduced) in cases {
            XCTAssertEqual(SelectionGeometry.resized(rect, corner: corner, by: outward, within: bounds, minimumSize: 10), expanded)
            XCTAssertEqual(SelectionGeometry.resized(rect, corner: corner, by: inward, within: bounds, minimumSize: 10), reduced)
        }
    }
    func testFractionalRetinaSelectionRoundsOutward() {
        let screen = CGRect(x: -100, y: -50, width: 100, height: 100)
        let rect = CGRect(x: -89.8, y: -39.8, width: 20.1, height: 20.1)
        XCTAssertEqual(SelectionGeometry.snappedCaptureRect(rect, screen: screen, scale: 2), CGRect(x: 10, y: 69.5, width: 20.5, height: 20.5))
        XCTAssertEqual(SelectionGeometry.snappedCaptureRect(rect, screen: screen, scale: 1), CGRect(x: 10, y: 69, width: 21, height: 21))
        XCTAssertNil(SelectionGeometry.snappedCaptureRect(rect, screen: screen, scale: 0))
    }
    func testNonfiniteSelectionIsRejected() {
        XCTAssertFalse(SelectionGeometry.valid(CGRect(x: CGFloat.nan, y: 0, width: 10, height: 10)))
        XCTAssertTrue(SelectionGeometry.rect(from: CGPoint(x: CGFloat.infinity, y: 0), to: .zero, within: CGRect(x: 0, y: 0, width: 100, height: 100)).isNull)
    }
    func testTranslationPreservesSizeAtDisplayBoundary() {
        XCTAssertEqual(SelectionGeometry.translated(CGRect(x: 10, y: 20, width: 40, height: 30), by: CGSize(width: 100, height: -100), within: CGRect(x: 0, y: 0, width: 100, height: 100)), CGRect(x: 60, y: 0, width: 40, height: 30))
    }
    func testResizePreservesOppositeCornerAndMinimumSize() {
        let rect = CGRect(x: 20, y: 20, width: 40, height: 40)
        let bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        XCTAssertEqual(SelectionGeometry.resized(rect, corner: .bottomLeft, by: CGSize(width: 100, height: -100), within: bounds, minimumSize: 10), CGRect(x: 50, y: 0, width: 10, height: 60))
        XCTAssertEqual(SelectionGeometry.resized(rect, corner: .topRight, by: CGSize(width: 100, height: 100), within: bounds), CGRect(x: 20, y: 20, width: 80, height: 80))
    }
    func testClipboardChangedAfterSnapshotNeverClears() {
        var cleared = false
        let result = ClipboardTransaction.commitResult(snapshot: [], expectedGeneration: 2, clear: { cleared = true; return 4 }, write: { _ in true }, count: { 3 }, image: [])
        XCTAssertEqual(result, .externalChange); XCTAssertFalse(cleared)
    }
    func testClipboardRollbackFailureIsDistinct() {
        var generation = 2
        let result = ClipboardTransaction.commitResult(snapshot: [["text": Data([1])]], clear: { generation += 1; return generation }, write: { _ in false }, count: { generation }, image: [["image": Data([2])]])
        XCTAssertEqual(result, .rollbackFailed)
    }
    func testClipboardRollbackDoesNotOverwriteExternalChangeAfterClear() {
        var generation = 2; var clearCalls = 0; var writes = 0
        let result = ClipboardTransaction.commitResult(snapshot: [["text": Data([1])]], clear: { clearCalls += 1; generation += 1; let owned = generation; if clearCalls == 2 { generation += 1 }; return owned }, write: { _ in writes += 1; return false }, count: { generation }, image: [["image": Data([2])]])
        XCTAssertEqual(result, .externalChange); XCTAssertEqual(writes, 1)
    }
    func testClipboardSuccessLostToExternalChangeIsNotReportedSuccessful() {
        var generation = 2
        let result = ClipboardTransaction.commitResult(snapshot: [], clear: { generation += 1; return generation }, write: { _ in generation += 1; return true }, count: { generation }, image: [])
        XCTAssertEqual(result, .externalChange)
    }
    func testNegativeOriginAndFlippedCoordinates() {
        let screen=CGRect(x:-1920,y:-200,width:1920,height:1080)
        let rect=SelectionGeometry.rect(from:CGPoint(x:-100,y:100),to:CGPoint(x:-300,y:300),within:screen)
        XCTAssertEqual(rect,CGRect(x:-300,y:100,width:200,height:200))
        XCTAssertEqual(SelectionGeometry.captureRect(rect,screen:screen),CGRect(x:1620,y:580,width:200,height:200))
    }
    func testClampAndZeroSize() {
        XCTAssertFalse(SelectionGeometry.valid(SelectionGeometry.rect(from:.zero,to:.zero,within:CGRect(x:0,y:0,width:100,height:100))))
        XCTAssertEqual(SelectionGeometry.rect(from:CGPoint(x:20,y:20),to:CGPoint(x:120,y:80),within:CGRect(x:0,y:0,width:100,height:100)).width,80)
    }
    func testSessionInvalidatesLateResult() {
        var gate=SessionGate(); let first=gate.begin()!; XCTAssertNil(gate.begin()); gate.end(); let second=gate.begin()!; XCTAssertFalse(gate.accepts(first)); XCTAssertTrue(gate.accepts(second))
    }
    func testClipboardRollback() {
        var generation=3; var value=[["text":Data([1])]]; let previous=value
        let result=ClipboardTransaction.commit(snapshot:previous,clear:{generation+=1;value=[];return generation},write:{items in if items.first?["image"] != nil { return false };value=items;return true},count:{generation},image:[["image":Data([2])]])
        XCTAssertFalse(result); XCTAssertEqual(value,previous)
    }
    func testClipboardExternalWriteIsNotOverwritten() {
        var generation=3; var value=[["text":Data([1])]]
        let result=ClipboardTransaction.commit(snapshot:value,clear:{generation+=1;value=[];return generation},write:{_ in generation+=1;value=[["external":Data([3])]];return false},count:{generation},image:[["image":Data([2])]])
        XCTAssertFalse(result); XCTAssertEqual(value,[["external":Data([3])]])
    }
}
