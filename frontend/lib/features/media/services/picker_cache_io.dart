import 'dart:io';

import 'package:flutter/services.dart';

const _cacheChannel = MethodChannel('studyhub/picker_cache');

Future<Directory?> _cacheDirectory() async {
  final path = await _cacheChannel.invokeMethod<String>('cacheDirectory');
  return path == null ? null : Directory(path);
}

final _pickerDirectory = RegExp(
  r'^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$',
  caseSensitive: false,
);
final _imageExtension = RegExp(
  r'\.(jpg|jpeg|png|webp|heic|heif|gif|bmp)$',
  caseSensitive: false,
);

Future<void> discardPickedImage(String path) async {
  if (!Platform.isAndroid) return;
  try {
    final cache = await _cacheDirectory();
    if (cache != null) await discardPickerFile(cache, File(path));
  } catch (_) {
    // Cache cleanup must not interfere with editing or uploading.
  }
}

Future<void> pruneOldPickerCache() async {
  if (!Platform.isAndroid) return;
  try {
    final cache = await _cacheDirectory();
    if (cache == null) return;
    await pruneAndroidPickerFiles(
      cache,
      olderThan: DateTime.now().subtract(const Duration(days: 1)),
    );
  } catch (_) {
    // The OS can also evict temporary files independently.
  }
}

Future<void> discardPickerFile(Directory directory, File file) async {
  final root = await directory.resolveSymbolicLinks();
  if (await FileSystemEntity.type(file.path, followLinks: false) !=
      FileSystemEntityType.file) {
    return;
  }
  final resolved = File(await file.resolveSymbolicLinks());
  if (!resolved.path.startsWith('$root${Platform.pathSeparator}')) return;
  await resolved.delete();
}

Future<void> pruneAndroidPickerFiles(
  Directory directory, {
  required DateTime olderThan,
}) async {
  await for (final entry in directory.list(followLinks: false)) {
    final name = entry.uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .last;
    if (entry is File &&
        name.startsWith('scaled_') &&
        _imageExtension.hasMatch(name)) {
      if ((await entry.lastModified()).isBefore(olderThan)) {
        await discardPickerFile(directory, entry);
      }
    } else if (entry is Directory && _pickerDirectory.hasMatch(name)) {
      // Android image_picker stores the original gallery copy in a UUID folder.
      final contents = await entry.list(followLinks: false).take(2).toList();
      if (contents.isEmpty) {
        if ((await entry.stat()).modified.isBefore(olderThan)) {
          await entry.delete();
        }
      } else if (contents.length == 1 && contents.single is File) {
        final image = contents.single as File;
        if (_imageExtension.hasMatch(image.path) &&
            (await image.lastModified()).isBefore(olderThan)) {
          await discardPickerFile(directory, image);
          if (await entry.list(followLinks: false).isEmpty) {
            await entry.delete();
          }
        }
      }
    }
  }
}
