#import "BTYRootListController.h"

@implementation BTYAppearanceSettings

- (UIColor *)tintColor {

    return [UIColor colorWithRed:0.66 green:0.70 blue:1.00 alpha:1.0];

}

- (UIColor *)statusBarTintColor {

    return [UIColor whiteColor];

}

- (UIColor *)navigationBarTitleColor {

    return [UIColor whiteColor];

}

- (UIColor *)navigationBarTintColor {

    return [UIColor whiteColor];

}

- (UIColor *)tableViewCellSeparatorColor {

    return [UIColor colorWithWhite:0 alpha:0];

}

- (UIColor *)navigationBarBackgroundColor {

    return [UIColor colorWithRed:0.66 green:0.70 blue:1.00 alpha:1.0];

}

- (BOOL)translucentNavigationBar {

    return YES;

}

@end