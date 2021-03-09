Pod::Spec.new do |s|
  s.name             = 'TortoiseGraphics'
  s.version          = '1.0.0-beta.3'
  s.summary          = 'A turtle graphics (a key feature of the Logo) engine written in Swift.'
  s.description      = 'A turtle graphics (a key feature of the Logo) engine written in Swift. The commands were implemented with reference to the turtle in Python 3 standard libraries.'
  s.homepage         = 'https://github.com/temoki/TortoiseGraphics'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = 'temoki'
  s.source           = { :git => 'https://github.com/temoki/TortoiseGraphics.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/temoki'
  s.swift_version    = '5.1'
  s.source_files     = 'PlaygroundBook/Sources/Core/*', 'PlaygroundBook/Sources/Playground/*'
  s.frameworks       = 'CoreGraphics'
  s.ios.framework    = 'UIKit'
  s.ios.deployment_target = '13.0'
end
