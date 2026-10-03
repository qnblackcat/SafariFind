// SafariFind — rebuilt from the 1.1.2 binary.
// Long-press the Share button in Safari's toolbar to open "Find on Page".
#import <UIKit/UIKit.h>

@interface _UIButtonBarButton : UIButton
- (void)setContextMenuEnabled:(BOOL)enabled;
@end

@interface _UIModernBarButton : UIView
@property (nonatomic, readonly) UIImage *currentImage;
@end

@interface BrowserRootViewController : UIViewController
- (id)primaryBar;     // iOS 15+
- (id)bottomToolbar;  // iOS < 15
- (id)delegate;       // BrowserController
@end

@interface BrowserController : NSObject
- (void)find:(id)sender;     // iOS 16+
- (void)findKeyPressed;      // iOS 15
@end

@interface BrowserRootViewController (SafariFind)
- (void)safariFind_addGestureRecognizer;
- (void)safariFind_gestureRecognizerDidFire;
@end

// iOS 15+ gives the Share button its own context menu on long-press,
// which would swallow our gesture — turn it off for that one button.
%group iOS15Only
%hook _UIButtonBarButton
- (void)setHighlighted:(BOOL)highlighted {
	%orig;
	for (UIView *subview in self.subviews) {
		if (![subview isKindOfClass:%c(_UIModernBarButton)]) continue;
		UIImage *image = ((_UIModernBarButton *)subview).currentImage;
		if (image && [image.description containsString:@"symbol(system: square.and.arrow.up)"]) {
			[self setContextMenuEnabled:NO];
			break;
		}
	}
}
%end
%end

%hook BrowserRootViewController
- (void)viewDidLoad {
	%orig;
	[self safariFind_addGestureRecognizer];
}

%new
- (void)safariFind_addGestureRecognizer {
	UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(safariFind_gestureRecognizerDidFire)];
	id bar = nil;
	if (@available(iOS 15, *))
		bar = [self primaryBar];
	else
		bar = [self bottomToolbar];
	UIView *shareView = [[[bar valueForKey:@"barRegistration"] valueForKey:@"_shareItem"] valueForKey:@"_view"];
	[shareView addGestureRecognizer:gesture];
}

%new
- (void)safariFind_gestureRecognizerDidFire {
	BrowserController *controller = [self delegate];
	if (@available(iOS 16, *))
		[controller find:nil];
	else
		[controller findKeyPressed];
}
%end

%ctor {
	if (@available(iOS 15, *))
		%init(iOS15Only);
	%init;
}
