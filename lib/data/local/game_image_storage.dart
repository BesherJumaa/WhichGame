import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

typedef SupportDirectoryProvider = Future<Directory> Function();

/// Persists user-selected game artwork inside the app's support directory.
///
/// We intentionally do not keep the original picker path because gallery/file
/// picker permissions can expire. Copying the bytes into app-owned storage
/// makes the image survive app restarts and device reboots until the app is
/// uninstalled or the user removes/replaces the artwork.
class GameImageStorage {
  GameImageStorage({SupportDirectoryProvider? supportDirectoryProvider})
      : _supportDirectoryProvider =
            supportDirectoryProvider ?? getApplicationSupportDirectory;

  static const _directoryName = 'game_images';
  static const _allowedExtensions = <String>{
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  };

  final SupportDirectoryProvider _supportDirectoryProvider;

  Future<String> saveImage({
    required String gameId,
    required Uint8List bytes,
    required String originalFileName,
  }) async {
    if (bytes.isEmpty) {
      throw ArgumentError.value(bytes.length, 'bytes', 'Image cannot be empty.');
    }

    final directory = await _ensureDirectory();
    final extension = _extensionFor(originalFileName);
    final safeGameId = gameId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final fileName =
        '${safeGameId}_${DateTime.now().microsecondsSinceEpoch}$extension';
    final file = File('${directory.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> deleteImage(String? path) async {
    final normalizedPath = path?.trim();
    if (normalizedPath == null || normalizedPath.isEmpty) {
      return;
    }

    final directory = await _ensureDirectory();
    final root = '${directory.absolute.path}${Platform.pathSeparator}'.toLowerCase();
    final candidate = File(normalizedPath).absolute.path.toLowerCase();

    // Never delete arbitrary files if a corrupted preference somehow contains
    // an external path. Only app-managed game images are eligible.
    if (!candidate.startsWith(root)) {
      return;
    }

    final file = File(normalizedPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Directory> _ensureDirectory() async {
    final supportDirectory = await _supportDirectoryProvider();
    final directory = Directory(
      '${supportDirectory.path}${Platform.pathSeparator}$_directoryName',
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  String _extensionFor(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0) {
      return '.img';
    }
    final extension = fileName.substring(dot).toLowerCase();
    return _allowedExtensions.contains(extension) ? extension : '.img';
  }
}
