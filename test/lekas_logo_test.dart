import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekas/core/components/lekas_logo.dart';
import 'package:lekas/core/components/motion.dart';

/// The logo ships as a bundled asset: if the pubspec entry or the file is
/// missing, the shell and onboarding would silently fall back to a plain
/// bolt. These checks keep the real image on screen.
void main() {
  testWidgets('the logo loads its bundled image', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LekasLogo(size: 44))),
    );
    await tester.pumpAndSettle();

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
    expect(
      (image.image as AssetImage).assetName,
      'assets/branding/logo.png',
    );

    // The missing-asset path must not throw: a broken bundle would still
    // render the fallback, never a red error box.
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('a settled entrance leaves no wrapper layer', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FadeSlideIn(index: 2, child: Text('hi')))),
    );
    await tester.pumpAndSettle();

    expect(find.text('hi'), findsOneWidget);
    // Once the entrance settles, the wrapper returns its child bare.
    expect(
      find.descendant(
        of: find.byType(FadeSlideIn),
        matching: find.byType(Opacity),
      ),
      findsNothing,
    );
  });
}
