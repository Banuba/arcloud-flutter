import Foundation

internal class ArEffectsJsonEncoder {
    func encode<T: Encodable>(from data: T) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try! encoder.encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return jsonString
    }
}
