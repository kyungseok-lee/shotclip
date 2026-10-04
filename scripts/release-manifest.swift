import Foundation
import CryptoKit

func fail(_ message: String) -> Never { fputs(message + "\n", stderr); exit(1) }
let arguments = CommandLine.arguments
guard arguments.count == 6 else { fail("Expected mode, directory, commit, version, public key") }
let mode = arguments[1], directory = URL(fileURLWithPath: arguments[2]), commit = arguments[3], version = arguments[4], key = arguments[5]
let archive = directory.appendingPathComponent("sshot-\(version).zip")
let bytes = try Data(contentsOf: archive)
let digest = SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
let manifest = directory.appendingPathComponent("release-manifest.json")
if mode == "create" {
    let build = ProcessInfo.processInfo.environment["SSHOT_BUILD_NUMBER"] ?? "3"
    let record = ["commit": commit, "version": version, "build": build, "publicKey": key, "archiveSHA256": digest]
    try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys]).write(to: manifest, options: .atomic)
} else if mode == "verify" {
    let record = try JSONSerialization.jsonObject(with: Data(contentsOf: manifest)) as? [String: String]
    guard record?["commit"] == commit, record?["version"] == version, record?["publicKey"] == key, record?["archiveSHA256"] == digest else { fail("Release manifest does not match reviewed commit, version, key or archive") }
    let feed = try XMLDocument(contentsOf: directory.appendingPathComponent("appcast.xml"), options: [.nodeLoadExternalEntitiesNever])
    let enclosures = try feed.nodes(forXPath: "//enclosure")
    let versions = try feed.nodes(forXPath: "//*[local-name()='version']")
    guard versions.count == 1, let versionElement = versions.first as? XMLElement,
          versionElement.name == "sparkle:version",
          versionElement.resolveNamespace(forName: "sparkle:version")?.stringValue == "http://www.andymatuschak.org/xml-namespaces/sparkle",
          versionElement.stringValue == record?["build"] else { fail("Appcast build version differs from release manifest") }
    guard enclosures.count == 1, let enclosure = enclosures.first as? XMLElement,
          enclosure.attribute(forName: "url")?.stringValue == "https://github.com/kyungseok-lee/sshot/releases/download/v\(version)/sshot-\(version).zip",
          enclosure.attribute(forName: "length")?.stringValue == String(bytes.count),
          let signature = enclosure.attribute(forName: "sparkle:edSignature")?.stringValue,
          enclosure.resolveNamespace(forName: "sparkle:edSignature")?.stringValue == "http://www.andymatuschak.org/xml-namespaces/sparkle",
          let decodedSignature = Data(base64Encoded: signature), let decodedKey = Data(base64Encoded: key),
          try Curve25519.Signing.PublicKey(rawRepresentation: decodedKey).isValidSignature(decodedSignature, for: bytes) else { fail("Appcast enclosure signature, URL or length is invalid") }
    print(signature)
} else { fail("Unknown manifest mode") }
