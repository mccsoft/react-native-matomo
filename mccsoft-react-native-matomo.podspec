require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name          = "mccsoft-react-native-matomo"
  s.version       = package["version"]
  s.summary       = package["description"]
  s.homepage      = package["homepage"]
  s.license       = package["license"]
  s.authors       = package["author"]

  s.swift_version = '5.0'
  s.platforms     = { :ios => "11.0", :tvos => "13.0" }
  s.source        = { :git => "https://github.com/mccsoft/react-native-matomo.git", :tag => "#{s.version}" }


  s.source_files  = "ios/**/*.{h,m,mm,swift}"

  s.dependency "React-Core"
  s.dependency "MatomoTracker", "7.8.0"
end
