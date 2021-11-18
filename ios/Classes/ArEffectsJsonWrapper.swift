import Foundation

internal struct ArEffectsJsonWrapper: Hashable, Encodable {
    public var errorCode: String?
    public var effects: [ArEffectWrapper]?
}
