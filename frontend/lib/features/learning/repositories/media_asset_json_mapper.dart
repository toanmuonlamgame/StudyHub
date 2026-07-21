import '../models/media_asset.dart';

MediaAsset? mediaAssetFromJson(Object? value, {Uri? baseUri}) {
  if (value == null) return null;
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Expected media to be an object.');
  }
  final rawType = value['mediaType'];
  final rawUrl = value['mediaUrl'];
  if (rawType is! String || rawUrl is! String) {
    throw const FormatException('Media type and URL are required.');
  }
  final type = StudyMediaType.values.firstWhere(
    (candidate) => candidate.name == rawType,
    orElse: () => throw FormatException('Unknown media type "$rawType".'),
  );
  String resolve(String url) =>
      baseUri == null ? url : baseUri.resolve(url).toString();
  return MediaAsset(
    mediaType: type,
    mediaUrl: resolve(rawUrl),
    thumbnailUrl: value['thumbnailUrl'] is String
        ? resolve(value['thumbnailUrl'] as String)
        : null,
    altText: value['altText'] as String?,
    width: value['width'] as int?,
    height: value['height'] as int?,
  );
}
