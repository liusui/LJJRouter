//
// Created by liusui on 16/9/19.
//
//
// 用于ViewController间跳转的解耦，通过ViewController的类名进行跳转，在本类的上下文中称之为'viewControllerName'。
// 比如LJJHomeViewController，跳转时可使用
// [[LJJRouter shared] navigateTo:@"LJJHomeViewController" arguments:@{@"content":@"Hello"}]; 或者
// [[LJJRouter shared] navigateTo:@"LJJHome" arguments:@{@"content":@"Hello"}];
// 去掉'viewControllerName'尾部的ViewController也是支持的。
//
// ViewController想要支持LJJRouter的跳转，需要实现LJJRouterViewControllerInstantiation协议中的方法instantiateViewController，提供ViewController的实例。

#import <UIKit/UIKit.h>

#import "LJJRouterViewControllerInstantiation.h"
#import "LJJRouterViewControllerDialog.h"
#import "UIButton+LJJRouter.h"

#include "LJJRouterHelperMacros.h"

typedef enum : NSUInteger {
    LJJRouterDialogPresentTypeWait,//等待上一个窗口关闭，默认
    LJJRouterDialogPresentTypeIgnore,//如果已有窗口弹出，忽略新的窗口
    LJJRouterDialogPresentTypeForce,//关闭之前的弹窗，弹出新的
} LJJRouterDialogPresentType;

@interface LJJRouter : NSObject

+ (LJJRouter *)shared;

/// 为LJJRouter设置初始ViewController，需要在App启动时第一个调用
+ (void)startupWithHomeViewController:(NSString *)viewControllerName;

/// 最底部的ViewController，目前为NavigationController
- (UIViewController *)rootViewController;

/// 通过ViewController标识实例化ViewController
- (UIViewController *)viewControllerInstanceWithName:(NSString *)name;
/// 通过ViewController标识实例化ViewController并传递参数
- (UIViewController *)viewControllerInstanceWithName:(NSString *)name arguments:(NSDictionary *)arguments;

/// 跳转到标识为viewControllerName的ViewController，并传递arguments中的参数
- (void)navigateTo:(NSString *)viewControllerName arguments:(NSDictionary *)arguments;

/// 跳转到标识为viewControllerName的ViewController，并传递arguments中的参数，animated指定是否具有动画
- (void)navigateTo:(NSString *)viewControllerName arguments:(NSDictionary *)arguments animated:(bool)animated;
/// 跳转到某个ViewController，allowRepeat表示如果topViewController和要跳转的一样时，是否忽略 （TODO：增加新的处理类型，比如替换）
- (void)navigateTo:(NSString *)viewControllerName arguments:(NSDictionary *)arguments allowRepeat:(BOOL)allowRepeat;
/// 跳转到某个ViewController，allowRepeat表示如果topViewController和要跳转的一样时，是否忽略 （TODO：增加新的处理类型，比如替换）,animated标识是否有动画
- (void)navigateTo:(NSString *)viewControllerName arguments:(NSDictionary *)arguments allowRepeat:(BOOL)allowRepeat animated:(bool)animated;

/// 回退一个ViewController
- (void)goBack;
/// 回退到rootViewController
- (void)goBackToRoot;
/// 会退到viewControllerName标识的ViewController
- (BOOL)goBackTo:(NSString *)viewControllerName;
/// 往后跳转到第一个出现的viewControllerName对应的UIViewController
- (BOOL)goBackToFirstOf:(NSString *)viewControllerName;
/// 往后跳转到最后一个出现的viewControllerName对应的UIViewController
- (BOOL)goBackToLastOf:(NSString *)viewControllerName;

/// 回退一个ViewController带参数版本
- (void)goBackWithArguments:(NSDictionary *)arguments;
/// 回退到rootViewController带参数版本
- (void)goBackToRootWithArguments:(NSDictionary *)arguments;
/// 会退到viewControllerName标识的ViewController带参数版本
- (BOOL)goBackTo:(NSString *)viewControllerName arguments:(NSDictionary *)arguments;
/// 往后跳转到第一个出现的viewControllerName对应的UIViewController带参数版本
- (BOOL)goBackToFirstOf:(NSString *)viewControllerName arguments:(NSDictionary *)arguments;
/// 往后跳转到最后一个出现的viewControllerName对应的UIViewController带参数版本
- (BOOL)goBackToLastOf:(NSString *)viewControllerName arguments:(NSDictionary *)arguments;

// 以Dialog的形式展现ViewController
- (void)presentAsDialog:(NSString *)viewControllerName arguments:(NSDictionary *)arguments completeBlock:(LJJRouterDialogCompleteBlock)completeBlock;
- (void)presentAsDialog:(NSString *)viewControllerName arguments:(NSDictionary *)arguments;
- (void)presentAsDialog:(NSString *)viewControllerName;
- (void)dismissDialog;

/// 使用全路由，要求当前页面必须是router中第一个页面，如果forceJumpToFirstPage为YES，则会强行跳回第一个页面后再继续往后跳转,为NO则放弃后续的跳转
- (void)navigateWithArguments:(NSDictionary *)arguments fullRouter:(NSArray *)router;
- (void)navigateWithArguments:(NSDictionary *)arguments fullRouter:(NSArray *)router forceJumpToFirstPage:(BOOL)force;

// 使用额外路由，直接从当前页面往后跳转router中的页面。
- (void)navigateWithArguments:(NSDictionary *)arguments additionRouter:(NSArray *)router;

#pragma mark - 获取特别位置的指定ViewController,专为恶心的需求而生
/// 绝对的最上层ViewController，如果有Present出来的NavigationController，则继续往上找（需配合使用presentAsDialog，目前处于不稳定状态,不需要着急替换）
- (UIViewController *)absoluteTopViewController;
/// 从底向上寻找第index个类为viewControllerClass的ViewController，index 从0开始。
- (UIViewController *)rIndexOf:(Class)viewControllerClass index:(int)index;
/// 从上向下寻找第index个类为viewControllerClass的ViewController，index 从0开始。
- (UIViewController *)lIndexOf:(Class)viewControllerClass index:(int)index;
@end
