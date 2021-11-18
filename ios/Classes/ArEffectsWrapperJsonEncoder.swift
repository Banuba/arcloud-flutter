import Foundation

internal class ArEffectsWrapperJsonEncoder {
    func encode(effectsWrapper: ArEffectsJsonWrapper) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try! encoder.encode(effectsWrapper)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return jsonString
    }
}
