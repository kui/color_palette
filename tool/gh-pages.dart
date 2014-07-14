#!/usr/bin/env dart

import 'dart:io';
import 'dart:async';

import 'package:ghpages_generator/ghpages_generator.dart' as gh;
import 'package:path/path.dart' as path;

String PROJECT_DIR =
    path.absolute(
        path.dirname(
            path.dirname(Platform.script.toFilePath())));
String EXAMPLE_DIR = path.join(PROJECT_DIR, 'example');

main() {
  generateIndexes()
    .then((files) => generateGhPages().then((_) => files))
    .then((files) => deleteIndexes(files));
}

/**
 * return generated index pages
 */
Future<List<File>> generateIndexes() {
  Stream<File> targetIndexes =
    exampleSubDirs
      .map((d) => path.join(d.path, 'index.html'))
      .map((String i) => new File(i))

      // remove already existing indexes
      .asyncExpand((File i) => i.exists()
        .then((existing) => (existing) ? null : i)
        .asStream()
        .where((i) => i != null));

  return targetIndexes
      .asyncExpand((f) => generateIndexex(f).asStream())
      .toList();
}

Stream<Directory> get exampleSubDirs {
  StreamController<Directory> dirsController =
    new StreamController.broadcast();

  var subs = new Directory(EXAMPLE_DIR).list(recursive: true)
    .where((e) => e is Directory)
    .where((Directory d) => !isPackagesSubDir(d.path));

  new Future(() => new Directory(EXAMPLE_DIR))
    .then((d) => dirsController.add(d))
    .then((_) => subs.pipe(dirsController));

  return dirsController.stream;
}

bool isPackagesSubDir(String p) =>
    path.split(path.relative(p, from: PROJECT_DIR)).contains('packages');

Future<File> generateIndexex(File idx) {
  print('Create index page: ${idx.path}');

  var title = '/' + path.dirname(path.relative(idx.path, from: EXAMPLE_DIR));
  var filesFuture = idx.parent.list()
      .map((e) => path.basename(e.path))
      .where((name) => name != 'index.html')
      .where((String name) => name.endsWith('.html'))
      .toList();
  var outputFuture = idx.open(mode: FileMode.WRITE);

  return Future.wait([filesFuture, outputFuture])
      .then((List args) {
        List<String> files = args[0];
        RandomAccessFile output = args[1];
        String content = buildIndexHtml(title, files);
        return output.writeString(content);
      })
      .then((_) => idx);
}

buildIndexHtml(String title, List files) {
  var content = new StringBuffer()
    ..write("""
<meta charset="utf-8">
<title>$title</title>
<h1>$title</h1>
""");
  if (files.isEmpty) {
    content.writeln('<p>No content</p>');
  } else {
    content.writeln('<ul>');
    files.forEach((f) => content.write('<li><a href="$f">$f</a></li>\n'));
    content.writeln('</ul>');
  }
  return content.toString();
}

Future<List<File>> deleteIndexes(Iterable<File> indexes) {
  return Future.wait(indexes.map((f) {
    print('Delete index page: ${f.path}');
    return f.delete();
  }));
}

Future generateGhPages() {
  var gen = new gh.Generator(rootDir: PROJECT_DIR)
    ..withExamples = true;
  return gen.generate(doCustomTask: (workDir) {
    gh.moveExampleAtRoot(workDir);
  });
}

