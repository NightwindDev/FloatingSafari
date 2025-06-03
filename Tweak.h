//
// Copyright (c) 2025 Nightwind
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>

@interface UIView (Undocumented)
- (UIViewController *)_viewControllerForAncestor;
@end

@interface UILongPressGestureRecognizer (Undocumented)
- (void)set_prefersToBeExclusiveWithCompetingLongPressGestureRecognizers:(BOOL)prefersToBeExclusiveWithCompetingLongPressGestureRecognizers;
@end

@interface SFFeatureManager : NSObject
@property (nonatomic, readonly, assign) NSInteger preferredCapsuleLayoutStyle;
+ (instancetype)sharedFeatureManager;
@end

@interface SFCapsuleCollectionView : UIView
@property (nonatomic, readonly) BOOL selectedItemIsMinimized;
@property (nonatomic, assign) BOOL itemsAreHidden;
- (CGFloat)_toolbarBackdropAlpha;
@end

@interface BrowserController : NSObject
@property (nonatomic, readonly) UIViewController *rootViewController;
- (void)setPresentingModalBookmarksController:(BOOL)isPresenting withExclusiveCollection:(id)exclusiveCollection bookmarkUUIDString:(NSString *)bookmarkUUIDString animated:(BOOL)animated;
@end

@interface SFCapsuleNavigationBar : UIView
@property (nonatomic, copy) NSArray<UIView *> *leadingButtons;
@property (nonatomic, copy) NSArray<UIView *> *trailingButtons;
@property (nonatomic, assign, setter=_setDidAddCustomMoreOptionsLongPressAction:) BOOL _didAddCustomMoreOptionsLongPressAction;
- (id)formatMenuButtonPopoverSourceInfo;
- (BrowserController *)delegate;
@end

@interface CapsuleNavigationBarViewController : UIViewController
@property (nonatomic, readonly) SFCapsuleNavigationBar *selectedItemNavigationBar;
@end

@interface SFStartPageCollectionViewController : UIViewController
- (id)dataSource;
@end

@interface CatalogViewController : UIViewController
- (BrowserController *)browserController;
@end

@interface CapsuleNavigationBarRegistration : NSObject
@property (nonatomic, strong, setter=_fs_setOriginalLeadingBarItems:) NSArray<NSNumber *> *_fs_originalLeadingBarItems;
@property (nonatomic, strong, setter=_fs_setOriginalTrailingBarItems:) NSArray<NSNumber *> *_fs_originalTrailingBarItems;
- (void)updateBarAnimated:(BOOL)animated;
@end

@interface SFCapsuleCollectionViewItem : NSObject
@property (nonatomic, strong, readonly) SFCapsuleCollectionView *collectionView;
@end

@interface _SFPageFormatMenuController : UIViewController
- (instancetype)initWithBrowserContentController:(BrowserController *)contentController;
- (void)presentMenuFromViewController:(UIViewController *)viewController withSourceInfo:(id)sourceInfo;
@end

@interface _SFUIViewPopoverSourceInfo : NSObject
@property (nonatomic, assign) BOOL shouldHideArrow;
- (instancetype)initWithView:(UIView *)view;
@end

@interface BrowserToolbar : UIToolbar
@end

@interface SFCapsuleView : UIView
@end

@interface SFStartPageViewController : UIViewController
@end

typedef NS_ENUM(NSInteger, SFBarItemIdentifier) {
	SFBarItemIdentifierBackButton,
	SFBarItemIdentifierForwardButton,
	SFBarItemIdentifierTabGroupsButton,
	SFBarItemIdentifierSidebarButton,
	SFBarItemIdentifierVoiceSearchButton,
	SFBarItemIdentifierMoreOptionsButton,
	SFBarItemIdentifierShareButton,
	SFBarItemIdentifierNewTabButton,
	SFBarItemIdentifierTabOverviewButton,
	SFBarItemIdentifierOpenInSafariButton,
	SFBarItemIdentifierCustomActivityButton,
	SFBarItemIdentifierDownloadsButton,
	SFBarItemIdentifierCancelBarItemButton,
	SFBarItemIdentifierPageFormatMenuButton,
	SFBarItemIdentifierStopButton,
	SFBarItemIdentifierReloadButton
};