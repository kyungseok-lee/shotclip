import Foundation
import CryptoKit

// Ephemeral synthetic signing key only; never reads or writes a user Keychain key.
let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
let key = Curve25519.Signing.PrivateKey()
let publicKey = key.publicKey.rawRepresentation.base64EncodedString()
let bytes = Data("synthetic archive".utf8)
let archive = directory.appendingPathComponent("sshot-0.2.1.zip")
try bytes.write(to: archive)
let signature = try key.signature(for: bytes).base64EncodedString()
let feed = directory.appendingPathComponent("appcast.xml")
func writeFeed(namespace: String = "http://www.andymatuschak.org/xml-namespaces/sparkle", build: String = "3", url: String = "https://github.com/kyungseok-lee/sshot/releases/download/v0.2.1/sshot-0.2.1.zip", signingValue: String? = nil) throws {
    let xml = """
    <?xml version="1.0"?><rss xmlns:sparkle="\(namespace)"><channel><item><sparkle:version>\(build)</sparkle:version><enclosure url="\(url)" length="\(bytes.count)" sparkle:edSignature="\(signingValue ?? signature)" /></item></channel></rss>
    """
    try Data(xml.utf8).write(to: feed)
}
func run(_ mode: String, commit: String = "reviewed") throws -> Int32 {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    task.arguments = ["scripts/release-manifest.swift", mode, directory.path, commit, "0.2.1", publicKey]
    task.standardOutput = FileHandle.nullDevice
    try task.run(); task.waitUntilExit(); return task.terminationStatus
}
func check(_ condition: Bool) { if !condition { fputs("FAIL: release verification regression\n", stderr); exit(1) } }
try writeFeed()
try check(run("create") == 0)
try check(run("verify") == 0)
try check(run("verify", commit: "unreviewed") != 0)
try Data("tampered archive".utf8).write(to: archive)
try check(run("verify") != 0)
try bytes.write(to: archive)
try writeFeed(namespace: "https://malicious.example")
try check(run("verify") != 0)
try writeFeed(build: "999")
try check(run("verify") != 0)
try writeFeed(url: "https://malicious.example/sshot.zip")
try check(run("verify") != 0)
try writeFeed(signingValue: Data(repeating: 0, count: 64).base64EncodedString())
try check(run("verify") != 0)
print("PASS: valid synthetic signature; reject commit mismatch, archive tamper, namespace mismatch, build mismatch, wrong URL and invalid signature")
