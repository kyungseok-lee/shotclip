import Foundation

public struct UpdateConfiguration: Equatable {
    public let feedURL: URL
    public let publicKey: Data
    public init?(feed: String?, publicKey: String?) {
        guard let feed, let url = URL(string: feed), url.scheme == "https",
              let host = url.host, !host.isEmpty, url.user == nil, url.password == nil,
              let publicKey, let decoded = Data(base64Encoded: publicKey), decoded.count == 32 else { return nil }
        feedURL = url
        self.publicKey = decoded
    }
}
