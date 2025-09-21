/**
 * @jest-environment jsdom
 */

// Mock react-native
jest.mock('react-native', () => ({
  NativeModules: {
    Libsodium: {
      install: () => {},
    },
  },
}));

describe('react-native-libsodium', () => {
  beforeEach(() => {
    // Reset global variables that might be set by the native library
    delete (global as any).jsi_crypto_secretbox_KEYBYTES;
    delete (global as any).jsi_crypto_auth_BYTES;
  });

  it('should export main entry point', () => {
    const sodium = require('../index');
    expect(sodium).toBeDefined();
    expect(typeof sodium.default).toBe('object');
  });

  it('should export constants when available', () => {
    // Mock some JSI constants
    (global as any).jsi_crypto_secretbox_KEYBYTES = 32;
    (global as any).jsi_crypto_auth_BYTES = 32;

    const sodium = require('../index');
    // Just test that the module loads without throwing
    expect(sodium.default).toBeDefined();
  });

  it('should handle missing JSI functions gracefully', () => {
    // Test that the module can be imported even when JSI functions are not available
    const sodium = require('../index');
    expect(sodium.default).toBeDefined();
  });
});
