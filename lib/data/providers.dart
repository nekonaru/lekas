import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'lekas.sqlite'));
    return NativeDatabase.createInBackground(file);
  }));
  ref.onDispose(db.close);
  return db;
});