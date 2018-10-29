Pod::Spec.new do |s|
  s.name                  = 'rebekka'
  s.version               = '1.0.4'
  s.license               = { :type => 'MIT', :file => 'License.txt' }
  s.authors               = { 'Constantine Fry' => '', 'Guillaume Bellue' => 'guillaume.bellue@wopata.com' }
  s.summary               = 'Rebekka - FTP/FTPS client in Swift.'
  s.homepage              = 'https://github.com/yomw/rebekka'
  s.source                = { :git => 'https://github.com/yomw/rebekka.git', :tag => '1.0.4'}
  s.source_files          = 'rebekka-source/**/*.{swift}'

  s.platform              = :ios
  s.ios.deployment_target = '8.0'
  s.requires_arc          = true
end
