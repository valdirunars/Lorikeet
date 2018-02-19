Pod::Spec.new do |s|
s.name             = "Lorikeet"
s.version          = "0.2.26"
s.summary          = "Lightweight framework for generating visually aesthetic color-schemes in Swift"
s.description      = "Lightweight framework for generating visually aesthetic color-schemes in Swift"
s.homepage         = "https://github.com/valdirunars/Lorikeet"
s.license          = 'MIT'
s.author           = { "valdirunars" => "valdirunars@gmail.com" }
s.source           = { :git => "https://github.com/valdirunars/Lorikeet.git", :tag => s.version.to_s }
s.platform     = :ios, '9.1'
s.requires_arc = true
s.source_files = 'Lorikeet/*'

end
