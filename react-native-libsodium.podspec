require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

# Load React Native pod utilities to get the correct Folly configuration
react_native_node_modules_dir = File.join(__dir__, '..', 'node_modules', 'react-native')
if File.exist?(File.join(react_native_node_modules_dir, 'scripts', 'react_native_pods.rb'))
  require File.join(react_native_node_modules_dir, 'scripts', 'react_native_pods.rb')
end

# Use React Native's Folly configuration if available, otherwise fallback to default
begin
  folly_config = get_folly_config()
  folly_compiler_flags = folly_config[:compiler_flags] || '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'
rescue => e
  # Fallback for older React Native versions or when react_native_pods.rb is not available
  folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'
end

Pod::Spec.new do |s|
  s.name         = "react-native-libsodium"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "12.4" }
  s.source       = { :git => "https://github.com/beshkenadze/react-native-libsodium.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm}", "cpp/**/*.{h,cpp}"

  s.vendored_frameworks = "libsodium/build/libsodium-apple/Clibsodium.xcframework"

  s.dependency "React-Core"

  # Don't install the dependencies when we run `pod install` in the old architecture.
  if ENV['RCT_NEW_ARCH_ENABLED'] == '1' then
    # Use React Native's install_modules_dependencies helper if available
    if respond_to?(:install_modules_dependencies, true)
      install_modules_dependencies(s)
    else
      # Fallback for older React Native versions
      s.compiler_flags = folly_compiler_flags + " -DRCT_NEW_ARCH_ENABLED=1"
      s.pod_target_xcconfig    = {
          "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/boost\"",
          "OTHER_CPLUSPLUSFLAGS" => "-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1",
          "CLANG_CXX_LANGUAGE_STANDARD" => "c++17"
      }
      s.dependency "React-Codegen"
      s.dependency "RCT-Folly"
      s.dependency "RCTRequired"
      s.dependency "RCTTypeSafety"
      s.dependency "ReactCommon/turbomodule/core"
    end
  end

end
