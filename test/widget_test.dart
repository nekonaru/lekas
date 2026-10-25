import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lekas/main.dart';

void main() {
  testWidgets('app builds', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LekasApp()));
    await tester.pump();
    expect(find.text('Lekas'), findsOneWidget);
  });
}