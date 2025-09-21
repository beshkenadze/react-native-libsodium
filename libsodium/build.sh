#!/bin/bash
set -euo pipefail

# get current dir of the build script
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$script_dir"

source_file='libsodium-1.0.20-stable.tar.gz'
source_dir='libsodium-stable'
build_dir='build'

# download and verify the source
rm -f "$source_file"
echo "Downloading $source_file..."
curl -fLo "$source_file" "https://download.libsodium.org/libsodium/releases/$source_file"

echo "Downloading signature for $source_file..."
signature_file="$source_file.minisig"
rm -f "$signature_file"
curl -fLo "$signature_file" "https://download.libsodium.org/libsodium/releases/$signature_file"
if [ ! -s "$signature_file" ]; then
  echo "ERROR: signature file '$signature_file' not found or empty after download."
  echo "Tried URL: https://download.libsodium.org/libsodium/releases/$signature_file"
  exit 1
fi

echo "Downloading minisign public key..."
# use a temp file for the public key so we don't clobber other files
minisign_pubkey=$(mktemp)
trap 'rm -f "$minisign_pubkey"' EXIT
curl -fLo "$minisign_pubkey" "https://download.libsodium.org/minisign.pub"
if [ ! -s "$minisign_pubkey" ]; then
  echo "ERROR: minisign public key download failed or file is empty."
  exit 1
fi

echo "Verifying $source_file with minisign..."
minisign -Vm "$source_file" -p "$minisign_pubkey" || exit 1

# extract source from previous builds
rm -rf $source_dir
# extract tar
tar -xzf $source_file
cd $source_dir

current_platform=`uname`

if [ "$current_platform" == 'Darwin' ]; then
  IOS_VERSION_MIN=10.0.0 dist-build/apple-xcframework.sh
fi

NDK_PLATFORM=android-21 dist-build/android-armv7-a.sh
NDK_PLATFORM=android-21 dist-build/android-armv8-a.sh
NDK_PLATFORM=android-21 dist-build/android-x86.sh
NDK_PLATFORM=android-21 dist-build/android-x86_64.sh

cd ..

# move compiled libraries
mkdir -p $build_dir
rm -rf $build_dir/*

if [ "$current_platform" == 'Darwin' ]; then
  mv $source_dir/libsodium-apple $build_dir/
fi

for dir in $source_dir/libsodium-android-*
do
  mv $dir $build_dir/
done

# create library archive
tar -cvzf build.tgz $build_dir

# cleanup downloaded source
rm $source_file
rm -rf $source_dir
