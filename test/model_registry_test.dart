import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kidscientia/model_registry.dart';

void main() {
  group('ModelRegistry.resolve', () {
    test('matches QR values scanned as website paths', () {
      expect(
        ModelRegistry.resolve('www.my-website.com/lungs')?.displayName,
        'Lungs',
      );
      expect(
        ModelRegistry.resolve('www.my-website.com/stomach')?.displayName,
        'Stomach',
      );
      expect(
        ModelRegistry.resolve('www.my-website.com/eye')?.displayName,
        'Eye',
      );
      expect(
        ModelRegistry.resolve('www.my-website.com/ear')?.displayName,
        'Ear',
      );
    });

    test('normalizes common QR formatting variations', () {
      expect(
        ModelRegistry.resolve('"www.my-website.com/lungs"')?.displayName,
        'Lungs',
      );
      expect(
        ModelRegistry.resolve('"www.my-website.com/lungs')?.displayName,
        'Lungs',
      );
      expect(
        ModelRegistry.resolve('www.my-website.com/lungs"\n')?.displayName,
        'Lungs',
      );
      expect(
        ModelRegistry.resolve(
          'https://www.my-website.com/red-panda',
        )?.displayName,
        'Red Panda',
      );
      expect(
        ModelRegistry.resolve(
          'assets/models/GEOLOGY/TECTONIC_PLATE.glb',
        )?.displayName,
        'Tectonic Plate',
      );
      expect(ModelRegistry.resolve('newbearD')?.displayName, 'Bear');
    });

    test('resolves geology and hammerhead flashcard wording', () {
      expect(
        ModelRegistry.resolve('sedimentary rock')?.displayName,
        'Sedimentary Rocks',
      );
      expect(
        ModelRegistry.resolve('metamorphic rock')?.displayName,
        'Metamorphic Rocks',
      );
      expect(
        ModelRegistry.resolve('igneous rock')?.displayName,
        'Igneous Rocks',
      );
      expect(ModelRegistry.resolve('gold')?.displayName, 'Gold Rock');
      expect(ModelRegistry.resolve('diamond')?.displayName, 'Diamond Rock');
      expect(
        ModelRegistry.resolve('hammer head shark')?.displayName,
        'Hammerhead Shark',
      );
      expect(
        ModelRegistry.resolve('hammer&#x20;head&#x20;shark')?.displayName,
        'Hammerhead Shark',
      );
      expect(
        ModelRegistry.resolve('www.my-website.com/sedimentary-rock')
            ?.displayName,
        'Sedimentary Rocks',
      );
    });

    test('normalizes to the model key that actually matched', () {
      expect(
        ModelRegistry.normalizeQrValue('www.my-website.com/lungs'),
        'lungs',
      );
      expect(
        ModelRegistry.normalizeQrValue('https://www.my-website.com/red-panda'),
        'red panda',
      );
      expect(
        ModelRegistry.normalizeQrValue(
          'assets/models/GEOLOGY/TECTONIC_PLATE.glb',
        ),
        'tectonic plate',
      );
    });

    test('resolves every registered key and website QR path', () {
      for (final key in ModelRegistry.registeredKeys) {
        expect(
          ModelRegistry.resolve(key),
          isNotNull,
          reason: 'Registered QR key should resolve: $key',
        );
        expect(
          ModelRegistry.resolve('www.my-website.com/$key'),
          isNotNull,
          reason: 'Website QR path should resolve: $key',
        );
      }
    });

    test('resolves every alias key', () {
      for (final alias in ModelRegistry.aliasKeys) {
        expect(
          ModelRegistry.resolve(alias),
          isNotNull,
          reason: 'Alias QR key should resolve: $alias',
        );
      }
    });

    test('all registered model assets exist and are bundled', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();

      for (final entry in ModelRegistry.registeredEntries) {
        final projectAssetPath = entry.assetPath.replaceFirst(
          'flutter_assets/',
          '',
        );
        expect(
          File(projectAssetPath).existsSync(),
          isTrue,
          reason: '${entry.displayName} file is missing: $projectAssetPath',
        );
        expect(
          pubspec,
          contains('- $projectAssetPath'),
          reason: '${entry.displayName} is not bundled in pubspec.yaml',
        );
      }
    });

    test('every bundled GLB model has a registry entry', () {
      final registeredAssetPaths = ModelRegistry.registeredEntries
          .map((entry) => entry.assetPath.replaceFirst('flutter_assets/', ''))
          .toSet();
      final modelFiles = Directory('assets/models')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.toLowerCase().endsWith('.glb'))
          .map((file) => file.path.replaceAll('\\', '/'))
          .toSet();

      expect(
        registeredAssetPaths.containsAll(modelFiles),
        isTrue,
        reason:
            'Missing registry entries for: ${modelFiles.difference(registeredAssetPaths).join(', ')}',
      );
    });
  });
}
