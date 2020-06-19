
Pod::Spec.new do |s|
s.name         = "DSHImagePicker"
s.version      = "0.0.1"
s.summary      = "图片选择器"
s.description  = <<-DESC
视频/图片选择器
                DESC
s.homepage     = "https://www.baidu.com"
s.license      = { :type => "MIT", :file => "../LICENSE" }
s.author       = { "lu" => "568071718@qq.com" }
s.platform     = :ios, "9.0"
s.source       = { :path => "Classes", :tag => s.version }
s.requires_arc = true
s.source_files = 'Classes'
s.resources = 'Resources/*'

s.dependency 'Masonry'
end
