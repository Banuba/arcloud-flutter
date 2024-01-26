import Flutter
import Foundation

extension FlutterMethodCall {
  
  func obtainArgument<T>(_ argumentName: String) throws -> T {
    let argumentsMap = self.arguments as! Dictionary<String, Any?>
    return try argumentsMap.obtainArgument(argumentName)
  }
}

extension Dictionary where Key == String, Value == Any? {
  
  func obtainArgument<T>(_ argumentName: String) throws -> T {
    if let value = self[argumentName] as? T {
      return value
    } else {
      throw NSError(domain: "Unknown argument \(argumentName)", code: 001)
    }
  }
}
