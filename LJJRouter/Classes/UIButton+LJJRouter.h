//
//  UIButton+LJJRouter.h
//  Pods
//
//  Created by liusui on 2016/10/8.
//
//

#import <UIKit/UIKit.h>

@interface UIButton (LJJRouter)

// LJJRouter格式的hyperlink，比如 /LJJHome/LJJContent 或者  LJJContent/#LJJDialog
// '/'开头的是全路由，反之是附加路由，详情看WIKI http://gitlab.baidao.com/LJJios/LJJRouter/wikis/home
@property (copy, nonatomic) IBInspectable NSString *hyperlink;

@end
