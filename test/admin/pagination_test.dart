import 'package:flutter_test/flutter_test.dart';
import 'package:movies_app/admin/shared/pagination.dart';

void main() {
  test('Pagination default values', () {
    final p = Pagination();
    expect(p.page, 0);
    expect(p.perPage, 25);
  });

  test('Pagination custom values', () {
    final p = Pagination(page: 2, perPage: 50);
    expect(p.page, 2);
    expect(p.perPage, 50);
  });
}

