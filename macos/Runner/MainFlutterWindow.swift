import Cocoa
import FlutterMacOS

/// File Name: MainFlutterWindow.swift
/// Purpose: Hosts the Flutter view, and handles the `screen_capture` channel
///          behind the Settings > Take Screen Shot switch.
/// Updated: 26/8/2026
///
/// macOS lever: `NSWindow.sharingType = .none`. It tells the window server
/// this window may not be read by other processes, which covers screen
/// sharing, screen recorders, ScreenCaptureKit and window-targeted captures —
/// the window is left out or comes back blank.
///
/// HONEST LIMIT: unlike Android's FLAG_SECURE this is not absolute. macOS
/// exposes no "user took a screenshot" notification, and a full-screen system
/// grab (Cmd+Shift+3) is not guaranteed to be redacted on every macOS
/// version. Treat macOS as best effort and do not promise the employee more.
class MainFlutterWindow: NSWindow {

  private static let screenCaptureChannelName = "knowticed_plus/screen_capture"

  private var screenCaptureChannel: FlutterMethodChannel?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    // ADDED 17/10/2026 (Moataz, resize test): the window stops shrinking at a
    // phone size, so it can show the phone layout but never squash smaller.
    self.contentMinSize = NSSize(width: 375, height: 640)
    // ADDED 22/10/2026 (Moataz): no white title bar — the app's own header
    // colour fills the top edge, behind the three window buttons. Flutter
    // keeps a strip of `kMacTitleBarHeight` free at the top (main.dart) so
    // nothing sits under the buttons; the strip still drags the window.
    self.titlebarAppearsTransparent = true
    self.titleVisibility = .hidden
    self.styleMask.insert(.fullSizeContentView)

    RegisterGeneratedPlugins(registry: flutterViewController)

    setUpScreenCaptureChannel(messenger: flutterViewController.engine.binaryMessenger)

    super.awakeFromNib()
  }

  private func setUpScreenCaptureChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: MainFlutterWindow.screenCaptureChannelName,
      binaryMessenger: messenger)

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(false)
        return
      }

      switch call.method {
      case "setAllowed":
        let arguments = call.arguments as? [String: Any]
        let allowed = arguments?["allowed"] as? Bool ?? true
        DispatchQueue.main.async {
          self.sharingType = allowed ? .readOnly : .none
          result(!allowed)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    screenCaptureChannel = channel
  }
}
