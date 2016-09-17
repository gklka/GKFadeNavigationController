# GKFadeNavigationController

[![CI Status](http://img.shields.io/travis/Gruber Kristóf/GKFadeNavigationController.svg?style=flat)](https://travis-ci.org/Gruber Kristóf/GKFadeNavigationController)
[![Version](https://img.shields.io/cocoapods/v/GKFadeNavigationController.svg?style=flat)](http://cocoapods.org/pods/GKFadeNavigationController)
[![License](https://img.shields.io/cocoapods/l/GKFadeNavigationController.svg?style=flat)](http://cocoapods.org/pods/GKFadeNavigationController)
[![Platform](https://img.shields.io/cocoapods/p/GKFadeNavigationController.svg?style=flat)](http://cocoapods.org/pods/GKFadeNavigationController)

This is an example implementation of a `UINavigationController` with support of animated hiding and showing it's Navigation Bar.

[![Demo](example.gif?raw=true)](example.mov?raw=true)

## Try it yourself

[Online simulator on appetize.io](https://appetize.io/embed/a87tdk5m1quj4wmqec3h0dh3er?device=iphone5s&scale=100&autoplay=true&orientation=portrait&deviceColor=white&screenOnly=true)

## Features

- Animates tint color
- Takes care of the status bar color
- Similar pattern to `-preferredStatusbarStyle`
- Uses native controls where possible (e.g. back button)
- Native looking translucent header
- Demo project with elastic header image

## Installation

GKFadeNavigationController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your `Podfile`:

```ruby
pod "GKFadeNavigationController"
```

Then update your pods with `pod install`.

## Usage

1. To run the example project, clone the repo, and run `pod install` from the Example directory first.
1. Set your Navigation Controller class to `GKFadeNavigationController` in Storyboard
1. Make your view controllers to conform `GKFadeNavigationControllerDelegate` protocol
1. Implement `-preferredNavigationBarVisibility` (return `GKFadeNavigationControllerNavigationBarVisibilityHidden` or `GKFadeNavigationControllerNavigationBarVisibilityVisible`)
1. Send a `-setNeedsNavigationBarVisibilityUpdateAnimated:animated` message to the navigation controller when you want to hide or show the navigation bar

You can see the attached demo project for easier reference.

## Requirements

- iOS 8 SDK

Works fine with iOS 10.

## Known limitations

- Does not handle screen rotation fully
- Supports only light navigation bar style out of the box
- Items under the header are not clickable
- Changing the status bar color happens in `-viewDidAppear` currently

Feel free to contribute or send me pull requests.

## Changelog

[GitHub Changelog and releases](https://github.com/gklka/GKFadeNavigationController/releases)

## Author

Gruber Kristóf, gk@lka.hu, [@gklka](https://twitter.com/gklka)

## License

GKFadeNavigationController is available under the MIT license. See the LICENSE file for more info.
