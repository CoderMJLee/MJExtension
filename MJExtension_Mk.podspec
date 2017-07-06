Pod::Spec.new do |s|
  s.name         = "MJExtension_Mk"
  s.version      = "3.0.14"
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'
  s.summary      = "A fast and convenient conversion between JSON and model"
  s.homepage     = "https://github.com/markalex25/MJExtension"
  s.license      = "MIT"
  s.author             = { "Markalex25" => "markalex25@163.com" }
  s.social_media_url   = "http://weibo.com/exceptions"
  s.source       = { :git => "https://github.com/markalex25/MJExtension.git", :tag => s.version }
  s.source_files  = "MJExtension_Mk"
  s.requires_arc = true
end
