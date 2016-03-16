Pod::Spec.new do |s|
  s.name = 'Haitch'
  s.version = '0.6'
  s.license = 'Posse'
  s.summary = 'Simple HTTP for Swift'
  s.homepage = 'https://github.com/goposse/haitch'
  s.social_media_url = 'http://twitter.com/goposse'
  s.authors = { 'Posse Productions LLC' => 'apps@goposse.com' }
  s.source = { :git => 'https://github.com/goposse/haitch.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
 
  s.source_files = 'Source/**/*.swift'

  s.requires_arc = true
end