import AppKit
import CaptureCore
import Darwin
enum SelfTest {
    @MainActor static func run() async {
        guard CGPreflightScreenCaptureAccess() else { emit(["case":"real-capture","result":"SKIP","reason":"screen-recording-permission"]);fflush(stdout);exit(77) }
        var passed=true
        for (index,screen) in NSScreen.screens.enumerated() {
            let result=await runCase(screen:screen,index:index)
            passed=passed && result
        }
        fflush(stdout);exit(passed ? 0 : 1)
    }
    @MainActor private static func runCase(screen:NSScreen,index:Int) async -> Bool {
        let process=Process()
        var testOverlay:OverlayWindow?
        var testBoard:NSPasteboard?
        var exitCode:Int32=1
        let sibling=Bundle.main.bundleURL.deletingLastPathComponent().appendingPathComponent("sshot-fixture.app/Contents/MacOS/sshot-fixture")
        process.executableURL=sibling
        process.arguments=["--display-index",String(index)]
        do {
            try process.run()
            try await Task.sleep(nanoseconds:1_000_000_000)
            let rect=CGRect(x:screen.visibleFrame.minX+100,y:screen.visibleFrame.minY+100,width:400,height:300)
            let overlay=OverlayWindow(contentRect:rect,styleMask:.borderless,backing:.buffered,defer:false)
            testOverlay=overlay
            overlay.level = .screenSaver;overlay.backgroundColor = .magenta;overlay.orderFrontRegardless()
            try await Task.sleep(nanoseconds:200_000_000)
            let image=try await CaptureService().capture(rect:rect,screen:screen)
            let bitmap=NSBitmapImageRep(cgImage:image)
            let samples=[(0.25,0.25,(0.0,0.0,1.0)),(0.75,0.25,(1.0,1.0,0.0)),(0.25,0.75,(1.0,0.0,0.0)),(0.75,0.75,(0.0,1.0,0.0))]
            let matched=samples.allSatisfy {x,y,expected in
                guard let c=bitmap.colorAt(x:Int(Double(image.width)*x),y:Int(Double(image.height)*y))?.usingColorSpace(.deviceRGB) else {return false}
                return abs(c.redComponent-expected.0)<0.15 && abs(c.greenComponent-expected.1)<0.15 && abs(c.blueComponent-expected.2)<0.15
            }
            let board=NSPasteboard.withUniqueName();testBoard=board
            try ClipboardService(board).store(image)
            let png=board.data(forType:.png).flatMap(NSBitmapImageRep.init(data:))
            let tiff=board.data(forType:.tiff).flatMap(NSBitmapImageRep.init(data:))
            let scale=screen.backingScaleFactor
            let size=image.width == Int(400*scale) && image.height == Int(300*scale)
            let decoded=png?.pixelsWide == image.width && tiff?.pixelsHigh == image.height
            let passed=matched && size && decoded
            emit(["case":"real-capture-exclusion-named-clipboard","displayIndex":index,"scale":scale,"result":passed ? "PASS":"FAIL","width":image.width,"height":image.height,"sampleMatch":matched,"sizeMatch":size,"clipboardDecoded":decoded])
            exitCode=passed ? 0 : 1
        } catch { emit(["case":"real-capture","displayIndex":index,"result":"FAIL","errorCode":(error as NSError).code]) }
        if process.isRunning { process.terminate();process.waitUntilExit() }
        testOverlay?.close();testBoard?.releaseGlobally()
        return exitCode == 0
    }
    private static func emit(_ record:[String:Any]) { if let data=try? JSONSerialization.data(withJSONObject:record,options:.sortedKeys),let value=String(data:data,encoding:.utf8) {print(value);fflush(stdout)} }
}
