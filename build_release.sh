#!/bin/bash
set -euo pipefail

FLUTTER_BIN="${FLUTTER_BIN:-.fvm/flutter_sdk/bin/flutter}"

# 1. add script permission
# `chmod +x build_release.sh`
# 2. run build scripts
# `./build_release.sh`

# Read the name and version from pubspec.yaml
name=$(grep '^name:' pubspec.yaml | sed 's/^name: //' | tr -d '_')
version=$(grep '^version:' pubspec.yaml | sed 's/^version: //')

# Replace '+' with '.' in the version for package naming
version_with_dot=${version//+/\.}
version_for_zip=${version//+/-}

# Extract the main version (major.minor.patch)
main_version=$(echo $version | cut -d "+" -f1)

# Define the package file names
android_apk_package="${name}_${version_with_dot}.apk"
android_aab_package="${name}_${version_with_dot}.aab"
ios_package="${name}_${version_with_dot}.ipa"
archive="${version_for_zip}.zip"

# Create the release-package and target directories
release_package_directory="release-package"
target_directory="${release_package_directory}/${main_version}"
mkdir -p $target_directory

# Use the checked-in lockfile for reproducible release builds.
env -u FLUTTER_STORAGE_BASE_URL -u PUB_HOSTED_URL "$FLUTTER_BIN" pub get --enforce-lockfile

# Build the Android APK
env -u FLUTTER_STORAGE_BASE_URL -u PUB_HOSTED_URL "$FLUTTER_BIN" build apk --release
mv build/app/outputs/flutter-apk/app-release.apk $target_directory/$android_apk_package

# Build the Android App Bundle. Use Gradle directly so release AABs do not
# embed native debug symbols in BUNDLE-METADATA.
(
  cd android
  ./gradlew :app:bundleRelease
)
mv build/app/outputs/bundle/release/app-release.aab $target_directory/$android_aab_package

# Build the iOS release package
env -u FLUTTER_STORAGE_BASE_URL -u PUB_HOSTED_URL "$FLUTTER_BIN" build ipa --release
mv build/ios/ipa/Aurowallet.ipa $target_directory/$ios_package

# Compress the packages into a single archive
cd $target_directory
zip $archive $android_apk_package $android_aab_package $ios_package
cd ../..

echo "Build and packaging completed. Archive created: $target_directory/$archive"
