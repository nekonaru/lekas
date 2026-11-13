import 'package:flutter/services.dart';

import 'file_rules.dart';

/// The root of one course's file store: `<picked>/Lekas/<course>/...`.
/// A stable top folder keeps the whole tree visible to every file manager
/// and keeps phone backups working as expected.
List<String> courseFileRoot(String courseName) =>
    [kLekasFolderName, sanitizeFileSegment(courseName)];

/// One normalized row of a folder listing.
class FolderEntry {
  const FolderEntry({
    required this.name,
    required this.isDirectory,
    required this.sizeBytes,
    required this.mime,
    required this.modifiedMs,
  });

  final String name;
  final bool isDirectory;
  final int sizeBytes;
  final String mime;
  final int modifiedMs;
}

/// Folders first, then alphabetical by name, insensitive to case.
List<FolderEntry> parseFolderEntries(List<dynamic> raw) {
  final entries = [
    for (final item in raw)
      if (item is Map)
        FolderEntry(
          name: item['name'] as String? ?? '',
          isDirectory: item['isDirectory'] as bool? ?? false,
          sizeBytes: (item['size'] as num?)?.toInt() ?? 0,
          mime: item['mime'] as String? ?? '',
          modifiedMs: (item['modified'] as num?)?.toInt() ?? 0,
        ),
  ];
  entries.sort((a, b) {
    if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return entries;
}

/// Icon family for a file row, picked by extension.
enum FileIconKind {
  image,
  pdf,
  archive,
  document,
  spreadsheet,
  presentation,
  audio,
  video,
  text,
  generic,
}

FileIconKind fileIconKind(String name) {
  final dot = name.lastIndexOf('.');
  final ext = dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  switch (ext) {
    case 'png':
    case 'jpg':
    case 'jpeg':
    case 'gif':
    case 'webp':
      return FileIconKind.image;
    case 'pdf':
      return FileIconKind.pdf;
    case 'zip':
    case 'rar':
    case '7z':
      return FileIconKind.archive;
    case 'doc':
    case 'docx':
    case 'odt':
      return FileIconKind.document;
    case 'xls':
    case 'xlsx':
    case 'ods':
    case 'csv':
      return FileIconKind.spreadsheet;
    case 'ppt':
    case 'pptx':
    case 'odp':
      return FileIconKind.presentation;
    case 'mp3':
    case 'wav':
    case 'm4a':
      return FileIconKind.audio;
    case 'mp4':
    case 'mkv':
    case 'webm':
      return FileIconKind.video;
    case 'txt':
    case 'md':
    case 'json':
      return FileIconKind.text;
    default:
      return FileIconKind.generic;
  }
}

/// The platform channel to the Storage Access Framework code in
/// LekasFileChannel. Every method maps failure to a result the caller can
/// show, instead of leaking exceptions or the raw channel.
class FilesChannel {
  static const MethodChannel _channel = MethodChannel('lekas/files');

  /// Opens the system tree picker; returns the tree uri, or null when the
  /// user cancels or the permission could not be taken.
  Future<String?> pickTree() async {
    try {
      return await _channel.invokeMethod<String>('pickTree');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<bool> ensureFolder(String treeUri, List<String> segments) async {
    try {
      return await _channel.invokeMethod<bool>('ensureFolder', {
            'treeUri': treeUri,
            'segments': segments,
          }) ??
          false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> createFolder(
    String treeUri,
    List<String> segments,
    String name,
  ) async {
    try {
      return await _channel.invokeMethod<bool>('createFolder', {
            'treeUri': treeUri,
            'segments': segments,
            'name': name,
          }) ??
          false;
    } on PlatformException {
      return false;
    }
  }

  Future<List<FolderEntry>> listFolder(
    String treeUri,
    List<String> segments,
  ) async {
    try {
      final raw = await _channel.invokeMethod<List<dynamic>>('listFolder', {
        'treeUri': treeUri,
        'segments': segments,
      });
      return parseFolderEntries(raw ?? const []);
    } on PlatformException {
      return const [];
    }
  }

  Future<bool> importFile(
    String treeUri,
    List<String> segments,
    String displayName,
    String sourcePath,
  ) async {
    try {
      return await _channel.invokeMethod<bool>('importFile', {
            'treeUri': treeUri,
            'segments': segments,
            'displayName': sanitizeFileName(displayName),
            'sourcePath': sourcePath,
          }) ??
          false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> deleteEntry(
    String treeUri,
    List<String> segments,
    String name,
  ) async {
    try {
      return await _channel.invokeMethod<bool>('deleteEntry', {
            'treeUri': treeUri,
            'segments': segments,
            'name': name,
          }) ??
          false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> renameEntry(
    String treeUri,
    List<String> segments,
    String name,
    String newName,
  ) async {
    try {
      return await _channel.invokeMethod<bool>('renameEntry', {
            'treeUri': treeUri,
            'segments': segments,
            'name': name,
            'newName': newName,
          }) ??
          false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> openEntry(
    String treeUri,
    List<String> segments,
    String name,
  ) async {
    try {
      return await _channel.invokeMethod<bool>('openEntry', {
            'treeUri': treeUri,
            'segments': segments,
            'name': name,
          }) ??
          false;
    } on PlatformException {
      return false;
    }
  }

  /// The last native error string, for logs and short debug notes.
  Future<String?> lastError() async {
    try {
      return await _channel.invokeMethod<String>('lastError');
    } on PlatformException {
      return null;
    }
  }
}
