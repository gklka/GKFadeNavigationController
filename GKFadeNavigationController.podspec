Pod::Spec.new do |s|
  s.name             = "GKFadeNavigationController"
  s.version          = "0.5.1"
  s.summary          = "A Navigation Controller which supports animated hiding of the Navigation Bar"
  s.description      = <<-DESC
                       This is an example implementation of a `UINavigationController` with support of animated hiding and showing it's Navigation Bar.

                       ## Features

                       * Animates tint color
                       * Takes care of the status bar color
                       * Similar pattern to `-preferredStatusbarStyle`
                       * Uses native controls where possible (e.g. back button)
                       * Native looking translucent header
                       * Demo project with elastic header image
                       DESC
  s.homepage         = "https://github.com/gklka/GKFadeNavigationController"
  s.screenshots      = "https://github.com/gklka/GKFadeNavigationController/blob/master/example.gif?raw=true"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Gruber Kristóf" => "gk@lka.hu" }
  s.source           = { :git => "https://github.com/gklka/GKFadeNavigationController.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/gklka'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'GKFadeNavigationController' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
end
