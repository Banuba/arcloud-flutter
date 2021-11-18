import Foundation
import BanubaARCloudSDK

internal class ArEffectMapper {
    func map(effect: AREffect) -> ArEffectWrapper {
        return ArEffectWrapper(
            isDefault: false,
            eTag: nil,
            id: effect.title.hash,
            name: effect.title,
            preview: effect.isDownloaded ? "\(effect.localURL?.path ?? "")/preview.png" : "https://cdn.staging.arcloud.banuba.net" + effect.previewImage.path,
            typeId: nil,
            uri: effect.isDownloaded ? effect.localURL?.path ?? "" : effect.downloadLink.path,
            isDownloaded: effect.isDownloaded
        )
    }
}
