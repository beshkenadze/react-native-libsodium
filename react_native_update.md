# React Native Update Guide

This document provides comprehensive instructions for updating React Native in the `react-native-libsodium` project, both for library maintainers and library consumers.

## Current Status

- **Current React Native version**: 0.71.6
- **Latest stable React Native version**: 0.81.4 (as of documentation date)
- **Node.js requirement**: >= 20.19.0
- **TypeScript version**: 5.0.4

## Checking for Updates

Before performing an update, check the current status:

```bash
# Check current versions
npm list react-native
npm outdated react-native

# Check what React Native versions are available
npm view react-native versions --json | tail -10

# Check for security vulnerabilities
npm audit
```

## Table of Contents

1. [For Library Maintainers](#for-library-maintainers)
2. [For Library Consumers](#for-library-consumers)
3. [Version Compatibility Matrix](#version-compatibility-matrix)
4. [Breaking Changes](#breaking-changes)
5. [Troubleshooting](#troubleshooting)
6. [Testing Updates](#testing-updates)

## For Library Maintainers

### Pre-Update Checklist

Before updating React Native, ensure you have:

- [ ] Backed up the current working state
- [ ] Reviewed React Native changelog for breaking changes
- [ ] Checked native dependencies compatibility
- [ ] Verified CI/CD pipeline is green
- [ ] Updated Node.js to the recommended version

### Step-by-Step Update Process

#### 1. Update Package Dependencies

Update the main package.json:

```bash
# Update React Native and React
yarn add --dev react-native@<target-version>
yarn add --dev react@<compatible-react-version>

# Update React Native specific dependencies
yarn add --dev @types/react-native@<compatible-types-version>
```

#### 2. Update Example App Dependencies

Update `example/package.json`:

```bash
cd example
yarn add react-native@<target-version>
yarn add react@<compatible-react-version>
yarn add react-native-web@<compatible-web-version>
```

#### 3. Update Native Configuration Files

##### Android Updates

1. **Update `android/build.gradle`**:
   - Update Android Gradle Plugin version
   - Update Gradle wrapper version
   - Update compile/target SDK versions

2. **Update `android/gradle.properties`**:
   - Update Kotlin version if needed
   - Update other Android-specific properties

3. **Update `example/android/build.gradle`**:
   - Mirror changes from main android config

##### iOS Updates

1. **Update `ios/Libsodium.podspec`**:
   - Update iOS deployment target if needed (Note: there's currently a typo "26.0" that should be "12.4")
   - Update dependency versions

2. **Update `example/ios/Podfile`**:
   - Update iOS deployment target
   - Update pod dependencies

3. **Run pod install**:
   ```bash
   cd example/ios && pod install
   ```

#### 4. Update Build and CI Configuration

1. **Update `package.json` scripts** if needed
2. **Update GitHub Actions workflows** (`.github/workflows/`):
   - Update Node.js versions in CI
   - Update Android/iOS build environments
   - Update test runners

3. **Update Metro configuration** if needed:
   - Check `metro.config.js` compatibility
   - Update `babel.config.js` if necessary

#### 5. Update Native Code (C++/Java/ObjC)

1. **Check JSI compatibility**:
   - Review `cpp/react-native-libsodium.cpp` for JSI changes
   - Update method signatures if needed

2. **Android native updates**:
   - Review `android/src/main/java/com/libsodium/LibsodiumModule.java`
   - Update TurboModule interfaces if needed

3. **iOS native updates**:
   - Review `ios/Libsodium.mm`
   - Update TurboModule interfaces if needed

#### 6. Update TypeScript Definitions

1. **Update type imports** in `src/` files:
   - Check for breaking changes in React Native types
   - Update JSI-related types

2. **Update `tsconfig.json`** if needed:
   - Update TypeScript version compatibility
   - Update module resolution settings

### Testing the Update

After completing the update:

1. **Build the library**:
   ```bash
   yarn prepack
   ```

2. **Run tests**:
   ```bash
   yarn test
   yarn typecheck
   yarn lint
   ```

3. **Test example app**:
   ```bash
   cd example
   yarn android  # Test Android
   yarn ios      # Test iOS
   yarn web      # Test Web
   ```

4. **Run E2E tests**:
   ```bash
   yarn test:e2e:web
   ```

5. **Quick verification checklist**:
   ```bash
   # Verify the package builds correctly
   yarn prepack
   
   # Check that all exports are working
   node -e "const lib = require('./lib/commonjs/index.js'); console.log('Exports:', Object.keys(lib).length)"
   
   # Test example apps
   cd example && yarn android --variant=release  # Android
   cd example && yarn ios --configuration=Release  # iOS  
   cd example && yarn web  # Web (opens http://localhost:8080)
   ```

## For Library Consumers

### Updating Your App to Use Latest react-native-libsodium

#### Check Compatibility

Before updating, check the [Version Compatibility Matrix](#version-compatibility-matrix) to ensure your React Native version is supported.

#### Update Process

1. **Update react-native-libsodium**:
   ```bash
   npm install react-native-libsodium@latest
   # or
   yarn add react-native-libsodium@latest
   ```

2. **For React Native CLI projects**:
   ```bash
   cd ios && pod install
   ```

3. **For Expo projects**:
   ```bash
   expo install react-native-libsodium
   ```

4. **Rebuild your app**:
   ```bash
   # React Native CLI
   npx react-native run-android
   npx react-native run-ios
   
   # Expo
   expo run:android
   expo run:ios
   ```

#### Migration Notes

If you're upgrading from an older version, check the [Breaking Changes](#breaking-changes) section for any required code changes.

## Version Compatibility Matrix

| react-native-libsodium | React Native | React | Node.js | Notes |
|------------------------|--------------|-------|---------|-------|
| 1.4.x                  | 0.71.x - 0.73.x | 18.x | >= 20.19.0 | Current stable |
| 1.5.x (planned)        | 0.74.x - 0.76.x | 18.x | >= 20.19.0 | Future release |
| 2.0.x (planned)        | 0.77.x+      | 18.x+ | >= 20.19.0 | Breaking changes expected |

### Platform Support

- **iOS**: Minimum iOS 12.4 (React Native 0.71.6 requirement)
- **Android**: Minimum API level 21 (Android 5.0)
- **Web**: Modern browsers with WebAssembly support

## Breaking Changes

### From React Native 0.71.x to 0.72.x+

- **Metro changes**: New Metro bundler requires configuration updates
- **Android Gradle**: Updated Android Gradle Plugin requirements
- **iOS deployment target**: May require iOS 12.0+

### From React Native 0.73.x to 0.74.x+

- **New Architecture**: Enhanced support for the new React Native architecture
- **JSI changes**: Updated JSI interfaces may require native code updates

### Library-Specific Breaking Changes

When updating react-native-libsodium versions:

#### v1.4.x to v1.5.x (planned)
- No breaking changes expected in public API
- Internal JSI interface updates for newer React Native support

#### v1.x to v2.x (future)
- Potential API changes for better TypeScript support
- Updated minimum React Native version requirements

## Troubleshooting

### Common Issues and Solutions

#### Build Errors After Update

**Issue**: `Unable to resolve module` errors
**Solution**: 
```bash
# Clear Metro cache
npx react-native start --reset-cache

# Clear npm/yarn cache
npm start -- --reset-cache
# or
yarn start --reset-cache
```

**Issue**: Android build failures
**Solution**:
```bash
cd android && ./gradlew clean
cd .. && npx react-native run-android
```

**Issue**: iOS build failures
**Solution**:
```bash
cd ios && rm -rf Pods Podfile.lock
pod install
cd .. && npx react-native run-ios
```

#### JSI-Related Issues

**Issue**: `jsi_crypto_*` functions not found
**Solution**: 
- Ensure the native module is properly installed
- Verify `install()` is called in your app initialization
- Check platform-specific installation guides

#### TypeScript Errors

**Issue**: Type definition conflicts
**Solution**:
```bash
# Clear TypeScript cache
rm -rf node_modules/.cache
npm install
# or
yarn install
```

### Platform-Specific Issues

#### Android

- **Gradle version conflicts**: Update `android/gradle/wrapper/gradle-wrapper.properties`
- **NDK version**: Ensure NDK version is compatible with React Native version
- **ProGuard/R8**: Update obfuscation rules if needed

#### iOS

- **Xcode version**: Ensure Xcode version supports the React Native version
- **CocoaPods**: Update CocoaPods if pod install fails
- **Swift version**: May need to update Swift language version in Xcode

#### Web

- **WebAssembly support**: Ensure target browsers support WebAssembly
- **Webpack configuration**: Update webpack config for new Metro bundler changes

## Testing Updates

### Automated Testing

1. **Unit Tests**:
   ```bash
   yarn test
   ```

2. **Type Checking**:
   ```bash
   yarn typecheck
   ```

3. **Linting**:
   ```bash
   yarn lint
   ```

4. **E2E Tests**:
   ```bash
   yarn test:e2e:web
   ```

### Manual Testing

1. **Basic functionality**: Test core crypto functions
2. **Platform compatibility**: Test on target platforms
3. **Performance**: Verify no performance regressions
4. **Memory leaks**: Check for memory leaks in long-running tests

### Testing Checklist

- [ ] All crypto functions work correctly
- [ ] `ready` Promise resolves properly (web platform)
- [ ] `loadSumoVersion()` works (web platform)
- [ ] JSI functions are properly exposed
- [ ] No crashes on app startup
- [ ] No memory leaks in crypto operations
- [ ] TypeScript definitions are accurate
- [ ] Example app builds and runs on all platforms

## Additional Resources

- [React Native Upgrade Guide](https://react-native-community.github.io/upgrade-helper/)
- [React Native Releases](https://github.com/facebook/react-native/releases)
- [Libsodium Documentation](https://doc.libsodium.org/)
- [libsodium-wrappers npm package](https://www.npmjs.com/package/libsodium-wrappers)

---

For questions or issues with React Native updates, please:
1. Check this documentation first
2. Search existing GitHub issues
3. Create a new issue with detailed information about your setup and the error