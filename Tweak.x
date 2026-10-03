// SafariFind — rebuilt from the 1.1.2 binary.
// Long-press the Share button in Safari's toolbar to open "Find on Page".
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#if DEBUG
#define SFLog(fmt, ...) NSLog(@"[SafariFind] " fmt, ##__VA_ARGS__)
#else
#define SFLog(...)
#endif

@interface _UIButtonBarButton : UIButton
- (void)setContextMenuEnabled:(BOOL)enabled;
@end

@interface _UIModernBarButton : UIView
@property (nonatomic, readonly) UIImage *currentImage;
@end

@interface BrowserRootViewController : UIViewController
- (id)delegate;       // BrowserController
@end

@interface BrowserController : NSObject
- (void)find:(id)sender;     // iOS 16+
- (void)findKeyPressed;      // iOS 15
@end

@interface BrowserRootViewController (SafariFind)
- (void)safariFind_gestureRecognizerDidFire;
@end

@interface _UIButtonBarButton (SafariFind)
- (void)safariFind_longPressed:(UILongPressGestureRecognizer *)gesture;
@end

static const void *kSafariFindGestureKey = &kSafariFindGestureKey;
// UIKit default is 0.5s; anything much shorter starts eating normal taps.
static const NSTimeInterval kSafariFindPressDuration = 0.3;

static BOOL SFIsShareButton(UIView *button) {
	for (UIView *subview in button.subviews) {
		if (![subview isKindOfClass:%c(_UIModernBarButton)]) continue;
		UIImage *image = ((_UIModernBarButton *)subview).currentImage;
		if (image && [image.description containsString:@"symbol(system: square.and.arrow.up)"])
			return YES;
	}
	return NO;
}

// The 1.1.2 binary attached the gesture in -[BrowserRootViewController viewDidLoad],
// but on iOS 17 the share item's view doesn't exist yet at that point. Attach it to
// the button itself once it's laid out instead.
%hook _UIButtonBarButton
- (void)layoutSubviews {
	%orig;
	if (objc_getAssociatedObject(self, kSafariFindGestureKey) || !SFIsShareButton(self)) return;

	UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(safariFind_longPressed:)];
	gesture.minimumPressDuration = kSafariFindPressDuration;
	[self addGestureRecognizer:gesture];
	objc_setAssociatedObject(self, kSafariFindGestureKey, gesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	SFLog(@"attached long-press to share button %@", self);
}

// iOS 15+ gives the Share button its own context menu on long-press,
// which would swallow our gesture — turn it off for that one button.
- (void)setHighlighted:(BOOL)highlighted {
	%orig;
	if (SFIsShareButton(self)) {
		SFLog(@"disabling context menu on share button %@", self);
		[self setContextMenuEnabled:NO];
	}
}

%new
- (void)safariFind_longPressed:(UILongPressGestureRecognizer *)gesture {
	if (gesture.state != UIGestureRecognizerStateBegan) return;
	// Bar buttons get reused, so make sure this one is still Share.
	if (!SFIsShareButton(self)) return;

	UIResponder *responder = self;
	while (responder && ![responder isKindOfClass:%c(BrowserRootViewController)])
		responder = responder.nextResponder;
	SFLog(@"long-press fired, root=%@", responder);
	[(BrowserRootViewController *)responder safariFind_gestureRecognizerDidFire];
}
%end

%hook BrowserRootViewController
%new
- (void)safariFind_gestureRecognizerDidFire {
	BrowserController *controller = [self delegate];
	SFLog(@"opening find, delegate=%@", controller);
	if (@available(iOS 16, *))
		[controller find:nil];
	else
		[controller findKeyPressed];
}
%end

%ctor {
	SFLog(@"loaded into %@ (iOS %@)", NSBundle.mainBundle.bundleIdentifier, UIDevice.currentDevice.systemVersion);
	%init;
}
