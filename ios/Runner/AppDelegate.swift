import CoreMotion
import Flutter
import MapKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AtivaDirections") {
      registrar.addSceneDelegate(DirectionsRequestHandler(messenger: registrar.messenger()))
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AtivaHeading") {
      HeadingBridge.register(with: registrar)
    }
  }
}

/// Device attitude for the orienteering compass, from Cosmolabe's bridge.
/// Magnetic north on purpose: orienteering maps are drawn to magnetic north,
/// so a bearing is read straight off the map, and no location permission is
/// needed (true north would need the position). Core Motion's frame has X to
/// north and Z up; every sample is turned a quarter about the vertical into
/// East-North-Up, the frame Android's rotation vector already uses.
final class HeadingBridge: NSObject, FlutterStreamHandler {
  static let channelName = "ativa/heading"
  private let motion = CMMotionManager()
  private static let nwuToEnu = (w: (2.0).squareRoot() / 2, z: (2.0).squareRoot() / 2)

  static func register(with registrar: FlutterPluginRegistrar) {
    let bridge = HeadingBridge()
    FlutterEventChannel(name: channelName, binaryMessenger: registrar.messenger()).setStreamHandler(bridge)
    FlutterMethodChannel(name: "\(channelName)/control", binaryMessenger: registrar.messenger())
      .setMethodCallHandler { call, result in
        if call.method == "isAvailable" {
          result(bridge.motion.isDeviceMotionAvailable
            && CMMotionManager.availableAttitudeReferenceFrames().contains(.xMagneticNorthZVertical))
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    guard motion.isDeviceMotionAvailable else {
      return FlutterError(code: "unavailable", message: "No motion sensors", details: nil)
    }
    motion.deviceMotionUpdateInterval = 1.0 / 30.0
    motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { m, _ in
      guard let m else { return }
      let q = m.attitude.quaternion
      let c = Self.nwuToEnu
      // Left-multiply by the quarter turn about Z (x and y of c are zero).
      events([
        "w": c.w * q.w - c.z * q.z,
        "x": c.w * q.x - c.z * q.y,
        "y": c.w * q.y + c.z * q.x,
        "z": c.w * q.z + c.z * q.w,
        "accuracy": Self.accuracy(m.magneticField.accuracy),
      ])
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    motion.stopDeviceMotionUpdates()
    return nil
  }

  private static func accuracy(_ a: CMMagneticFieldCalibrationAccuracy) -> Double {
    switch a {
    case .high: return 5
    case .medium: return 15
    case .low: return 35
    default: return 180
    }
  }
}

/// Apple Maps offers Madeira Ativa for bus directions on the island (the routing
/// coverage file in App Store Connect draws where). Maps opens the app with an
/// MKDirectionsRequest; this turns its two points into the in-app bus planner,
/// /bus?from=lat,lon&to=lat,lon. A start of "My Location" carries no
/// coordinates and the app asks for no location permission, so the planner
/// opens with only the destination filled in.
final class DirectionsRequestHandler: NSObject, FlutterSceneLifeCycleDelegate {
  private let navigation: FlutterMethodChannel

  init(messenger: FlutterBinaryMessenger) {
    navigation = FlutterMethodChannel(
      name: "flutter/navigation", binaryMessenger: messenger, codec: FlutterJSONMethodCodec.sharedInstance())
  }

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions?) -> Bool {
    guard let route = Self.route(from: connectionOptions?.urlContexts ?? []) else { return false }
    // A cold start: give the widget tree a moment to mount its Navigator.
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { self.push(route) }
    return true
  }

  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
    guard let route = Self.route(from: URLContexts) else { return false }
    push(route)
    return true
  }

  private func push(_ route: String) {
    navigation.invokeMethod("pushRouteInformation", arguments: ["location": route, "state": NSNull()])
  }

  static func route(from contexts: Set<UIOpenURLContext>) -> String? {
    guard let url = contexts.first(where: { MKDirections.Request.isDirectionsRequest($0.url) })?.url else { return nil }
    let request = MKDirections.Request(contentsOf: url)
    func point(_ item: MKMapItem?, _ key: String) -> [URLQueryItem] {
      guard let item, !item.isCurrentLocation else { return [] }
      let c = item.placemark.coordinate
      var q = [URLQueryItem(name: key, value: String(format: "%.5f,%.5f", c.latitude, c.longitude))]
      if let name = item.name, !name.isEmpty { q.append(URLQueryItem(name: key + "Name", value: name)) }
      return q
    }
    var parts = URLComponents()
    parts.path = "/bus"
    parts.queryItems = point(request.source, "from") + point(request.destination, "to")
    return parts.string
  }
}
