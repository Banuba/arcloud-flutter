class ArEffect {
  const ArEffect(
    this.isDefault,
    this.eTag,
    this.id,
    this.name,
    this.preview,
    this.typeId,
    this.uri,
    this.isDownloaded,
  );

  final bool isDefault;
  final String? eTag;
  final int id;
  final String name;
  final String? preview;
  final int? typeId;
  final String uri;
  final bool isDownloaded;

  @override
  String toString() {
    return 'ArEffect(isDefault: $isDefault, eTag: $eTag, id: $id, name: $name, preview: $preview, typeId: $typeId, uri: $uri, isDownloaded: $isDownloaded)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ArEffect &&
        other.isDefault == isDefault &&
        other.eTag == eTag &&
        other.id == id &&
        other.name == name &&
        other.preview == preview &&
        other.typeId == typeId &&
        other.uri == uri &&
        other.isDownloaded == isDownloaded;
  }

  @override
  int get hashCode {
    return isDefault.hashCode ^
        eTag.hashCode ^
        id.hashCode ^
        name.hashCode ^
        preview.hashCode ^
        typeId.hashCode ^
        uri.hashCode ^
        isDownloaded.hashCode;
  }
}
