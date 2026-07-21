import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/access_token_provider.dart';
import '../../../core/api_request.dart';
import '../../learning/models/media_asset.dart';
import '../../learning/repositories/media_asset_json_mapper.dart';
import 'media_repository.dart';

class ApiMediaRepository implements MediaRepository {
  ApiMediaRepository({
    required String baseUrl,
    this.accessTokenProvider,
    http.Client? client,
    this.requestTimeout = defaultApiRequestTimeout,
  }) : _baseUri = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'),
       _client = client ?? http.Client();

  final Uri _baseUri;
  final AccessTokenProvider? accessTokenProvider;
  final http.Client _client;
  final Duration requestTimeout;

  @override
  Future<MediaAsset> uploadImage(XFile file, {String? altText}) async {
    final bytes = await file.readAsBytes();
    if (bytes.length > imageUploadMaxBytes) {
      throw const MediaUploadException('Image must be 5 MiB or smaller.');
    }
    final token = await accessTokenProvider?.call();
    final request =
        http.MultipartRequest('POST', _baseUri.resolve('media/images'))
          ..files.add(
            http.MultipartFile.fromBytes('file', bytes, filename: file.name),
          );
    if (token?.trim().isNotEmpty == true) {
      request.headers['authorization'] = 'Bearer ${token!.trim()}';
    }
    final streamed = await withApiTimeout(
      _client.send(request),
      requestTimeout,
    );
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MediaUploadException(
        'Image upload failed with status ${response.statusCode}.',
      );
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      final media = mediaAssetFromJson(decoded['media'], baseUri: _baseUri);
      if (media == null) throw const FormatException();
      return media;
    } on FormatException {
      throw const MediaUploadException('Image upload returned malformed data.');
    }
  }
}
