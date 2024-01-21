class Effect {
  const Effect(
    this.isDefault,
    this.eTag,
    this.id,
    this.name,
    this.preview,
    this.type,
    this.uri,
    this.isDownloaded,
  );

  final bool isDefault;
  final String? eTag;
  final int id;
  final String name;
  final String? preview;
  final String? type;
  final String uri;
  final bool isDownloaded;

  @override
  String toString() {
    return 'Effect(isDefault: $isDefault, eTag: $eTag, id: $id, name: $name, preview: $preview, type: $type, uri: $uri, isDownloaded: $isDownloaded)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Effect &&
        other.isDefault == isDefault &&
        other.eTag == eTag &&
        other.id == id &&
        other.name == name &&
        other.preview == preview &&
        other.type == type &&
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
        type.hashCode ^
        uri.hashCode ^
        isDownloaded.hashCode;
  }
}
