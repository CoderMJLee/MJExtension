Pod::Spec.new do |s|
  s.name         = "MJExtension"
  s.version      = "2.0.4"
  s.summary      = "The fastest and most convenient conversion between JSON and model"
  s.homepage     = "https://github.com/CoderMJLee/MJExtension"
  s.license      = "MIT"
  s.author             = { "MJLee" => "199109106@qq.com" }
  s.social_media_url   = "http://weibo.com/exceptions"
  s.source       = { :git => "https://github.com/CoderMJLee/MJExtension.git", :tag => s.version }
  s.source_files  = "MJExtensionExample/MJExtensionExample/MJExtension"
  s.requires_arc = true
end
