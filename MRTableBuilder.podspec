Pod::Spec.new do |s|
  s.name             = "MRTableBuilder"
  s.version          = "0.1.0"
  s.summary          = "A declarative, block-based helper class to configure UITableViews."
  s.homepage         = "https://github.com/martinrybak/MRTableBuilder"
  s.license          = 'MIT'
  s.author           = { "Martin Rybak" => "martin.rybak@gmail.com" }
  s.source           = { :git => "https://github.com/martinrybak/MRTableBuilder.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'MRTableBuilder' => ['Pod/Assets/*.png']
  }
end
