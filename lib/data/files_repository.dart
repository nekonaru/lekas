import '../core/files_channel.dart';
import 'settings_repository.dart';

/// The course file store: thin repository that keeps the picked tree uri
/// in settings and composes the native calls. Screens use this, never the
/// raw channel.
class FilesRepository {
  FilesRepository(this._settings, this._channel);

  final SettingsRepository _settings;
  final FilesChannel _channel;

  static const String _treeKey = 'lekas_tree_uri';

  /// Null while the user never picked a folder.
  Future<String?> rootUri() async {
    final value = await _settings.get(_treeKey);
    if (value == null || value.trim().isEmpty) return null;
    return value;
  }

  Future<void> setRootUri(String? uri) async {
    await _settings.set(_treeKey, uri ?? '');
  }

  /// The segments between the picked root and [courseName]: `Lekas/Nama`.
  List<String> courseSegments(String courseName) => courseFileRoot(courseName);

  /// Makes sure the store folder exists; false when the picked tree is no
  /// longer readable (the screen shows the setup callout again).
  Future<bool> ensureCourseRoot(String tree, String courseName) =>
      _channel.ensureFolder(tree, courseSegments(courseName));

  Future<List<FolderEntry>> listCourseFiles(
    String tree,
    String courseName,
    List<String> relativePath,
  ) =>
      _channel.listFolder(tree, [...courseSegments(courseName), ...relativePath]);

  Future<bool> createFolder(
    String tree,
    String courseName,
    List<String> relativePath,
    String name,
  ) =>
      _channel.createFolder(
        tree,
        [...courseSegments(courseName), ...relativePath],
        name,
      );

  Future<bool> importFile(
    String tree,
    String courseName,
    List<String> relativePath,
    String displayName,
    String sourcePath,
  ) =>
      _channel.importFile(
        tree,
        [...courseSegments(courseName), ...relativePath],
        displayName,
        sourcePath,
      );

  Future<bool> validNameAvailable(
    String tree,
    String courseName,
    List<String> relativePath,
    String name,
  ) async {
    final entries = await listCourseFiles(tree, courseName, relativePath);
    final lower = name.toLowerCase();
    return !entries.any((entry) => entry.name.toLowerCase() == lower);
  }

  Future<bool> deleteEntry(
    String tree,
    String courseName,
    List<String> relativePath,
    String name,
  ) =>
      _channel.deleteEntry(
        tree,
        [...courseSegments(courseName), ...relativePath],
        name,
      );

  Future<bool> renameEntry(
    String tree,
    String courseName,
    List<String> relativePath,
    String name,
    String newName,
  ) =>
      _channel.renameEntry(
        tree,
        [...courseSegments(courseName), ...relativePath],
        name,
        newName,
      );

  Future<bool> openEntry(
    String tree,
    String courseName,
    List<String> relativePath,
    String name,
  ) =>
      _channel.openEntry(
        tree,
        [...courseSegments(courseName), ...relativePath],
        name,
      );
}
