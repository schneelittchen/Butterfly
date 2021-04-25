#import "Butterfly.h"

BOOL enabled;

%group Cursor

void generateRandomColor() {
    
    double r = arc4random_uniform(101);
    double g = arc4random_uniform(101);
    double b = arc4random_uniform(101);
    if (r == 100.0) r = 1.00;
    else r = r / 100;
    if (g == 100.0) g = 1.00;
    else g = g / 100;
    if (b == 100.0) b = 1.00;
    else b = b / 100;

    randomColor = [UIColor colorWithRed:r green:g blue:b alpha: 1.00];

}

%hook UITextSelectionView

- (id)caretViewColor {

    if (cursorColorSwitch) {
        if (!randomColorSwitch) {
            UIColor* customColor = [SparkColourPickerUtils colourWithString:[preferencesDictionary objectForKey:@"customCursorColor"] withFallback:@"#147efb"];
            return [customColor colorWithAlphaComponent:[cursorAlphaLevel doubleValue]];
        } else if (randomColorSwitch) {
            generateRandomColor();
            return [randomColor colorWithAlphaComponent:[cursorAlphaLevel doubleValue]];
        }
    }

    return %orig;

}

- (id)floatingCaretViewColor {

    if (cursorColorSwitch) {
        if (!randomColorSwitch) {
            UIColor* customColor = [SparkColourPickerUtils colourWithString:[preferencesDictionary objectForKey:@"customCursorColor"] withFallback:@"#147efb"];
            return [customColor colorWithAlphaComponent:[cursorAlphaLevel doubleValue]];
        } else if (randomColorSwitch) {
            generateRandomColor();
            return [randomColor colorWithAlphaComponent:[cursorAlphaLevel doubleValue]];
        }
    }

    return %orig;

}

- (void)updateSelectionRects {
    
    if (smoothCursorMovementSwitch) {
        [UIView animateWithDuration: 0.2 animations: ^{
            %orig;
        }];
    } else {
        %orig;
    }
    
}

- (id)dynamicCaret {
    
    if (smoothCursorMovementSwitch)
        return [self caretView];
    else
        return %orig;

}

%end

%end

%group HighlightColor

%hook UITextInputTraits

- (void)setSelectionBarColor:(id)arg1 {

    if (highlightColorSwitch) {
        if (!randomColorSwitch) {
            UIColor* customColor = [SparkColourPickerUtils colourWithString:[preferencesDictionary objectForKey:@"customHighlightColor"] withFallback:@"#147efb"];
            %orig([customColor colorWithAlphaComponent:[cursorAlphaLevel doubleValue]]);
        } else if (randomColorSwitch) {
            generateRandomColor();
            %orig([randomColor colorWithAlphaComponent:[cursorAlphaLevel doubleValue]]);
        }
    } else {
        %orig;
    }

}

- (UIColor *)selectionHighlightColor {

    if (highlightColorSwitch) {
        UIColor* customColor = [SparkColourPickerUtils colourWithString:[preferencesDictionary objectForKey:@"customHighlightColor"] withFallback:@"#147efb"];
        return [customColor colorWithAlphaComponent:[highlightColorAlphaLevel doubleValue]];
    }

    return %orig;

}

%end

%end

%group ScrollIndicator

%hook _UIScrollViewScrollIndicator

- (id)_colorForStyle:(long long)arg1 {

    if (scrollIndicatorColorSwitch) {
        if (!randomColorSwitch) {
            UIColor* customColor = [SparkColourPickerUtils colourWithString:[preferencesDictionary objectForKey:@"customScrollIndicatorColor"] withFallback:@"#147efb"];
            return [customColor colorWithAlphaComponent:[scrollIndicatorAlphaLevel doubleValue]];
        } else if (randomColorSwitch) {
            generateRandomColor();
            return [randomColor colorWithAlphaComponent:[scrollIndicatorAlphaLevel doubleValue]];
        }
    }

    return %orig;

}

%end

%end

%group StatusBarPill

%hook _UIStatusBarPillView

- (void)setPillColor:(UIColor *)arg1 {
    
    if (pillColorSwitch) {
        if (!randomColorSwitch) {
            UIColor* customColor = [SparkColourPickerUtils colourWithString:[preferencesDictionary objectForKey:@"customPillColor"] withFallback:@"#147efb"];
            %orig([customColor colorWithAlphaComponent:[pillAlphaLevel doubleValue]]);
        } else if (randomColorSwitch) {
            generateRandomColor();
            %orig([randomColor colorWithAlphaComponent:[pillAlphaLevel doubleValue]]);
        }
    } else {
        %orig;
    }

}

%end

%end

%ctor {

    if (![NSProcessInfo processInfo]) return;
    NSString* processName = [NSProcessInfo processInfo].processName;
    bool isSpringboard = [@"SpringBoard" isEqualToString:processName];

    bool shouldLoad = NO;
    NSArray* args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
    NSUInteger count = args.count;
    if (count != 0) {
        NSString* executablePath = args[0];
        if (executablePath) {
            NSString* processName = [executablePath lastPathComponent];
            BOOL isApplication = [executablePath rangeOfString:@"/Application/"].location != NSNotFound || [executablePath rangeOfString:@"/Applications/"].location != NSNotFound;
            BOOL isFileProvider = [[processName lowercaseString] rangeOfString:@"fileprovider"].location != NSNotFound;
            BOOL skip = [processName isEqualToString:@"AdSheet"]
                        || [processName isEqualToString:@"CoreAuthUI"]
                        || [processName isEqualToString:@"InCallService"]
                        || [processName isEqualToString:@"MessagesNotificationViewService"]
                        || [executablePath rangeOfString:@".appex/"].location != NSNotFound;
            if ((!isFileProvider && isApplication && !skip) || isSpringboard) {
                shouldLoad = YES;
            }
        }
    }

	if (!shouldLoad) return;

    preferences = [[HBPreferences alloc] initWithIdentifier:@"love.litten.butterflypreferences"];
    preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/love.litten.butterfly.colorspreferences.plist"];

    [preferences registerBool:&enabled default:nil forKey:@"Enabled"];

    // Cursor
    [preferences registerBool:&cursorColorSwitch default:NO forKey:@"cursorColor"];
    if (cursorColorSwitch) {
        [preferences registerObject:&customCursorString default:@"#147efb" forKey:@"customCursorColor"];
        [preferences registerObject:&cursorAlphaLevel default:@"1.0" forKey:@"cursorAlpha"];
        [preferences registerBool:&smoothCursorMovementSwitch default:NO forKey:@"smoothCursorMovement"];
    }

    // Highlight Color
    [preferences registerBool:&highlightColorSwitch default:NO forKey:@"highlightColor"];
    if (highlightColorSwitch) {
        [preferences registerObject:&customHighlightString default:@"#147efb" forKey:@"customHighlightColor"];
        [preferences registerObject:&highlightColorAlphaLevel default:@"0.1" forKey:@"highlightColorAlpha"];
    }

    // Scroll Indicator Color
    [preferences registerBool:&scrollIndicatorColorSwitch default:NO forKey:@"scrollIndicatorColor"];
    if (scrollIndicatorColorSwitch) {
        [preferences registerObject:&customScrollIndicatorColorString default:@"#147efb" forKey:@"customScrollIndicatorColor"];
        [preferences registerObject:&scrollIndicatorAlphaLevel default:@"0.4" forKey:@"scrollIndicatorAlpha"];
    }

    // StatusBar Pill
    [preferences registerBool:&pillColorSwitch default:NO forKey:@"pillColor"];
    if (pillColorSwitch) {
        [preferences registerObject:&customPillString default:@"#147efb" forKey:@"customPillColor"];
        [preferences registerObject:&pillAlphaLevel default:@"1.0" forKey:@"pillAlpha"];
    }

    // Miscellaneous
    [preferences registerBool:&randomColorSwitch default:NO forKey:@"randomColor"];

    if (enabled) {
        if (cursorColorSwitch) %init(Cursor);
        if (highlightColorSwitch) %init(HighlightColor);
        if (scrollIndicatorColorSwitch) %init(ScrollIndicator);
        if (pillColorSwitch) %init(StatusBarPill);
    }

}