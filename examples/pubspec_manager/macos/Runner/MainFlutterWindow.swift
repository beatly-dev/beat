import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
//    self.titleVisibility = .hidden
//    self.titlebarAppearsTransparent = true
//    self.isMovableByWindowBackground = true
//    self.styleMask.insert(NSWindow.StyleMask.fullSizeContentView)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
