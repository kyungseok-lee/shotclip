import Foundation
import CryptoKit

// Ephemeral synthetic signing key only; never reads or writes a user Keychain key.
let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
defer { try? FileManager.default.removeItem(at: directory) }
let key = Curve25519.Signing.PrivateKey()
let publicKey = key.publicKey.rawRepresentation.base64EncodedString()
let bytes = Data("synthetic archive".utf8)
let archive = directory.appendingPathComponent("shotclip-0.4.0.zip")
try bytes.write(to: archive)
let signature = try key.signature(for: bytes).base64EncodedString()
let feed = directory.appendingPathComponent("appcast.xml")
let commit = String(repeating: "a", count: 40)
let validURL = "https://github.com/kyungseok-lee/shotclip/releases/download/v0.4.0/shotclip-0.4.0.zip"
func writeFeed(namespace: String = "http://www.andymatuschak.org/xml-namespaces/sparkle", build: String = "5", version: String = "0.4.0", minimumOS: String = "14.0", url: String? = nil, signingValue: String? = nil, extra: String = "", signed: Bool = true, feedSignature: Data? = nil) throws {
    let xml = """
    <?xml version="1.0"?><rss xmlns:sparkle="\(namespace)"><channel><item><sparkle:version>\(build)</sparkle:version><sparkle:shortVersionString>\(version)</sparkle:shortVersionString><sparkle:minimumSystemVersion>\(minimumOS)</sparkle:minimumSystemVersion><enclosure url="\(url ?? validURL)" length="\(bytes.count)" type="application/octet-stream" sparkle:edSignature="\(signingValue ?? signature)" />\(extra)</item></channel></rss>
    """
    let content = Data((xml + "\n").utf8)
    let block = signed ? "<!-- sparkle-signatures:\nedSignature: \((try feedSignature ?? key.signature(for: content)).base64EncodedString())\nlength: \(content.count)\n-->\n" : ""
    try (content + Data(block.utf8)).write(to: feed)
}
func run(_ mode: String, source: String? = nil, releaseMode: String = "ad-hoc", build: String = "5") throws -> Int32 {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
    task.arguments = ["scripts/release-manifest.swift", mode, directory.path, source ?? commit, "0.4.0", publicKey]
    var environment = ProcessInfo.processInfo.environment
    environment["SHOTCLIP_BUILD_NUMBER"] = build
    environment["SHOTCLIP_RELEASE_MODE"] = releaseMode
    task.environment = environment
    task.standardOutput = FileHandle.nullDevice
    try task.run(); task.waitUntilExit(); return task.terminationStatus
}
func check(_ condition: Bool, _ label: String) { if !condition { fputs("FAIL: \(label)\n", stderr); exit(1) } }
func write(_ name: String, _ data: Data) throws { try data.write(to: directory.appendingPathComponent(name)) }
func checksums() throws {
    let names = ["shotclip-0.4.0.zip", "appcast.xml", "release-manifest.json", "RELEASE-NOTES.md", "README.txt"]
    let text = try names.map { name in
        SHA256.hash(data: try Data(contentsOf: directory.appendingPathComponent(name))).map { String(format: "%02x", $0) }.joined() + "  " + name + "\n"
    }.joined()
    try write("SHA256SUMS", Data(text.utf8))
}
let notes = Data("Ad-hoc signed; NOT notarized.\n한국어: 공증되지 않았습니다.\n".utf8)
try write("RELEASE-NOTES.md", notes); try write("README.txt", notes)
try writeFeed()
try check(run("create") == 0, "create valid ad-hoc manifest")
try checksums()
try check(run("verify") == 0, "verify valid ad-hoc release")
let baseline = try Dictionary(uniqueKeysWithValues: ["shotclip-0.4.0.zip", "appcast.xml", "release-manifest.json", "RELEASE-NOTES.md", "README.txt", "SHA256SUMS"].map { ($0, try Data(contentsOf: directory.appendingPathComponent($0))) })
func reset() throws { for (name, data) in baseline { try write(name, data) } }
var rejected = 0
func reject(_ label: String, mutate: () throws -> Void) throws {
    try reset(); try mutate(); try check(run("verify") != 0, label); rejected += 1
}
try check(run("verify", source: String(repeating: "b", count: 40)) != 0, "commit mismatch"); rejected += 1
try reject("archive tamper") { try write("shotclip-0.4.0.zip", Data("tampered archive".utf8)) }
try reject("namespace mismatch") { try writeFeed(namespace: "https://malicious.example") }
try reject("build mismatch") { try writeFeed(build: "999") }
try reject("short version mismatch") { try writeFeed(version: "9.9.9") }
try reject("minimum OS mismatch") { try writeFeed(minimumOS: "13.0") }
try reject("wrong HTTPS URL") { try writeFeed(url: "https://malicious.example/shotclip.zip") }
try reject("insecure URL") { try writeFeed(url: validURL.replacingOccurrences(of: "https:", with: "http:")) }
try reject("invalid archive signature") { try writeFeed(signingValue: Data(repeating: 0, count: 64).base64EncodedString()) }
try reject("unsigned feed") { try writeFeed(signed: false) }
try reject("invalid feed signature") { try writeFeed(feedSignature: Data(repeating: 0, count: 64)) }
try reject("feed tamper") { try write("appcast.xml", baseline["appcast.xml"]! + Data("tampered".utf8)) }
try reject("duplicate version") { try writeFeed(extra: "<sparkle:version>5</sparkle:version>") }
try reject("external notes") { try writeFeed(extra: "<sparkle:releaseNotesLink>https://malicious.example/notes</sparkle:releaseNotesLink>") }
try reject("notes tamper") { try write("RELEASE-NOTES.md", notes + Data("tampered".utf8)) }
try reject("misleading notarized notes") { try write("RELEASE-NOTES.md", Data("Developer ID distribution; notarized".utf8)) }
try reject("checksum tamper/path injection") { try write("SHA256SUMS", baseline["SHA256SUMS"]! + Data((String(repeating: "0", count: 64) + "  ../outside\n").utf8)) }
for field in ["commit", "publicKey", "releaseMode", "notarized", "archiveSHA256", "feedSHA256"] {
    try reject("manifest \(field) tamper") {
        var record = try JSONSerialization.jsonObject(with: baseline["release-manifest.json"]!) as! [String: String]
        record[field] = "tampered"
        try write("release-manifest.json", JSONSerialization.data(withJSONObject: record, options: [.sortedKeys]))
    }
}
try reset()
try check(run("create") != 0, "existing manifest is never replaced"); rejected += 1
try check(run("verify", releaseMode: "development") != 0, "development cannot publish"); rejected += 1
try FileManager.default.removeItem(at: directory.appendingPathComponent("release-manifest.json"))
let developerNotes = Data("Developer ID distribution;\n한국어: Developer ID 배포\n".utf8)
try write("RELEASE-NOTES.md", developerNotes); try write("README.txt", developerNotes)
try check(run("create", releaseMode: "developer-id") == 0, "create developer-id manifest")
try checksums()
try check(run("verify", releaseMode: "developer-id") == 0, "verify developer-id manifest")
print("PASS: valid synthetic signed archive/feed in both modes; \(rejected) tamper and policy rejection cases; no Keychain access")
