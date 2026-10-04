import Foundation
import CryptoKit

func fail(_ message: String) -> Never { fputs(message + "\n", stderr); exit(1) }
let arguments = CommandLine.arguments
guard arguments.count == 6 else { fail("Expected mode, directory, commit, version, public key") }
let mode = arguments[1], directory = URL(fileURLWithPath: arguments[2]), commit = arguments[3], version = arguments[4], key = arguments[5]
let environment = ProcessInfo.processInfo.environment
let build = environment["SHOTCLIP_BUILD_NUMBER"] ?? "6"
let releaseMode = environment["SHOTCLIP_RELEASE_MODE"] ?? ""
guard ["create", "verify"].contains(mode), ["ad-hoc", "developer-id"].contains(releaseMode),
      commit.range(of: "^[0-9a-f]{40}$", options: .regularExpression) != nil,
      version.range(of: "^[0-9]+\\.[0-9]+\\.[0-9]+$", options: .regularExpression) != nil,
      build.range(of: "^[1-9][0-9]*$", options: .regularExpression) != nil,
      let decodedKey = Data(base64Encoded: key), decodedKey.count == 32 else { fail("Invalid manifest mode, release mode, commit, version, build or public key") }
let publicKey = try Curve25519.Signing.PublicKey(rawRepresentation: decodedKey)
func read(_ name: String) throws -> Data {
    let url = directory.appendingPathComponent(name)
    guard try url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey]).isRegularFile == true,
          try url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink != true else { fail("Release asset must be a regular file: \(name)") }
    return try Data(contentsOf: url)
}
func digest(_ data: Data) -> String { SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined() }
let bytes = try read("shotclip-\(version).zip")
let feedBytes = try read("appcast.xml")

// Sparkle 2.10.0 common_cli/Signing.swift and SPUExtractSignedFeed.m define this block.
// Verify with the embedded public key only; publishing never needs Keychain access.
let prefix = Data("<!-- sparkle-signatures:\n".utf8)
guard let blockStart = feedBytes.range(of: prefix, options: .backwards),
      feedBytes[..<blockStart.lowerBound].range(of: prefix) == nil,
      let suffix = feedBytes.range(of: Data("-->".utf8), in: blockStart.upperBound..<feedBytes.endIndex),
      let trailing = String(data: feedBytes[suffix.upperBound...], encoding: .utf8), trailing.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
      let block = String(data: feedBytes[blockStart.upperBound..<suffix.lowerBound], encoding: .utf8) else { fail("Appcast is missing a single final Sparkle signing block") }
let content = Data(feedBytes[..<blockStart.lowerBound])
let lines = block.split(separator: "\n").map(String.init)
let signatureLines = lines.filter { $0.hasPrefix("edSignature:") }
let lengthLines = lines.filter { $0.hasPrefix("length:") }
guard signatureLines.count == 1, lengthLines.count == 1, lines.count == 2,
      let feedSignature = Data(base64Encoded: signatureLines[0].dropFirst("edSignature:".count).trimmingCharacters(in: .whitespaces)),
      feedSignature.count == 64,
      lengthLines[0].dropFirst("length:".count).trimmingCharacters(in: .whitespaces) == String(content.count),
      publicKey.isValidSignature(feedSignature, for: content) else { fail("Appcast Ed25519 signature or signed content length is invalid") }
guard let xml = String(data: content, encoding: .utf8), !xml.contains("<!DOCTYPE"), !xml.contains("<!ENTITY") else { fail("Appcast XML must not declare external entities") }
let feed = try XMLDocument(data: content, options: [.nodeLoadExternalEntitiesNever])
let namespace = "http://www.andymatuschak.org/xml-namespaces/sparkle"
let items = try feed.nodes(forXPath: "/rss/channel/item")
guard items.count == 1, let item = items.first as? XMLElement else { fail("Appcast must contain exactly one release item") }
func sparkleValue(_ name: String, expected: String) throws {
    let nodes = try feed.nodes(forXPath: "//*[local-name()='\(name)']")
    guard nodes.count == 1, let node = nodes.first as? XMLElement,
          node.parent === item, node.name == "sparkle:\(name)",
          node.resolveNamespace(forName: "sparkle:\(name)")?.stringValue == namespace,
          node.stringValue == expected else { fail("Appcast \(name) differs from reviewed release") }
}
try sparkleValue("version", expected: build)
try sparkleValue("shortVersionString", expected: version)
try sparkleValue("minimumSystemVersion", expected: "14.0")
let enclosures = try feed.nodes(forXPath: "//*[local-name()='enclosure']")
guard enclosures.count == 1, let enclosure = enclosures.first as? XMLElement, enclosure.parent === item,
      enclosure.name == "enclosure",
      enclosure.attribute(forName: "url")?.stringValue == "https://github.com/kyungseok-lee/shotclip/releases/download/v\(version)/shotclip-\(version).zip",
      enclosure.attribute(forName: "length")?.stringValue == String(bytes.count),
      enclosure.attribute(forName: "type")?.stringValue == "application/octet-stream",
      let signature = enclosure.attribute(forName: "sparkle:edSignature")?.stringValue,
      enclosure.resolveNamespace(forName: "sparkle:edSignature")?.stringValue == namespace,
      let decodedSignature = Data(base64Encoded: signature), decodedSignature.count == 64,
      publicKey.isValidSignature(decodedSignature, for: bytes) else { fail("Appcast archive Ed25519 signature, HTTPS URL, type or length is invalid") }
guard try feed.nodes(forXPath: "//*[local-name()='releaseNotesLink']").isEmpty else { fail("Use the verified release assets; external release notes are not part of this release format") }
let notes = try read("RELEASE-NOTES.md"), readme = try read("README.txt")
let status = releaseMode == "ad-hoc" ? "Ad-hoc signed; NOT notarized." : "Developer ID distribution;"
guard String(data: notes, encoding: .utf8)?.contains(status) == true, readme == notes else { fail("Bilingual release notes must state the actual distribution mode and match README") }
let record = ["schema": "2", "commit": commit, "version": version, "build": build,
              "publicKey": key, "releaseMode": releaseMode, "notarized": releaseMode == "ad-hoc" ? "false" : "true",
              "feedURL": "https://github.com/kyungseok-lee/shotclip/releases/latest/download/appcast.xml",
              "archiveSHA256": digest(bytes), "feedSHA256": digest(feedBytes), "releaseNotesSHA256": digest(notes), "readmeSHA256": digest(readme)]
let manifest = directory.appendingPathComponent("release-manifest.json")
if mode == "create" {
    guard !FileManager.default.fileExists(atPath: manifest.path) else { fail("Refusing to replace an existing release manifest") }
    try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys]).write(to: manifest, options: .atomic)
} else {
    guard let saved = try JSONSerialization.jsonObject(with: read("release-manifest.json")) as? [String: String], saved == record else { fail("Release manifest differs from reviewed source, distribution mode, version, key or asset hashes") }
    let checksums = [("shotclip-\(version).zip", bytes), ("appcast.xml", feedBytes), ("release-manifest.json", try read("release-manifest.json")), ("RELEASE-NOTES.md", notes), ("README.txt", readme)]
    let expectedChecksums = checksums.map { digest($0.1) + "  " + $0.0 + "\n" }.joined()
    guard try read("SHA256SUMS") == Data(expectedChecksums.utf8) else { fail("SHA256SUMS must contain exactly the verified release assets and hashes") }
    print(signature)
}
