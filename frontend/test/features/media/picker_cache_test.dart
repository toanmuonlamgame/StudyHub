import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/media/services/picker_cache_io.dart';

void main() {
  test(
    'picker cleanup stays inside the app cache and keeps recent files',
    () async {
      final sandbox = await Directory.systemTemp.createTemp('studyhub-picker-');
      addTearDown(() => sandbox.delete(recursive: true));
      final cache = await Directory.fromUri(
        sandbox.uri.resolve('cache/'),
      ).create();
      final old = DateTime.now().subtract(const Duration(days: 2));
      final cutoff = DateTime.now().subtract(const Duration(days: 1));

      Future<File> image(Uri location, {bool stale = false}) async {
        final file = await File.fromUri(location).writeAsBytes([1, 2, 3]);
        if (stale) await file.setLastModified(old);
        return file;
      }

      final picked = await image(cache.uri.resolve('scaled_current.jpg'));
      final staleScaled = await image(
        cache.uri.resolve('scaled_old.jpg'),
        stale: true,
      );
      final unrelated = await image(
        cache.uri.resolve('unrelated.jpg'),
        stale: true,
      );
      final originalDir = await Directory.fromUri(
        cache.uri.resolve('12345678-1234-4abc-8abc-123456789abc/'),
      ).create();
      await image(originalDir.uri.resolve('old.png'), stale: true);
      final outside = await image(
        sandbox.uri.resolve('user-photo.jpg'),
        stale: true,
      );

      await pruneAndroidPickerFiles(cache, olderThan: cutoff);
      expect(await staleScaled.exists(), isFalse);
      expect(await originalDir.exists(), isFalse);
      expect(await picked.exists(), isTrue);
      expect(await unrelated.exists(), isTrue);
      await discardPickerFile(cache, outside);
      expect(await outside.exists(), isTrue);
      await discardPickerFile(cache, picked);
      expect(await picked.exists(), isFalse);
    },
  );
}
