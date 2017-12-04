# LJJRouter

[![CI Status](http://img.shields.io/travis/liusui/LJJRouter.svg?style=flat)](https://travis-ci.org/liusui/LJJRouter)
[![Version](https://img.shields.io/cocoapods/v/LJJRouter.svg?style=flat)](http://cocoapods.org/pods/LJJRouter)
[![License](https://img.shields.io/cocoapods/l/LJJRouter.svg?style=flat)](http://cocoapods.org/pods/LJJRouter)
[![Platform](https://img.shields.io/cocoapods/p/LJJRouter.svg?style=flat)](http://cocoapods.org/pods/LJJRouter)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Useage
在App启动时需要第一个调用，实现下面的方法，为```LJJRouter```设置初始```ViewController```
```ruby
+ (void)startupWithHomeViewController:(NSString *)viewControllerName
```
```ViewController```想要支持LJJRouter的跳转，需要实现```LJJRouterViewControllerInstantiation```协议中的方法```instantiateViewController```，提供```ViewController```的实例。普通```viewController```初始化在.m文件里添加```LJJRouterInitPage()```，```storyboard```启动的```viewController```初始化是添加```LJJRouterInitPageFromStoryboard(StoryboardName,StoryboardID)```，初始化完成就可以进行跳转 比如LJJHomeViewController，跳转时可使用

```ruby
[[LJJRouter shared] navigateTo:@"LJJHomeViewController" arguments:@{@"content":@"Hello"}]; 或者
[[LJJRouter shared] navigateTo:@"LJJHome" arguments:@{@"content":@"Hello"}];
```

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
