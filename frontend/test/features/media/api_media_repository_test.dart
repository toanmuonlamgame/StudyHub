import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/media/repositories/api_media_repository.dart';
import 'package:frontend/features/media/repositories/media_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  test(
    'rejects large images before reading bytes or starting a request',
    () async {
      final repository = ApiMediaRepository(
        baseUrl: 'https://example.test',
        client: MockClient((_) => throw StateError('Unexpected request')),
      );

      await expectLater(
        repository.uploadImage(_OversizedImage()),
        throwsA(isA<MediaUploadException>()),
      );
    },
  );

  test(
    'uploads the bounded image as an authenticated multipart stream',
    () async {
      final repository = ApiMediaRepository(
        baseUrl: 'https://example.test',
        accessTokenProvider: () async => 'test-token',
        client: MockClient((request) async {
          expect(request.url.path, '/media/images');
          expect(request.headers['authorization'], 'Bearer test-token');
          expect(
            request.headers['content-type'],
            startsWith('multipart/form-data'),
          );
          expect(request.body, contains('photo.png'));
          expect(request.body, contains('test-image'));
          return http.Response(
            '{"media":{"mediaType":"image","mediaUrl":"/media/images/photo.png"}}',
            201,
          );
        }),
      );
      final result = await repository.uploadImage(
        XFile.fromData(
          Uint8List.fromList('test-image'.codeUnits),
          name: 'photo.png',
          path: 'photo.png',
        ),
      );

      expect(result.mediaUrl, 'https://example.test/media/images/photo.png');
    },
  );
}

class _OversizedImage extends XFile {
  _OversizedImage() : super('large.jpg');

  @override
  Future<int> length() async => imageUploadMaxBytes + 1;

  @override
  Future<Uint8List> readAsBytes() async => throw StateError('Unexpected read');

  @override
  Stream<Uint8List> openRead([int? start, int? end]) =>
      throw StateError('Unexpected stream');
}
