// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UseNamedConstantsTestLanguage300);
  });
}

@reflectiveTest
class UseNamedConstantsTestLanguage300 extends LintRuleTest
    with LanguageVersion300Mixin {
  @override
  String get lintRule => 'use_named_constants';

  /// https://github.com/dart-lang/linter/issues/4201
  test_constantPattern_ifCase() async {
    await assertDiagnostics(r'''
class A {
  const A(this.value);
  final int value;

  static const zero = A(0);
}

void f(A a) {
  if (a case const A(0)) {}
}
''', [
      lint(117, 4),
    ]);
  }

  /// https://github.com/dart-lang/linter/issues/4201
  test_constantPattern_switch() async {
    await assertDiagnostics(r'''
class A {
  const A(this.value);
  final int value;

  static const zero = A(0);
  static const one = A(1);
}

void f(A a) {
  switch (a) {
    case const A(1):
  }
}
''', [
      lint(155, 4),
    ]);
  }
}
