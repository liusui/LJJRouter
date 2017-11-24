//
// Created by liusui on 16/9/19.
//

#import "LJJRouter.h"
#import "LJJRouterViewControllerInstantiation.h"
#import "LJJNotExistViewController.h"

#import <objc/runtime.h>
#import <MZFormSheetPresentationController/MZFormSheetPresentationViewController.h>

@interface LJJRouter ()

@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) MZFormSheetPresentationViewController *formSheetController;
@property (strong, nonatomic) dispatch_queue_t dialogPresentQueue;
@property (strong, nonatomic) dispatch_semaphore_t dialogPresentSemaphore;
@property (strong, nonatomic) dispatch_queue_t dialogPresentWaitShowCompleteQueue;
@property (strong, nonatomic) dispatch_semaphore_t dialogPresentShowCompleteSemaphore;

@end

@implementation LJJRouter

+ (LJJRouter *)shared {
    static LJJRouter *_shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [LJJRouter new];
    });
    return _shared;
}

+ (void)startupWithHomeViewController:(NSString *)viewControllerName {
    UIWindow *window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [UIApplication sharedApplication].delegate.window = window;
    [[LJJRouter shared] setHomeViewController:viewControllerName];
    window.rootViewController = [LJJRouter shared].rootViewController;
    [window makeKeyAndVisible];
}

- (UIViewController *)rootViewController {
    return self.navigationController;
}

#pragma mark - Navigate To
#define BeginDismissDialog [self dismissDialogWithCompleteBlock:^(id result) {
#define EndDismissDialog } result:nil];

- (void)navigateWithArguments:(NSDictionary *)arguments fullRouter:(NSArray *)router {
    [self navigateWithArguments:arguments fullRouter:router forceJumpToFirstPage:YES];
}

- (void)navigateWithArguments:(NSDictionary *)arguments fullRouter:(NSArray *)router forceJumpToFirstPage:(BOOL)force {
    router = [self cleanRouter:router];
    BeginDismissDialog
    NSString *firstRouter = router[0];
    NSArray *newRouters = router;
    if ([self viewControllerName:firstRouter matchClassName:NSStringFromClass(self.navigationController.topViewController.class)]) {
       newRouters = [router subarrayWithRange:NSMakeRange(1, router.count - 1)];
    } else {
        if (force == YES && [self goBackToFirstOf:firstRouter]) {
            newRouters = [router subarrayWithRange:NSMakeRange(1, router.count - 1)];
        } else {
            //只有force为YES并且成功返回到第一个router，才会继续走下去，否则不执行跳转
            return;
        }
    }
    NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
    NSMutableArray *dialogs = [NSMutableArray new];
    for (NSString *item in newRouters) {
        if ([item hasPrefix:@"#"]) {
            NSString *dialogName = [item substringFromIndex:1];
            [dialogs addObject:dialogName];
        } else {
            UIViewController *viewController = [self viewControllerInstanceWithName:item arguments:arguments];
            if (viewController) {
                [viewControllers addObject:viewController];
            }
        }
    }
    [self.navigationController setViewControllers:viewControllers animated:YES];
    for (NSString *dialog in dialogs) {
        [self presentAsDialog:dialog arguments:arguments];
    }
    EndDismissDialog
}

- (void)navigateWithArguments:(NSDictionary *)arguments additionRouter:(NSArray *)router {
    [self navigateWithArguments:arguments additionRouter:router forceJumpToFirstPage:YES];
}

- (void)navigateWithArguments:(NSDictionary *)arguments additionRouter:(NSArray *)routers forceJumpToFirstPage:(BOOL)force {
    NSArray *fullRouters = @[NSStringFromClass(self.navigationController.topViewController.class)];
    fullRouters = [fullRouters arrayByAddingObjectsFromArray:routers];
    [self navigateWithArguments:arguments fullRouter:fullRouters forceJumpToFirstPage:force];
}

- (void)navigateTo:(NSString *)viewControllerName arguments:(NSDictionary *)arguments {
    [self navigateTo:viewControllerName arguments:arguments allowRepeat:NO];
}

- (void)navigateTo:(NSString *)viewControllerName arguments:(NSDictionary *)arguments animated:(bool)animated{
    [self navigateTo:viewControllerName arguments:arguments allowRepeat:NO animated:animated];
}

- (void)navigateTo:(NSString *)viewControllerName arguments:(NSDictionary *)arguments allowRepeat:(BOOL)allowRepeat {
    [self navigateTo:viewControllerName arguments:arguments allowRepeat:allowRepeat animated:YES];
}

- (void)navigateTo:(NSString *)viewControllerName arguments:(NSDictionary *)arguments allowRepeat:(BOOL)allowRepeat animated:(bool)animated {
    BeginDismissDialog
    if (allowRepeat == NO) {
        //如果不允许最高层的ViewController发生重复，当这种情况发生时就什么也不做。
        NSString *topViewControllerClassName = NSStringFromClass(self.navigationController.topViewController.class);
        if ([self viewControllerName:viewControllerName matchClassName:topViewControllerClassName]) {
            return;
        }
    }
    UIViewController *viewController = [self viewControllerInstanceWithName:viewControllerName arguments:arguments];
    if (viewController != nil && self.navigationController != nil) {
        [self.navigationController pushViewController:viewController animated:animated];
    }
    EndDismissDialog
}

#pragma mark - Present Dialog

- (void)presentAsDialog:(NSString *)viewControllerName arguments:(NSDictionary *)arguments completeBlock:(LJJRouterDialogCompleteBlock)completeBlock {
    [self presentAsDialog:viewControllerName arguments:arguments completeBlock:completeBlock presentType:LJJRouterDialogPresentTypeWait];
}

- (void)presentAsDialog:(NSString *)viewControllerName arguments:(NSDictionary *)arguments {
    [self presentAsDialog:viewControllerName arguments:arguments completeBlock:nil presentType:LJJRouterDialogPresentTypeWait];
}

- (void)presentAsDialog:(NSString *)viewControllerName {
    [self presentAsDialog:viewControllerName arguments:nil completeBlock:nil presentType:LJJRouterDialogPresentTypeWait];
}

- (void)presentAsDialog:(NSString *)viewControllerName arguments:(NSDictionary *)arguments completeBlock:(LJJRouterDialogCompleteBlock)completeBlock presentType:(LJJRouterDialogPresentType)presentType {
    UIViewController *viewController = [self viewControllerInstanceWithName:viewControllerName arguments:arguments];
    if ([viewController.class conformsToProtocol:@protocol(LJJRouterViewControllerDialog)]) {
        id<LJJRouterViewControllerDialog> dialog = viewController;
        if (presentType == LJJRouterDialogPresentTypeIgnore && self.formSheetController != nil) {
            return;
        }
        if (presentType == LJJRouterDialogPresentTypeForce && self.formSheetController != nil) {
            [self dismissDialog];
        }
        dispatch_async(self.dialogPresentQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentDialog:dialog completeBlock:completeBlock];
            });
            dispatch_semaphore_wait(self.dialogPresentSemaphore,DISPATCH_TIME_FOREVER);
        });
    }
}

- (void)presentDialog:(id<LJJRouterViewControllerDialog>)dialog completeBlock:(LJJRouterDialogCompleteBlock)completeBlock {
    CGSize size = [dialog dialogSize];
    self.formSheetController = [[MZFormSheetPresentationViewController alloc]initWithContentViewController:dialog];
    __weak typeof(self) self_weak = self;
    [dialog setCompletedBlock:^ (id result) {
        [self_weak dismissDialogWithCompleteBlock:completeBlock result:result];
    }];
    [self.navigationController presentViewController:self.formSheetController animated:YES completion:^{
        dispatch_semaphore_signal(self_weak.dialogPresentShowCompleteSemaphore);
    }];
}

- (void)dismissDialogWithCompleteBlock:(LJJRouterDialogCompleteBlock)completeBlock result:(id)result{
    __weak typeof(self) self_weak = self;
    if (self.formSheetController != nil) {
        dispatch_async(self.dialogPresentWaitShowCompleteQueue, ^{
            //必须等到Dialog Present动画做完才能调用dismiss
            dispatch_semaphore_wait(self.dialogPresentShowCompleteSemaphore, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC));
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [self.formSheetController dismissViewControllerAnimated:YES completion:^{
                    self_weak.formSheetController = nil;
                    dispatch_semaphore_signal(self_weak.dialogPresentSemaphore);
                    if (completeBlock) {
                        completeBlock(result);
                    }
                }];
            });
        });
    } else {
        if (completeBlock) {
            completeBlock(nil);
        }
    }
}

- (void)dismissDialog {
    [self dismissDialogWithCompleteBlock:nil result:nil];
}

- (dispatch_queue_t)dialogPresentQueue {
    if (_dialogPresentQueue == nil) {
        _dialogPresentQueue = dispatch_queue_create("com.epmyg.dialogpresent", DISPATCH_QUEUE_SERIAL);
    }
    return _dialogPresentQueue;
}

- (dispatch_semaphore_t)dialogPresentSemaphore {
    if (_dialogPresentSemaphore == nil) {
        _dialogPresentSemaphore = dispatch_semaphore_create(0);
    }
    return _dialogPresentSemaphore;
}

- (dispatch_queue_t)dialogPresentWaitShowCompleteQueue {
    if (_dialogPresentWaitShowCompleteQueue == nil) {
        _dialogPresentWaitShowCompleteQueue = dispatch_queue_create("com.epmyg.dialogpresent", DISPATCH_QUEUE_SERIAL);
    }
    return _dialogPresentWaitShowCompleteQueue;
}

- (dispatch_semaphore_t)dialogPresentShowCompleteSemaphore {
    if (_dialogPresentShowCompleteSemaphore == nil) {
        _dialogPresentShowCompleteSemaphore = dispatch_semaphore_create(0);
    }
    return _dialogPresentShowCompleteSemaphore;
}

#pragma mark - Go Back

- (void)goBack {
    [self goBackWithArguments:nil];
}

- (void)goBackToRoot {
    [self goBackToRootWithArguments:nil];
}

- (BOOL)goBackTo:(NSString *)viewControllerName {
    return [self goBackToFirstOf:viewControllerName];
}

- (BOOL)goBackToFirstOf:(NSString *)viewControllerName {
    return [self goBackToFirstOf:viewControllerName arguments:nil];
}

- (BOOL)goBackToLastOf:(NSString *)viewControllerName {
    return [self goBackToLastOf:viewControllerName arguments:nil];
}

// go back With Arguments
- (void)goBackWithArguments:(NSDictionary *)arguments {
    //如果有Dialog，先Dismiss掉再pop
    [self dismissDialog];
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
        if (arguments) {
            [self setupArguments:arguments forViewController:[self.navigationController topViewController]];
        }
    }
}


- (void)goBackToRootWithArguments:(NSDictionary *)arguments{
    //如果有Dialog，先Dismiss掉再pop
    [self dismissDialog];
    if (self.navigationController) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        if (arguments) {
            [self setupArguments:arguments forViewController:[self.navigationController topViewController]];
        }
    }
}

- (BOOL)goBackTo:(NSString *)viewControllerName arguments:(NSDictionary *)arguments {
    return [self goBackToFirstOf:viewControllerName arguments:arguments];
}


- (BOOL)goBackToFirstOf:(NSString *)viewControllerName arguments:(NSDictionary *)arguments {
    //如果有Dialog，先Dismiss掉再pop
    [self dismissDialog];
    UIViewController *viewController = [self viewControllerInstanceInNavigationStackWithName:viewControllerName reverseFindDirection:YES];
    if (viewController) {
        [self.navigationController popToViewController:viewController animated:YES];
        if (arguments) {
            [self setupArguments:arguments forViewController:viewController];
        }
        return YES;
    }
    return NO;
}


- (BOOL)goBackToLastOf:(NSString *)viewControllerName arguments:(NSDictionary *)arguments {
    //如果有Dialog，先Dismiss掉再pop
    [self dismissDialog];
    UIViewController *viewController = [self viewControllerInstanceInNavigationStackWithName:viewControllerName reverseFindDirection:NO];
    if (viewController) {
        [self.navigationController popToViewController:viewController animated:YES];
        if (arguments) {
            [self setupArguments:arguments forViewController:viewController];
        }
        return YES;
    }
    return NO;
}

#pragma mark - 获取特别位置的指定ViewController,专为恶心的需求而生
- (UIViewController *)absoluteTopViewController {
    if (self.formSheetController == nil) {
        return self.navigationController.topViewController;
    } else {
        if ([self.formSheetController.contentViewController isKindOfClass:[UINavigationController class]]) {
            return [(UINavigationController *)self.formSheetController.contentViewController topViewController];
        } else {
            return self.formSheetController.contentViewController;
        }
    }
    return nil;
}

- (UIViewController *)rIndexOf:(Class)viewControllerClass index:(int)index {
    UIViewController *viewController = [self viewControllerInstanceInNavigationStackWithName:NSStringFromClass(viewControllerClass) reverseFindDirection:NO skip:index];
    return viewController;
}

- (UIViewController *)lIndexOf:(Class)viewControllerClass index:(int)index {
    UIViewController *viewController = [self viewControllerInstanceInNavigationStackWithName:NSStringFromClass(viewControllerClass) reverseFindDirection:YES skip:index];
    return viewController;
}


#pragma mark - Private Method

- (void)setHomeViewController:(NSString *)viewControllerName {
    UIViewController *viewController = [self viewControllerInstanceWithName:viewControllerName];
    //Home View Controller必然不为空
    assert(viewController != nil);
    self.navigationController = [[UINavigationController alloc]initWithRootViewController:viewController];
}

- (UIViewController *)viewControllerInstanceWithName:(NSString *)name arguments:(NSDictionary *)arguments {
    NSArray *nameSegs = [name componentsSeparatedByString:@":"];
    name = nameSegs[0];
    UIViewController *viewController = [self viewControllerInstanceWithName:name];
    if (viewController != nil) {
        [self setupArguments:arguments forViewController:viewController];
    }
    if (nameSegs.count > 1 && [viewController isKindOfClass:[UITabBarController class]]) {
        [self switchTabBarViewController:(UITabBarController *)viewController selectedTo:nameSegs[1]];
    }
    return viewController;
}

- (instancetype)viewControllerInstanceInNavigationStackWithName:(NSString *)name reverseFindDirection:(BOOL)reverseFindDirection {
    return [self viewControllerInstanceInNavigationStackWithName:name reverseFindDirection:reverseFindDirection skip:0];
}

- (instancetype)viewControllerInstanceInNavigationStackWithName:(NSString *)name reverseFindDirection:(BOOL)reverseFindDirection skip:(int)skip {
    int skipCount = skip;
    NSArray *nameSegs = [name componentsSeparatedByString:@":"];
    name = nameSegs[0];
    if (self.navigationController) {
        NSEnumerator *enumerator = self.navigationController.viewControllers.objectEnumerator;
        if (reverseFindDirection) {
            enumerator = self.navigationController.viewControllers.reverseObjectEnumerator;
        }
        UIViewController *viewController = enumerator.nextObject;
        while (viewController != nil) {
            NSString *classString = NSStringFromClass(viewController.class);
            if ([self viewControllerName:name matchClassName:classString]) {
                if (skipCount <= 0) {
                    break;
                }
                skipCount--;
            }
            viewController = enumerator.nextObject;
        }
        if (viewController != nil) {
            if (nameSegs.count > 1 && [viewController isKindOfClass:[UITabBarController class]]) {
                [self switchTabBarViewController:(UITabBarController *)viewController selectedTo:nameSegs[1]];
            }
            return viewController;
        }
    }
    return nil;
}

- (void)switchTabBarViewController:(UITabBarController *)tabBarViewController selectedTo:(NSString *)viewControllerName {
    for (UIViewController *subViewController in tabBarViewController.childViewControllers) {
        if ([self viewControllerName:viewControllerName matchClassName:NSStringFromClass(subViewController.class)]) {
            [tabBarViewController setSelectedViewController:subViewController];
        }
    }
}

- (UIViewController *)viewControllerInstanceWithName:(NSString *)name {
    Class cLJJ = NSClassFromString(name);
    if (cLJJ == nil) {
        //兼容不带ViewController后缀的写法
        cLJJ = NSClassFromString([NSString stringWithFormat:@"%@ViewController",name]);
    }
    if (cLJJ && [cLJJ conformsToProtocol:@protocol(LJJRouterViewControllerInstantiation)]) {
        UIViewController<LJJRouterViewControllerInstantiation> *viewController = [cLJJ instantiateViewController];
        return viewController;
    }
    return [LJJNotExistViewController new];
}

- (void)setupArguments:(NSDictionary *)arguments forViewController:(UIViewController *)viewController {
    if (arguments && [arguments count] > 0) {
        //bind property values
        unsigned int propertyCount = 0;
        objc_property_t *properties = class_copyPropertyList([viewController class], &propertyCount);
        for(int i=0;i<propertyCount;i++)
        {
            objc_property_t property = *(properties + i);
            const char *propertyName = property_getName(property);
            NSString *propertyNameNS = [NSString stringWithUTF8String:propertyName];
            if(arguments[propertyNameNS]) {
                [viewController setValue:arguments[propertyNameNS] forKeyPath:propertyNameNS];
            }
        }
    }
}

- (BOOL)viewControllerName:(NSString *)viewControllerName matchClassName:(NSString *)className {
    if ([viewControllerName isEqualToString:className]
        || [[NSString stringWithFormat:@"%@ViewController",viewControllerName] isEqualToString:className]) {
        return YES;
    }
    return NO;
}

// 清除掉router中的空字符串
- (NSArray *)cleanRouter:(NSArray *)router {
    return [router filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject isEqualToString:@""] == NO;
    }]];
}

@end
