// A simple script to generate Hive adapters and JSON serialization code
// This script can be run with `dart run generate_models.dart`

import 'dart:io';

void main() async {
  print('Running build_runner to generate model adapters...');
  
  final result = await Process.run(
    'flutter', 
    ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    runInShell: true,
  );
  
  print(result.stdout);
  
  if (result.exitCode != 0) {
    print('Error: ${result.stderr}');
    exit(1);
  }
  
  print('Model generation completed successfully!');
}
