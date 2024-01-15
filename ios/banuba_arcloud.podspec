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
    s.platform = :ios, '14.0'
    s.swift_version = '5.5.1'

    version = '1.32.1'
    s.dependency 'BanubaARCloudSDK', version
    s.dependency 'BanubaUtilities', version
  end
