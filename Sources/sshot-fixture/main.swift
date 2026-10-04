import AppKit
final class Pattern: NSView {
    override func draw(_ dirtyRect:NSRect) {
        for (color,rect) in [(NSColor.red,CGRect(x:0,y:0,width:200,height:150)),(.green,CGRect(x:200,y:0,width:200,height:150)),(.blue,CGRect(x:0,y:150,width:200,height:150)),(.yellow,CGRect(x:200,y:150,width:200,height:150))] { color.setFill();rect.fill() }
    }
}
let app=NSApplication.shared
app.setActivationPolicy(.accessory)
let requested=CommandLine.arguments.firstIndex(of:"--display-index").flatMap {i in i+1 < CommandLine.arguments.count ? Int(CommandLine.arguments[i+1]) : nil} ?? 0
let screen=NSScreen.screens[min(max(requested,0),NSScreen.screens.count-1)].visibleFrame
let window=NSWindow(contentRect:CGRect(x:screen.minX+100,y:screen.minY+100,width:400,height:300),styleMask:.borderless,backing:.buffered,defer:false)
window.isReleasedWhenClosed=false
window.level = .floating;window.contentView=Pattern(frame:CGRect(x:0,y:0,width:400,height:300));window.backgroundColor = .white;window.isOpaque=true;window.orderFrontRegardless()
app.run()
