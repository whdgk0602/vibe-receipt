import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vibe_checker/app.dart';

void main() {
  testWidgets('앱 스모크 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: VibeReceiptApp()),
    );
    expect(find.text('VIBE RECEIPT'), findsOneWidget);
  });
}
