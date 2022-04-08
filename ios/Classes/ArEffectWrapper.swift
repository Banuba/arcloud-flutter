import Foundation

internal struct ArEffectWrapper: Hashable, Encodable {
    public var isDefault: Bool
    public var eTag: String?
    public var id: Int
    public var name: String
    public var preview: String
    public var type: String?
    public var uri: String
    public var isDownloaded: Bool
    
    enum CodingKeys: String, CodingKey {
        case `default`
        case eTag
        case id
        case name
        case preview
        case type
        case uri
        case isDownloaded
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isDefault, forKey: .`default`)
        try container.encode(eTag, forKey: .eTag)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(preview, forKey: .preview)
        try container.encode(type, forKey: .type)
        try container.encode(uri, forKey: .uri)
        try container.encode(isDownloaded, forKey: .isDownloaded)
    }
}
