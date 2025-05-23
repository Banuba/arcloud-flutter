Pod::Spec.new do |s|
    s.name             = 'banuba_arcloud'
    s.version          = '1.0.4'
    s.summary          = 'Banuba plugin for ARCloud'
    s.description      = <<-DESC
  A new flutter plugin project.
                         DESC
    s.homepage         = 'https://banuba.com'
    s.license          = { :file => '../LICENSE' }
    s.author           = { 'Your Company' => 'info@banuba.com' }
    s.source           = { :path => '.' }
    s.source_files = 'Classes/**/*'
    s.dependency 'Flutter'
    s.platform = :ios, '14.0'
    s.swift_version = '5.5.1'

    version = '1.43.0'
    s.dependency 'BanubaARCloudSDK', version
    s.dependency 'BanubaUtilities', version
  end
