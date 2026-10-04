import XCTest
@testable import CaptureCore

final class UpdateConfigurationTests: XCTestCase {
    private let key = Data(repeating: 7, count: 32).base64EncodedString()
    func testUnconfiguredAndInvalidFeedNeverEnableUpdates() {
        for feed in [nil, "", "http://updates.example.com/appcast.xml", "https://", "https://user:password@updates.example.com/appcast.xml"] as [String?] {
            XCTAssertNil(UpdateConfiguration(feed: feed, publicKey: key))
        }
    }
    func testInvalidKeysNeverEnableUpdates() {
        for invalid in [nil, "", "%%%", Data(repeating: 1, count: 31).base64EncodedString(), Data(repeating: 1, count: 33).base64EncodedString()] as [String?] {
            XCTAssertNil(UpdateConfiguration(feed: "https://updates.example.com/appcast.xml", publicKey: invalid))
        }
    }
    func testHTTPSAndEd25519KeyAcceptsConfiguredFeed() {
        let configuration = UpdateConfiguration(feed: "https://updates.example.com/appcast.xml", publicKey: key)
        XCTAssertEqual(configuration?.feedURL.absoluteString, "https://updates.example.com/appcast.xml")
        XCTAssertEqual(configuration?.publicKey.count, 32)
    }
}
