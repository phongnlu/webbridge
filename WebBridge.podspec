Pod::Spec.new do |spec|
  spec.name = "WebBridge"
  spec.version = "0.0.1"
  spec.summary = "Enable 2 way communication between a remote webapp and native code"
  spec.homepage = "https://github.com/phongnlu/webbridge"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Your Name" => 'phongnlu@gmail.com' }

  spec.platform = :ios, "9.0"
  spec.swift_version = "4.0"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/phongnlu/webbridge/WebBridge.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "WebBridge/**/*.{h,swift}"

  spec.dependency "SwiftyJSON", "~> 4.0.0"
end