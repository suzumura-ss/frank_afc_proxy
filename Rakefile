require "bundler/gem_tasks"
require File.expand_path('../lib/frank_afc_proxy/version', __FILE__)

def discover_latest_sdk_for(platform)
  `xcodebuild -showsdks | grep -o "#{platform}.*$" | sort | tail -n 1`.chomp
end

def build_dir
  File.expand_path('../build', __FILE__)
end

def build_ios_library(platform)
  sdk = discover_latest_sdk_for(platform)
  puts "building #{{sdk:sdk}}"
  preprocessor_flag = %Q|GCC_PREPROCESSOR_DEFINITIONS='$(inherited) FRANKAFCPROXY_PRODUCT_VERSION=\"#{FrankAfcProxy::VERSION}\"'|
  sh "xcodebuild -project FrankAfcProxy.xcodeproj -configuration Release -sdk #{sdk} BUILD_DIR=\"#{build_dir}\" #{preprocessor_flag} clean build"
end

task :build_iphone_lib do
  build_ios_library('iphoneos')
end

task :build_simulator_lib do
  build_ios_library('iphonesimulator')
end

task :combine_libraries do
  `lipo -create -output "dist/libFrankAfcProxy.a" "#{build_dir}/Release-iphoneos/libFrankAfcProxy.a" "#{build_dir}/Release-iphonesimulator/libFrankAfcProxy.a"`
end

task :build_ios_lib => [:build_iphone_lib, :build_simulator_lib, :combine_libraries]


desc "clean build artifacts"
task :clean do
  rm_rf 'dist'
  rm_rf "#{build_dir}"
  rm_rf 'FrankAfcProxy.xcodeproj/project.xcworkspace'
  rm_rf 'FrankAfcProxy.xcodeproj/xcuserdata'
end

task :prep_dist do
  mkdir_p 'dist'
  mkdir_p "#{build_dir}"
end

desc "build library"
task :build_lib => [:clean, :prep_dist, :build_ios_lib]


task :copy_to_skeleton do
  sh "cp -r dist/* frankAfcProxy-skeleton/"
end

desc "build and copy into the skeleton dir."
task :build_for_release => [:build_lib, :copy_to_skeleton]


desc "build library and build gem."
task :all => [:build_for_release, :build]
