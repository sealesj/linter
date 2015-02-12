// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library unnecessary_getters_setters;

import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:dart_lint/src/ast.dart';
import 'package:dart_lint/src/linter.dart';

const desc = 'AVOID wrapping fields in getters and setters just to be "safe".';

const details = '''
From the [style guide] (https://www.dartlang.org/articles/style-guide/):

*AVOID** wrapping fields in getters and setters just to be "safe".

In Java and C#, it's common to hide all fields behind getters and setters 
(or properties in C#), even if the implementation just forwards to the field. 
That way, if you ever need to do more work in those members, you can without 
needing to touch the callsites. This is because calling a getter method is 
different than accessing a field in Java, and accessing a property isn't 
binary-compatible with accessing a raw field in C#.

Dart doesn't have this limitation. Fields and getters/setters are completely 
indistinguishable. You can expose a field in a class and later wrap it in a 
getter and setter without having to touch any code that uses that field.

**GOOD:**

```
class Box {
  var contents;
}
```

**BAD:**

```
class Box {
  var _contents;
  get contents => _contents;
  set contents(value) {
    _contents = value;
  }
}
```
''';

class UnnecessaryGettersSetters extends LintRule {
  UnnecessaryGettersSetters()
      : super(
          name: 'UnnecessaryGettersSetters',
          description: desc,
          details: details,
          group: Group.STYLE_GUIDE,
          kind: Kind.AVOID);

  @override
  AstVisitor getVisitor() => new Visitor(this);
}

class Visitor extends SimpleAstVisitor {
  LintRule rule;
  Visitor(this.rule);

  @override
  visitClassDeclaration(ClassDeclaration node) {
    Map<String, MethodDeclaration> getters = {};
    Map<String, MethodDeclaration> setters = {};

    // Build getter/setter maps
    var methods = node.members.where(isMethod);
    for (var method in methods) {
      if (method.isGetter) {
        getters[method.name.toString()] = method;
      } else if (method.isSetter) {
        setters[method.name.toString()] = method;
      }
    }

    // Only select getters with setter pairs
    var candidates = getters.keys.where((id) => setters.keys.contains(id));
    candidates.forEach((id) => _visitGetterSetter(getters[id], setters[id]));
  }

  _visitGetterSetter(MethodDeclaration getter, MethodDeclaration setter) {
    if (isSimpleSetter(setter) && isSimpleGetter(getter)) {
      rule.reportLint(getter);
      rule.reportLint(setter);
    }
  }
}
