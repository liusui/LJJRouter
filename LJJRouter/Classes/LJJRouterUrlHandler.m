//
//  LJJRouterUrlHandler.m
//  Pods
//
//  Created by liusui on 2016/9/29.
//
//

#import "LJJRouterUrlHandler.h"
#import "LJJRouter.h"

@interface LJJRouterUrlHandler ()

@property (strong, nonatomic) NSMutableDictionary *registeredUrLJJ;

@end

@implementation LJJRouterUrlHandler
+ (LJJRouterUrlHandler *)shared {
    static LJJRouterUrlHandler *_shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [LJJRouterUrlHandler new];
    });
    return _shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.registeredUrLJJ = [NSMutableDictionary new];
    }
    return self;
}

- (void)registerUrl:(NSString *)url forRouters:(NSArray *)routers {
    [self.registeredUrLJJ setObject:routers forKey:url];
}

- (void)handleUrl:(NSURL *)url {
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    NSString *host = components.host;
    NSMutableDictionary *arguments = [NSMutableDictionary new];
    for (NSURLQueryItem *item in components.queryItems) {
        arguments[item.name] = item.value;
    }
    NSArray *routers = self.registeredUrLJJ[host];
    if (routers) {
        [[LJJRouter shared] navigateWithArguments:arguments fullRouter:routers];
    }
}
@end
