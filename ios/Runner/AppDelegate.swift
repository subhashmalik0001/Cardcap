import Flutter
import UIKit
import Vision

class ProxyViewController: UIViewController {
  weak var appDelegate: AppDelegate?
  
  override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
    if let realVC = appDelegate?.findRealFlutterViewController(), realVC !== self {
      realVC.present(viewControllerToPresent, animated: flag, completion: completion)
    } else {
      super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
  }
  
  override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
    if let realVC = appDelegate?.findRealFlutterViewController(), realVC !== self {
      realVC.dismiss(animated: flag, completion: completion)
    } else {
      super.dismiss(animated: flag, completion: completion)
    }
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  
  weak var earlyFlutterViewController: UIViewController?
  
  private lazy var proxyWindow: UIWindow = {
    let win = UIWindow(frame: UIScreen.main.bounds)
    let proxyVC = ProxyViewController()
    proxyVC.appDelegate = self
    win.rootViewController = proxyVC
    return win
  }()

  override var window: UIWindow? {
    get {
      if let window = super.window {
        return window
      }
      for scene in UIApplication.shared.connectedScenes {
        if let windowScene = scene as? UIWindowScene {
          if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }), keyWindow !== proxyWindow {
            return keyWindow
          }
          if let firstWindow = windowScene.windows.first(where: { $0 !== proxyWindow }) {
            return firstWindow
          }
        }
      }
      return proxyWindow
    }
    set {
      super.window = newValue
    }
  }

  func findRealFlutterViewController() -> UIViewController? {
    if let vc = super.window?.rootViewController {
      return vc
    }
    for scene in UIApplication.shared.connectedScenes {
      if let windowScene = scene as? UIWindowScene {
        if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
          return keyWindow.rootViewController
        }
        if let firstWindow = windowScene.windows.first {
          return firstWindow.rootViewController
        }
      }
    }
    return self.earlyFlutterViewController
  }

  private func registerOcrChannel(with messenger: FlutterBinaryMessenger) {
    let ocrChannel = FlutterMethodChannel(name: "com.cardcapture.cardCapture/ocr",
                                              binaryMessenger: messenger)
    ocrChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard let self = self else { return }
      if call.method == "recognizeText" {
        guard let args = call.arguments as? [String: Any],
              let imagePath = args["imagePath"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "imagePath is required", details: nil))
          return
        }
        self.recognizeTextNatively(imagePath: imagePath, result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    if let controller = findRealFlutterViewController() as? FlutterViewController {
      registerOcrChannel(with: controller.binaryMessenger)
    } else if let controller = window?.rootViewController as? FlutterViewController {
      registerOcrChannel(with: controller.binaryMessenger)
    }
    
    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    if let vc = engineBridge.pluginRegistry as? UIViewController {
      self.earlyFlutterViewController = vc
    }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerOcrChannel(with: engineBridge.applicationRegistrar.messenger())
  }

  private func recognizeTextNatively(imagePath: String, result: @escaping FlutterResult) {
    guard let image = UIImage(contentsOfFile: imagePath),
          let cgImage = image.cgImage else {
      result(FlutterError(code: "LOAD_ERROR", message: "Failed to load image from path: \(imagePath)", details: nil))
      return
    }

    let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    let request = VNRecognizeTextRequest { request, error in
      if let error = error {
        result(FlutterError(code: "VISION_ERROR", message: error.localizedDescription, details: nil))
        return
      }

      var lines: [[String: Any]] = []
      guard let observations = request.results as? [VNRecognizedTextObservation] else {
        result([])
        return
      }

      for observation in observations {
        guard let topCandidate = observation.topCandidates(1).first else { continue }
        
        let rect = observation.boundingBox
        
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        let x = rect.origin.x * width
        let y = (1.0 - rect.origin.y - rect.size.height) * height
        let w = rect.size.width * width
        let h = rect.size.height * height

        lines.append([
          "text": topCandidate.string,
          "x": Double(x),
          "y": Double(y),
          "width": Double(w),
          "height": Double(h)
        ])
      }
      result(lines)
    }

    request.recognitionLevel = .accurate
    do {
      try requestHandler.perform([request])
    } catch {
      result(FlutterError(code: "PERFORM_ERROR", message: error.localizedDescription, details: nil))
    }
  }
}
