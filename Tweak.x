//
// Copyright (c) 2025 Nightwind
//

#import "Tweak.h"

static BOOL safariUsesLoweredSearchBar(void) {
	return [[%c(SFFeatureManager) sharedFeatureManager] preferredCapsuleLayoutStyle] != 2;
}

%hook SFCapsuleCollectionView

- (void)_updateToolbarAlpha {
	if (!safariUsesLoweredSearchBar()) {
		%orig;
		return;
	}

	UIVisualEffectView *const _toolbarBackdropView = [self valueForKey:@"_toolbarBackdropView"];
	_toolbarBackdropView.alpha = [self _toolbarBackdropAlpha];

	@try {
		UIView *const _alternateToolbarContentView = [self valueForKey:@"_alternateToolbarContentView"];
		_alternateToolbarContentView.alpha = [self _toolbarBackdropAlpha];
	} @catch (NSException *const exception) {
		// We ignore if we can't access "_alternateToolbarContentView"
	}
}

- (void)setShowingAlternateToolbarContent:(BOOL)showingAlternateToolbarContent animated:(BOOL)animated {
	%orig;

	if (!safariUsesLoweredSearchBar()) return;

	[UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
		UIVisualEffectView *const _toolbarBackdropView = [self valueForKey:@"_toolbarBackdropView"];
		_toolbarBackdropView.alpha = showingAlternateToolbarContent ? 1 : 0;

		@try {
			UIView *const _alternateToolbarContentView = [self valueForKey:@"_alternateToolbarContentView"];
			_alternateToolbarContentView.alpha = showingAlternateToolbarContent ? 1 : 0;
		} @catch (NSException *const exception) {
			// We ignore if we can't access "_alternateToolbarContentView"
		}
	}];
}

- (CGFloat)capsuleBackgroundCornerRadius {
	return safariUsesLoweredSearchBar() ? 17 : %orig;
}

- (CGRect)capsuleFrame {
	CGRect frame = %orig;
	if (!safariUsesLoweredSearchBar()) {
		return frame;
	}

	frame.origin.y = UIScreen.mainScreen.bounds.size.height - frame.size.height - self.window.safeAreaInsets.bottom - 20;
	return frame;
}

- (CGFloat)_toolbarBackdropAlpha {
	if (!safariUsesLoweredSearchBar()) {
		return %orig;
	}

	return [self selectedItemIsMinimized] || [self itemsAreHidden] ? 1 : 0;
}

%end

%hook SFCapsuleNavigationBar

- (void)layoutSubviews {
	%orig;

	if (!safariUsesLoweredSearchBar()) return;

	for (UIButton *button in [self leadingButtons]) {
		button.tintColor = [UIColor systemBlueColor];
		button.transform = CGAffineTransformMakeScale(1.2, 1.2);
	}

	for (UIButton *button in [self trailingButtons]) {
		button.tintColor = [UIColor systemBlueColor];
		button.transform = CGAffineTransformMakeScale(1.2, 1.2);
	}
}

- (void)didMoveToWindow {
	%orig;

	if (!safariUsesLoweredSearchBar()) return;

	CapsuleNavigationBarRegistration *const registration = (CapsuleNavigationBarRegistration *)[self valueForKey:@"_registration"];

	UIButton *const button = [(NSMutableDictionary *)[registration valueForKey:@"_buttonsByBarItem"] objectForKey:@(SFBarItemIdentifierMoreOptionsButton)];
	UILongPressGestureRecognizer *const recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_fs_moreOptionsLongPressed:)];
	[recognizer set_prefersToBeExclusiveWithCompetingLongPressGestureRecognizers:YES];
	recognizer.minimumPressDuration = 0.2;
	recognizer.cancelsTouchesInView = YES;
	[button addGestureRecognizer:recognizer];
}

- (_SFUIViewPopoverSourceInfo *)formatMenuButtonPopoverSourceInfo {
	if (!safariUsesLoweredSearchBar()) {
		return %orig;
	}

	CapsuleNavigationBarRegistration *const registration = (CapsuleNavigationBarRegistration *)[self valueForKey:@"_registration"];
	UIButton *const moreOptionsButton = [(NSMutableDictionary *)[registration valueForKey:@"_buttonsByBarItem"] objectForKey:@(SFBarItemIdentifierMoreOptionsButton)];

	_SFUIViewPopoverSourceInfo *const popoverSourceInfo = [[%c(_SFUIViewPopoverSourceInfo) alloc] initWithView:moreOptionsButton];
	popoverSourceInfo.shouldHideArrow = YES;
	return popoverSourceInfo;
}

%new
- (void)_fs_moreOptionsLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		AudioServicesPlaySystemSound(1519);

		BrowserController *const browserController = (BrowserController *)[self delegate];
		if (![browserController isKindOfClass:%c(BrowserController)]) return;

		_SFPageFormatMenuController *const menuController = [[%c(_SFPageFormatMenuController) alloc] initWithBrowserContentController:browserController];
		[menuController presentMenuFromViewController:[browserController rootViewController] withSourceInfo:[self formatMenuButtonPopoverSourceInfo]];
	}
}

%end

%hook SFCapsuleView

- (CGRect)frameForShadowView {
	return safariUsesLoweredSearchBar() ? self.frame : %orig;
}

%end

%hook SFCapsuleCollectionViewItem

- (CGFloat)capsuleHeightForWidth:(CGFloat)width defaultHeight:(CGFloat)defaultHeight state:(NSInteger)state index:(NSInteger)index {
	return safariUsesLoweredSearchBar() && ![self.collectionView selectedItemIsMinimized] ? 54 : %orig;
}

%end

%hook CapsuleNavigationBarRegistration
%property (nonatomic, strong, setter=_fs_setOriginalLeadingBarItems:) NSArray *_fs_originalLeadingBarItems;
%property (nonatomic, strong, setter=_fs_setOriginalTrailingBarItems:) NSArray *_fs_originalTrailingBarItems;

- (instancetype)initWithBar:(id)bar barManager:(id)barManager {
	self = %orig;

	if (self) {
		self._fs_originalLeadingBarItems = [self valueForKey:@"_leadingBarItems"];
		self._fs_originalTrailingBarItems = [self valueForKey:@"_trailingBarItems"];
	}

	return self;
}

- (void)updateBarAnimated:(BOOL)animated {
	%orig;

	NSArray *leadingBarItems = nil;
	NSArray *trailingBarItems = nil;

	if (safariUsesLoweredSearchBar()) {
		leadingBarItems = @[@(SFBarItemIdentifierBackButton), @(SFBarItemIdentifierForwardButton)];
		trailingBarItems = @[@(SFBarItemIdentifierDownloadsButton), @(SFBarItemIdentifierTabOverviewButton), @(SFBarItemIdentifierMoreOptionsButton)];
	} else {
		leadingBarItems = self._fs_originalLeadingBarItems;
		trailingBarItems = self._fs_originalTrailingBarItems;
	}

	[self setValue:leadingBarItems forKey:@"_leadingBarItems"];
	[self setValue:trailingBarItems forKey:@"_trailingBarItems"];
}

%end

%hook CapsuleNavigationBarViewController

- (void)capsuleCollectionViewLayoutStyleDidChange:(id)style {
	%orig;

	SFCapsuleNavigationBar *const navigationBar = [self selectedItemNavigationBar];
	CapsuleNavigationBarRegistration *const registration = [navigationBar valueForKey:@"_registration"];

	[registration updateBarAnimated:YES];
}

%end

%hook BrowserToolbar

- (void)layoutSubviews {
	%orig;
	self.hidden = safariUsesLoweredSearchBar() ? YES : NO;
}

%end

%hook SFStartPageCollectionViewController

- (void)_updateNavigationItemAnimated:(BOOL)animated {
	%orig;

	if (!safariUsesLoweredSearchBar()) return;

	UIImage *const bookImage = [UIImage systemImageNamed:@"book"];
	UIBarButtonItem *const barButtonItem = [[UIBarButtonItem alloc] initWithImage:bookImage style:UIBarButtonItemStylePlain target:self action:@selector(_fs_presentBookmarksController)];
	self.navigationItem.leftBarButtonItem = barButtonItem;

	self.navigationController.navigationBar.userInteractionEnabled = YES;
}

%new
- (void)_fs_presentBookmarksController {
	SFStartPageViewController *const startPageViewController = [self dataSource];
	if (![startPageViewController isKindOfClass:%c(SFStartPageViewController)]) return;

	CatalogViewController *const catalogViewController = (CatalogViewController *)[startPageViewController parentViewController];
	if (![catalogViewController isKindOfClass:%c(CatalogViewController)]) return;

	BrowserController *const browserController = [catalogViewController browserController];
	[browserController setPresentingModalBookmarksController:YES withExclusiveCollection:nil bookmarkUUIDString:nil animated:YES];
}

%end