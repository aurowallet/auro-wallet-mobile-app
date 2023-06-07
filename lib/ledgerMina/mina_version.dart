class MinaVersion {
  // final bool testMode;
  final int versionMajor;
  final int versionMinor;
  final int versionPatch;

  // final bool locked;

  MinaVersion({
    // required this.testMode,
    required this.versionMajor,
    required this.versionMinor,
    required this.versionPatch,
    // required this.locked,
  });

  /// Get the version code.
  int get versionCode =>
      versionMajor * 10000 + versionMinor * 100 + versionPatch;

  /// Get the version name.
  String get versionName => '$versionMajor.$versionMinor.$versionPatch';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MinaVersion &&
          runtimeType == other.runtimeType &&
          versionMajor == other.versionMajor &&
          versionMinor == other.versionMinor &&
          versionPatch == other.versionPatch;

  @override
  int get hashCode =>
      versionMajor.hashCode ^ versionMinor.hashCode ^ versionPatch.hashCode;
}
