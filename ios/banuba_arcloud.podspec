Pod::Spec.new do |s|
    s.name             = 'banuba_arcloud'
    s.version          = '0.0.1'
    s.summary          = 'Banuba plugin for ARCloud'
    s.description      = <<-DESC
  A new flutter plugin project.
                         DESC
    s.homepage         = 'http://example.com'
    s.license          = { :file => '../LICENSE' }
    s.author           = { 'Your Company' => 'email@example.com' }
    s.source           = { :path => '.' }
    s.source_files = 'Classes/**/*'
    s.dependency 'Flutter'
    s.platform = :ios, '10.0'
    s.static_framework = true
    s.swift_version = '5.0'
    s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  end