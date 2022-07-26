Pod::Spec.new do |s|
    s.name         = "LetSee"
    s.version      = "0.3.5"
    s.summary      = "Neat and clean network Logger abstraction layer written in Swift"
    s.description  = <<-EOS
    LetSee logs network commands using Swift and Javascript and lets you see all these commands in a clean and neat way (local web page).
    Instructions for installation
    are in [the README](https://github.com/farshadjahanmanesh/Letsee).
    EOS
    s.homepage     = "https://github.com/farshadjahanmanesh/Letsee"
    s.license      = { :type => "MIT", :file => "LICENSE" }
    s.author             = { "Farshad Jahanmanesh" => "farshadjahanmanesh@gmail.com" }
    s.social_media_url   = "http://twitter.com/fjahanmanesh"
    
    s.source       = { :git => "https://github.com/farshadjahanmanesh/Letsee.git", :tag => s.version }
    s.swift_version = '5.3'
    s.cocoapods_version = '>= 1.11.0'
    s.exclude_files = 'Sources/LetSee/Core/Website/**/*'
    s.resource = [ 'Sources/LetSee/Core/Website']
    s.default_subspec = "Core"
    s.ios.deployment_target = '13.0'
#    s.osx.deployment_target = '10.15'
    s.platforms = {:ios=> '13.0'}
    s.dependency 'Swifter', '~> 1.5.0'
    s.subspec "Core" do |core|
      core.source_files = 'Sources/LetSee/Core/**/*.{swift}'
      core.pod_target_xcconfig = {"IPHONEOS_DEPLOYMENT_TARGET" => "13.0"}
    end

		s.subspec 'MoyaPlugin' do |moya|
		  moya.pod_target_xcconfig = {"IPHONEOS_DEPLOYMENT_TARGET" => "13.0"}
				moya.source_files = 'Sources/LetSee/MoyaPlugin/*.{swift}'
				moya.dependency 'LetSee/Core'
				moya.dependency 'LetSee/Interceptor'
				moya.dependency 'Moya', '~> 15.0'
		end

		s.subspec 'InAppView' do |inapp|
			inapp.pod_target_xcconfig = {"IPHONEOS_DEPLOYMENT_TARGET" => "13.0"}
			inapp.source_files = 'Sources/LetSee/InAppView/*.{swift}'
			inapp.dependency 'LetSee/Core'
			inapp.dependency 'LetSee/Interceptor'
			inapp.ios.framework = "SwiftUI"
			inapp.ios.framework = "UIKit"
			inapp.ios.framework = "Combine"
		end

		s.subspec 'Interceptor' do |interceptor|
			interceptor.pod_target_xcconfig = {"IPHONEOS_DEPLOYMENT_TARGET" => "13.0"}
			interceptor.source_files = 'Sources/LetSee/Interceptor/*.{swift}'
			interceptor.dependency 'LetSee/Core'
			interceptor.ios.framework = "Combine"
		end

    s.screenshots = ['https://github.com/farshadjahanmanesh/Letsee/raw/main/Examples%2BImages/good.gif?raw=true', 'https://github.com/farshadjahanmanesh/Letsee/raw/main/Examples%2BImages/package.manager.jpg?raw=true']
  end

