import Foundation

let path = CommandLine.arguments[1]
let environment = ProcessInfo.processInfo.environment
let data = try Data(contentsOf: URL(fileURLWithPath: path))
var plist = try PropertyListSerialization.propertyList(from: data, format: nil) as! [String: Any]
let override = environment["SHOTCLIP_UPDATE_FEED_URL"] != nil || environment["SHOTCLIP_UPDATE_PUBLIC_KEY"] != nil
let feed = override ? environment["SHOTCLIP_UPDATE_FEED_URL"] ?? "" : plist["SUFeedURL"] as? String ?? ""
let key = override ? environment["SHOTCLIP_UPDATE_PUBLIC_KEY"] ?? "" : plist["SUPublicEDKey"] as? String ?? ""
if !feed.isEmpty || !key.isEmpty {
    guard let url = URL(string: feed), url.scheme == "https", url.host != nil,
          url.user == nil, url.password == nil, Data(base64Encoded: key)?.count == 32 else {
        fputs("Both a valid HTTPS SHOTCLIP_UPDATE_FEED_URL and 32-byte base64 SHOTCLIP_UPDATE_PUBLIC_KEY are required.\n", stderr)
        exit(1)
    }
    plist["SUFeedURL"] = feed
    plist["SUPublicEDKey"] = key
}
plist["SUEnableAutomaticChecks"] = false
plist["SUAutomaticallyUpdate"] = false
plist["SUAllowsAutomaticUpdates"] = false
plist["SUVerifyUpdateBeforeExtraction"] = true
plist["SURequireSignedFeed"] = true
// Zero never expires a failed signed-feed policy into Sparkle's safe mode.
plist["SUSignedFeedFailureExpirationInterval"] = 0
try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0).write(to: URL(fileURLWithPath: path), options: .atomic)
