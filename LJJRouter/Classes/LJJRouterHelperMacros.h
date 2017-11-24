//
//  LJJRouterHelperMacros.h
//  Pods
//
//  Created by liusui on 2016/9/28.
//
//

#ifndef LJJRouterHelperMacros_h
#define LJJRouterHelperMacros_h

#define LJJRouterInitPageFromStoryboard(StoryboardName,StoryboardID) \
+ (instancetype)instantiateViewController {\
    return [[UIStoryboard storyboardWithName:StoryboardName bundle:[NSBundle bundleForClass:self]] instantiateViewControllerWithIdentifier:StoryboardID];\
}

#define LJJRouterInitPage() \
+ (instancetype)instantiateViewController {\
    return [self new];\
}

#define LJJRouterInitDialog(WidthPadding,Height) \
@synthesize completedBlock;\
- (CGSize)dialogSize {\
    return CGSizeMake([UIScreen mainScreen].bounds.size.width - WidthPadding * 2, Height);\
}

#endif /* LJJRouterHelperMacros_h */
