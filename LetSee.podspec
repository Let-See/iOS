Pod::Spec.new do |s|
    s.name         = "LetSee"
    s.version      = "0.1.8"
    s.summary      = "Neat and clean network Logger abstraction layer written in Swift"
    s.description  = <<-EOS
    LetSee logs network commands using Swift and Javascript and lets you see all of these command in a clean website.
    Instructions for installation
    are in [the README](https://github.com/farshadjahanmanesh/Letsee).
    EOS
    s.homepage     = "https://github.com/farshadjahanmanesh/Letsee"
    s.license      = { :type => "MIT", :file => "LICENSE" }
    s.author             = { "Farshad Jahanmanesh" => "farshadjahanmanesh@gmail.com" }
    s.social_media_url   = "http://twitter.com/fjahanmanesh"
    s.ios.deployment_target = '10.0'
    s.source       = { :git => "https://github.com/farshadjahanmanesh/Letsee.git", :tag => s.version }
    s.swift_version = '5.3'
    s.cocoapods_version = '>= 1.11.0'
    s.source_files = 'Sources/LetSee/**/*.swift'
    s.resource_bundles = { 'LetSee' => ['Sources/LetSee/Website/**/*.{js,html,css,json}'] }
    s.exclude_files = 'Sources/LetSee/Website/**/*'
    s.dependency 'Swifter', '~> 1.5.0'
    s.resource = [ 'Sources/LetSee/Website']
  end
