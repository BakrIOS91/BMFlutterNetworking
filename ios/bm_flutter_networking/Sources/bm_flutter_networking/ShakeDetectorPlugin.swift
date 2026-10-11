import Flutter
import UIKit

/// Bridges iOS's native shake gesture (`UIEvent.EventSubtype.motionShake`,
/// the same mechanism behind "Shake to Undo") to Dart via an event channel.
/// Unlike CoreMotion accelerometer polling, this fires correctly in the
/// iOS Simulator (Device > Shake Gesture) as well as on real devices.
public class ShakeDetectorPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private static var eventSink: FlutterEventSink?
  private static var didSwizzle = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterEventChannel(
      name: "bm_flutter_networking/shake",
      binaryMessenger: registrar.messenger()
    )
    channel.setStreamHandler(ShakeDetectorPlugin())
    swizzleMotionEndedOnce()
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    ShakeDetectorPlugin.eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    ShakeDetectorPlugin.eventSink = nil
    return nil
  }

  fileprivate static func notifyShake() {
    DispatchQueue.main.async {
      eventSink?(true)
    }
  }

  private static func swizzleMotionEndedOnce() {
    guard !didSwizzle else { return }
    didSwizzle = true

    let originalSelector = #selector(UIWindow.motionEnded(_:with:))
    let swizzledSelector = #selector(UIWindow.bm_shakeMotionEnded(_:with:))

    guard
      let originalMethod = class_getInstanceMethod(UIWindow.self, originalSelector),
      let swizzledMethod = class_getInstanceMethod(UIWindow.self, swizzledSelector)
    else { return }

    method_exchangeImplementations(originalMethod, swizzledMethod)
  }
}

extension UIWindow {
  @objc func bm_shakeMotionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      ShakeDetectorPlugin.notifyShake()
    }
    // UIResponder has no concrete `motionEnded` implementation to swap back
    // in, so forward to the next responder ourselves instead of trying to
    // call a swapped-in "original" that doesn't exist.
    next?.motionEnded(motion, with: event)
  }
}
