# LJJRouter

[![CI Status](http://img.shields.io/travis/liusui/LJJRouter.svg?style=flat)](https://travis-ci.org/liusui/LJJRouter)
[![Version](https://img.shields.io/cocoapods/v/LJJRouter.svg?style=flat)](http://cocoapods.org/pods/LJJRouter)
[![License](https://img.shields.io/cocoapods/l/LJJRouter.svg?style=flat)](http://cocoapods.org/pods/LJJRouter)
[![Platform](https://img.shields.io/cocoapods/p/LJJRouter.svg?style=flat)](http://cocoapods.org/pods/LJJRouter)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Useage
ViewController想要支持LJJRouter的跳转，需要实现LJJRouterViewControllerInstantiation协议中的方法instantiateViewController，提供ViewController的实例。普通viewController初始化在.m文件里添加```ruby LJJRouterInitPage()```，storyboard启动的viewController初始化是添加```ruby LJJRouterInitPageFromStoryboard(StoryboardName,StoryboardID)```
为LJJRouter设置初始ViewController，需要在App启动时第一个调用

## Installation

LJJRouter is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LJJRouter'
```

## Author

liusui, 952923202@qq.com

## License

LJJRouter is available under the MIT license. See the LICENSE file for more info.
