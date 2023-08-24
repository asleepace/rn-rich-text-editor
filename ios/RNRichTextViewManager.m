//
//  RNRichTextViewManager.m
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/23/23.
//

#import "RNRichTextViewManager.h"
#import "RNRichTextView.h"

@implementation RNRichTextViewManager

RCT_EXPORT_MODULE()
RCT_EXPORT_VIEW_PROPERTY(html, NSString *)
RCT_EXPORT_VIEW_PROPERTY(onSizeChange, RCTBubblingEventBlock)

//RCT_EXPORT_VIEW_PROPERTY(height, NSNumber *)
//RCT_EXPORT_VIEW_PROPERTY(onSelection, RCTBubblingEventBlock)
//RCT_EXPORT_VIEW_PROPERTY(onSizeChange, RCTBubblingEventBlock)

- (UIView *)view {
  RNRichTextView *richTextView = [[RNRichTextView alloc] init];
  [richTextView initializeTextView];
  richTextView.delegate = self;
  return richTextView;
}

+ (BOOL)requiresMainQueueSetup {
  return true;
}

#pragma mark - Delegate Methods

// when the content size changes in the text view we need to notify react-native of
// the changes to allow the view to grow.
- (void)didUpdate:(CGSize)size on:(nonnull RNRichTextView *)view {
  RCTLogInfo(@"[RNRichTextManager] didUpdate height: %f", size.height);
  [self.bridge.uiManager setIntrinsicContentSize:size forView:view];
}

@end
