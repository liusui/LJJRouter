//
//  UIButton+LJJRouter.m
//  Pods
//
//  Created by liusui on 2016/10/8.
//
//

#import "UIButton+LJJRouter.h"
#import "LJJRouter.h"

#import <objc/runtime.h>

const NSString * kHyperlinkKey;

@implementation UIButton (LJJRouter)

- (void)setHyperlink:(NSString *)hyperlink {
    objc_setAssociatedObject(self, &kHyperlinkKey, hyperlink, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)hyperlink {
    return objc_getAssociatedObject(self, &kHyperlinkKey);
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if (self.hyperlink && self.hyperlink.length > 0) {
        if ([self.hyperlink hasPrefix:@"/"]) {
            NSArray *router = [[self.hyperlink substringFromIndex:1] componentsSeparatedByString:@"/"];
            [[LJJRouter shared] navigateWithArguments:nil fullRouter:router];
        } else {
            NSArray *router = [self.hyperlink componentsSeparatedByString:@"/"];
            [[LJJRouter shared] navigateWithArguments:nil additionRouter:router];
        }
    }
    [super sendAction:action to:target forEvent:event];
}

@end
