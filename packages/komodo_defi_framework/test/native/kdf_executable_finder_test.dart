import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_defi_framework/src/native/kdf_executable_finder.dart';
import 'package:path/path.dart' as p;

void main() {
  final finder = KdfExecutableFinder(logCallback: (_) {});

  test('uses the native Linux ARM64 bundle path', () {
    expect(
      finder.constructLinuxBuildArtifactPath(abi: Abi.linuxArm64),
      endsWith(
        p.join('build', 'linux', 'arm64', 'release', 'bundle', 'lib', 'kdf'),
      ),
    );
  });

  test('preserves the Linux x64 bundle path', () {
    expect(
      finder.constructLinuxBuildArtifactPath(abi: Abi.linuxX64),
      endsWith(
        p.join('build', 'linux', 'x64', 'release', 'bundle', 'lib', 'kdf'),
      ),
    );
  });

  test('finds an installed Linux KDF beside the wallet executable', () {
    expect(
      finder.constructLinuxInstalledArtifactPath(
        hostExecutablePath: p.join('opt', 'stashi', 'stashi-wallet'),
      ),
      p.join('opt', 'stashi', 'lib', 'kdf'),
    );
  });
}
