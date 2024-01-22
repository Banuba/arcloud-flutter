import BanubaARCloudSDK

struct ArEffectWrapper: Hashable, Encodable {
  var isDefault: Bool
  var eTag: String?
  var id: Int
  var name: String
  var preview: String
  var type: String?
  var uri: String
  var isDownloaded: Bool
  
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

struct ArEffectsJsonWrapper: Hashable, Encodable {
  var errorCode: String?
  var effects: [ArEffectWrapper]?
}

extension Array where Element == AREffect {
  func wrapped() -> [ArEffectWrapper] {
    self.map { effect in
      ArEffectWrapper(
        isDefault: false,
        eTag: nil,
        id: effect.title.hash,
        name: effect.title,
        preview: effect.isDownloaded ? "\(effect.localURL?.path ?? "")/preview.png" : effect.previewImage.absoluteString,
        type: effect.type,
        uri: effect.isDownloaded ? effect.localURL?.path ?? "" : effect.downloadLink.path,
        isDownloaded: effect.isDownloaded
      )
    }
  }
}

extension Encodable {
  func asPrettyPrintedString() -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let jsonData = try! encoder.encode(self)
    let jsonString = String(data: jsonData, encoding: .utf8)!
    return jsonString
  }
}
