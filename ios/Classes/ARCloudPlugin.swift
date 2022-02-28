import Foundation
import Flutter
import BanubaARCloudSDK

enum Channel: String {
    case name = "com.banuba.sdk.flutter.arcloud"
}

enum Method: String {
    case getEffects = "get_effects"
    case downloadEffect = "download_effect"
    case effectLoaded = "effects_loaded"
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
    private let concurrentQueue = DispatchQueue(label: "banuba_arcloud", attributes: .concurrent)
    private var channel: FlutterMethodChannel?
    private var banubaARCloud: BanubaARCloud?
    private var delegate: ARCloudPluginDelegate {
        get {
            guard let delegate = UIApplication.shared.delegate as? ARCloudPluginDelegate else {
                fatalError("You must implement ARCloudPluginDelegate in AppDelegate!")
            }
            return delegate
        }
    }
    private var effectsList: [AREffect] = []
    
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
                self.banubaARCloud = BanubaARCloud(arCloudUrl: arCloudURL)
                result(nil)
            } catch {
                self.handleResultError(result, ErrorCode.downloadEffect.rawValue, "Unknown error.")
            }
        }
    }
    
    private func onGetEffectsCall(_ call: FlutterMethodCall,_ result: @escaping FlutterResult) {
        fetchAREffects(completion: { (effects, error) in
            if (let error = error) {
                self.handleResultError(result, ErrorCode.getEffects.rawValue, error.errorMessage)
            }
            if (let effects = effects) {
                self.effectsList = effects
                let wrappedEffects = self.effectsList.map(ArEffectMapper().map)
                let effectsJsonString = ArEffectsJsonEncoder().encode(from: wrappedEffects)
                result(effectsJsonString)
            }
        })
    }
    
    private func onDownloadEffectCall(_ call: FlutterMethodCall,_ result: @escaping FlutterResult) {
        do {
            let effectNameParam: String = try call.obtainArgument(Param.effectName.rawValue)
            let effect = effectsList.first { $0.title == effectNameParam }
            if (effect == nil) {
                handleResultError(result, ErrorCode.downloadEffect.rawValue, "Effect \(effectNameParam) not found.")
            } else {
                downloadEffect(result, effect!)
            }
        } catch EncodingError.invalidValue {
            handleResultError(result, ErrorCode.downloadEffect.rawValue, "Effects serialization error.")
        } catch {
            handleResultError(result, ErrorCode.downloadEffect.rawValue, "Unknown error.")
        }
    }
    
    private func downloadEffect(_ result: @escaping FlutterResult, _ effect: AREffect) {
        concurrentQueue.async {
            self.banubaARCloud?.downloadArEffect(effect) { (progress) in
                // do nothing
            } completion: { (url, error) in
                DispatchQueue.main.async {
                    if (error != nil) {
                        self.handleResultError(result, ErrorCode.downloadEffect.rawValue, error?.errorMessage)
                    }
                    if (url != nil) {
                        self.onEffectDownloaded(result, effect)
                    }
                }
            }
        }
    }
    
    private func onEffectDownloaded(_ result: @escaping FlutterResult, _ effect: AREffect) {
        fetchAREffects(completion: { (effects, error) in
            if (error != nil) {
                self.handleResultError(result, ErrorCode.downloadEffect.rawValue, error?.errorMessage)
            }
            if (effects != nil) {
                self.sendEffectDownloadedResult(result, effect)
                self.sendEffectsLoaded()
            }
        })
    }
    
    private func sendEffectDownloadedResult(_ result: @escaping FlutterResult, _ effect: AREffect) {
        let effect = self.effectsList
            .map(ArEffectMapper().map)
            .first { $0.name == effect.title }!
        let effectJsonString = ArEffectsJsonEncoder().encode(from: effect)
        result(effectJsonString)
    }
    
    private func sendEffectsLoaded() {
        let wrappedEffects = self.effectsList.map(ArEffectMapper().map)
        let jsonWrapper = ArEffectsJsonWrapper(errorCode: nil, effects: wrappedEffects)
        let effectsJsonString = ArEffectsJsonEncoder().encode(from: jsonWrapper)
        self.channel?.invokeMethod(Method.effectLoaded.rawValue, arguments: effectsJsonString)
    }
    
    private func fetchAREffects(completion: @escaping ([AREffect]?, NSError?) -> Void) {
        concurrentQueue.async {
            self.banubaARCloud?.getAREffects { (effectsArray, error) in
                DispatchQueue.main.async {
                    completion(self.effectsList, error)
                }
            }
        }
    }
    
    private func handleResultError(_ result: @escaping FlutterResult, _ errorCode: String, _ message: String?) {
        let error = FlutterError(
            code: errorCode,
            message: message,
            details: nil
        )
        result(error)
    }
}
