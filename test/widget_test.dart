import 'package:flutter_test/flutter_test.dart';
import 'package:alpenexplorer/main.dart';

void main() {
  test('AlpenExplorerApp kann instanziiert werden', () {
    const app = AlpenExplorerApp();
    expect(app, isA<AlpenExplorerApp>());
  });
}
