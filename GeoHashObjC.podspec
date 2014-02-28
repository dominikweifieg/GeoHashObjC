Pod::Spec.new do |s|
  s.name         = "GeoHashObjC"
  s.version      = "0.0.1"
  s.summary      = "GeoHash implementation in Objective-C for iOS"
  s.homepage     = "https://github.com/dominikweifieg/GeoHashObjC"
  s.license = { :type => 'MIT', :text => <<-LICENSE
Created by Dominik Wei-Fieg on 09.07.13.
Copyright (c) 2013 Ars Subtilior. All rights reserved.

Code is available for free distribution under the MIT License
Based on geohash.js : Geohash library for Javascript (c) 2008 David Troy
                   LICENSE
                 }
  s.author       = { "Dominik Wei-Fieg" => "dominik@ars-subtilior.com" }
  s.source       = { :git => "https://github.com/dominikweifieg/GeoHashObjC.git", :commit => "97c54daa81c29d3047ba5de31a02425cdb816d34" }
  s.source_files  = 'GeoHashObjC', 'GeoHashObjC/*.{h,m}'
  s.exclude_files = 'Classes/Exclude'
  s.public_header_files = 'GeoHashObjC/*.h'
  s.framework  = 'CoreLocation'
  s.requires_arc = true
end
