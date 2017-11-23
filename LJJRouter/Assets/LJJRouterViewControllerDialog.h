//
//  LJJRouterViewControllerDialog.h
//  Pods
//
//  Created by liusui on 2016/9/28.
//
//

#import <UIKit/UIkit.h>

typedef void(^LJJRouterDialogCompleteBlock)(id result);

@protocol LJJRouterViewControllerDialog <NSObject>

@required
@property (copy, nonatomic) LJJRouterDialogCompleteBlock completedBlock;
- (CGSize)dialogSize;

@end
