Pod::Spec.new do |spec|
  spec.name         = 'TOMJSONAdapter'
  spec.version      = '1.0.0'
  spec.license      = 'Public Domain'
  spec.summary      = "A Library for parsing JSON into an object graph."
  spec.description  = <<-DESC
                   A Library for parsing JSON into an object graph.
                   DESC
  spec.homepage     = 'https://github.com/TomCorwine/TOMJSONAdapter-iOS'

  spec.author       = { "Tom Corwine" => "tc@corwine.org" }
  spec.source       = { :git => 'https://github.com/TomCorwine/TOMJSONAdapter-iOS.git' }

  spec.requires_arc = true
  spec.source_files  = "TOMJSONAdapter/**.{h,m}"

  spec.public_header_files = "TOMJSONAdapter/**.h"
end
