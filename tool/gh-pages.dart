#!/usr/bin/env dart

import 'dart:io';

import 'package:ghpages_generator/ghpages_generator.dart' as gh;
import 'package:path/path.dart';

main() {
  var gen = new gh.Generator(rootDir: projectDir)
    ..withExamples = true;
  gen.generate(doCustomTask: (workDir) {
    gh.moveExampleAtRoot(workDir);
  });
}

String get projectDir =>
    absolute(
        dirname(
            dirname(Platform.script.toFilePath())));
