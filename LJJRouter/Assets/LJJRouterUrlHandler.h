//
//  LJJRouterUrlHandler.h
//  Pods
//
//  Created by liusui on 2016/9/29.
//
//

#import <Foundation/Foundation.h>

@interface LJJRouterUrlHandler : NSObject
+ (LJJRouterUrlHandler *)shared;

- (void)registerUrl:(NSString *)url forRouters:(NSArray *)routers;
- (void)handleUrl:(NSURL *)url;
@end
