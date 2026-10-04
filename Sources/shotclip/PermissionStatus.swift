import AppKit
import Security
import CaptureCore

struct PermissionStatus {
    let isReady:Bool
    let isAdHoc:Bool?
    let bundleURL:URL
    let version:String
    init(bundle:Bundle = .main) {
        isReady=CGPreflightScreenCaptureAccess()
        bundleURL=bundle.bundleURL
        version="\(bundle.object(forInfoDictionaryKey:"CFBundleShortVersionString") as? String ?? L10n.text("version.development")) (\(bundle.object(forInfoDictionaryKey:"CFBundleVersion") as? String ?? "—"))"
        var code:SecCode?
        var staticCode:SecStaticCode?
        var information:CFDictionary?
        if SecCodeCopySelf(SecCSFlags(),&code) == errSecSuccess,let code,
           SecCodeCopyStaticCode(code,SecCSFlags(),&staticCode) == errSecSuccess,let staticCode,
           SecCodeCopySigningInformation(staticCode,SecCSFlags(rawValue:kSecCSSigningInformation),&information) == errSecSuccess,
           let flags=(information as? [String:Any])?[kSecCodeInfoFlags as String] as? NSNumber {
            // Security CSCommon.h: kSecCodeSignatureAdhoc (CS_ADHOC) = 0x0002.
            isAdHoc=flags.uint32Value & 0x0002 != 0
        } else {isAdHoc=nil}
    }
    var presentation:PermissionPresentation {PermissionPresentation(accessEffective:isReady,adHoc:isAdHoc)}
    var title:String {L10n.text(presentation.titleKey,defaultValue:presentation.title)}
    var explanation:String {L10n.text(presentation.explanationKey,defaultValue:presentation.explanation)}
    var identityAdvice:String {L10n.text(presentation.identityAdviceKey,defaultValue:presentation.identityAdvice)}
}
