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
