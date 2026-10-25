import 'package:drift/drift.dart';
import 'database.dart';
import 'models.dart';

class DiagnosticRepository {
  final AppDatabase db;
  DiagnosticRepository(this.db);

  Stream<List<Diagnostic>> watchDiagnostics() {
    return db.select(db.diagnostics).watch();
  }

  Future<List<Diagnostic>> getDiagnostics() async {
    return db.select(db.diagnostics).get();
  }

  Future<void> insertDiagnostic(Diagnostic diagnostic) async {
    await db.into(db.diagnostics).insert(diagnostic);
  }
}
