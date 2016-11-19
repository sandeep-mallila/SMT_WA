//
//  UIAppearance+Swift.h
//  WayAlerts
//
//  Created by Sandeep Mallila on 13/09/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//
#import <UIKit/UIKit.h>

// UIAppearance+Swift.h
@interface UIView (UIViewAppearance_Swift)
// appearanceWhenContainedIn: is not available in Swift. This fixes that.
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
@end

@interface UIBarButtonItem (UIViewAppearance_Swift)
// appearanceWhenContainedIn: is not available in Swift. This fixes that.
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
@end
