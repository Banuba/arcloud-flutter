import Foundation
import Flutter
import BanubaARCloudSDK
import os

enum Channel: String {
  case name = "com.banuba.sdk.flutter.arcloud"
}

enum Method: String {
  case getEffects = "get_effects"
  case downloadEffect = "download_effect"
  case effectsLoaded = "effects_loaded"
  case arCloudURL = "ar_cloud_url"
}

enum Param: String {
  case effectName = "effect_name"
  case arCloudUrlName = "arCloudUrl"
}

enum ErrorCode: String {
  case getEffects = "error_get_effects"
  case downloadEffect = "error_download_effect"
}

public class ARCloudPlugin: NSObject, FlutterPlugin {
  private static let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "",
    category: "ARCloudiOS"
  )

  private var arcloudEffectsFolderURL: URL {
    let manager = FileManager.default
    let documents = manager.urls(
      for: .documentDirectory,
      in: .userDomainMask
    ).last ?? manager.temporaryDirectory
    let effectsFolder = documents.appendingPathComponent("effects")
    return effectsFolder
  }

  private var channel: FlutterMethodChannel?
  
  private let concurrentQueue = DispatchQueue(label: "banuba_arcloud", attributes: .concurrent)
  private var banubaARCloud: BanubaARCloud?
  
  private var effectsList: [AREffect] = [] {
    didSet {
      let jsonWrapper = ArEffectsJsonWrapper(errorCode: nil, effects: effectsList.wrapped())
      channel?.invokeMethod(Method.effectsLoaded.rawValue, arguments: jsonWrapper.asPrettyPrintedString())
    }
  }
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let arCloudPlugin = ARCloudPlugin()
    
    arCloudPlugin.channel = FlutterMethodChannel(name: Channel.name.rawValue, binaryMessenger: registrar.messenger())
    
    registrar.addMethodCallDelegate(arCloudPlugin, channel: arCloudPlugin.channel!)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch(call.method) {
      case Method.getEffects.rawValue:
        onGetEffectsCall(call, result)
      case Method.downloadEffect.rawValue:
        onDownloadEffectCall(call, result)
      case Method.arCloudURL.rawValue:
        onArCloudUrlCall(call, result)
      default:
        result(FlutterMethodNotImplemented)
    }
  }
  
  private func onArCloudUrlCall(_ call: FlutterMethodCall,_ result: @escaping FlutterResult) {
    concurrentQueue.async {
      do {
        let arCloudURL: String = try call.obtainArgument(Param.arCloudUrlName.rawValue)
          self.banubaARCloud = BanubaARCloud(
            arCloudUrl: arCloudURL,
            effectsFolderURL: self.arcloudEffectsFolderURL
          )
        Self.logger.debug("initWithUrl = \(arCloudURL)")
        result(nil)
      } catch {
        result(FlutterError(code: ErrorCode.downloadEffect.rawValue, message: "Unknown error.", details: nil))
      }
    }
  }
  
  private func onGetEffectsCall(_ call: FlutterMethodCall,_ result: @escaping FlutterResult) {
    Self.logger.debug("Load effects")
    fetchAREffects(completion: { [weak self] effects, error in
      guard let self else { return }
      if let error {
        Self.logger.debug("Failed to load effects. Error: \(error.errorMessage)")
        result(FlutterError(code: ErrorCode.getEffects.rawValue, message: error.errorMessage, details: nil))
        return
      }
      if let effects {
        self.effectsList = effects
        result(effectsList.wrapped().asPrettyPrintedString())
      }
    })
  }
  
  private func onDownloadEffectCall(_ call: FlutterMethodCall,_ result: @escaping FlutterResult) {
    do {
      let effectNameParam: String = try call.obtainArgument(Param.effectName.rawValue)
      Self.logger.debug("Download effect = \(effectNameParam)")
      let effect = effectsList.first { $0.title == effectNameParam }
      if let effect {
        downloadEffect(result, effect)
      } else {
        result(FlutterError(code: ErrorCode.downloadEffect.rawValue, message: "Effect \(effectNameParam) not found.", details: nil))
      }
    } catch EncodingError.invalidValue {
      result(FlutterError(code: ErrorCode.downloadEffect.rawValue, message: "Effects serialization error.", details: nil))
    } catch {
      result(
        FlutterError(code: ErrorCode.downloadEffect.rawValue, message: "Unknown error.", details: nil)
      )
    }
  }
  
  private func downloadEffect(_ result: @escaping FlutterResult, _ effect: AREffect) {
    concurrentQueue.async {
      self.banubaARCloud?.downloadArEffect(effect) { (progress) in
        // do nothing
      } completion: { [weak self] url, error in
        guard let self else { return }
        DispatchQueue.main.async {
          if let error {
            Self.logger.debug("Failed to download effect = \(effect.title)")
            result(FlutterError(code: ErrorCode.downloadEffect.rawValue, message: error.errorMessage, details: nil))
            return
          }
          
          self.onEffectDownloaded(result, effect)
        }
      }
    }
  }
  
  private func onEffectDownloaded(_ result: @escaping FlutterResult, _ effect: AREffect) {
    fetchAREffects(completion: { [weak self] effects, error in
      guard let self else { return }
      if let error {
        result(FlutterError(code: ErrorCode.downloadEffect.rawValue, message: error.errorMessage, details: nil))
        return
      }
      if let effects {
        self.effectsList = effects
        let effect = effectsList.wrapped().first { $0.name == effect.title }!
        result(effect.asPrettyPrintedString())
      }
    })
  }
  
  private func fetchAREffects(completion: @escaping ([AREffect]?, NSError?) -> Void) {
    concurrentQueue.async {
      self.banubaARCloud?.getAREffects { effectsArray, error in
        DispatchQueue.main.async {
          completion(effectsArray, error)
        }
      }
    }
  }
}
