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
RCT_EXPORT_VIEW_PROPERTY(onSizeChange, RCTBubblingEventBlock)

//RCT_EXPORT_VIEW_PROPERTY(height, NSNumber *)
//RCT_EXPORT_VIEW_PROPERTY(text, NSString *)
//RCT_EXPORT_VIEW_PROPERTY(onSelection, RCTBubblingEventBlock)
//RCT_EXPORT_VIEW_PROPERTY(onSizeChange, RCTBubblingEventBlock)

- (UIView *)view {
  RNRichTextView *richTextView = [[RNRichTextView alloc] init];
  [richTextView initializeTextView];
  [richTextView setDelegate:self];
  return richTextView;
}

+ (BOOL)requiresMainQueueSetup {
  return true;
}

#pragma mark - Delegate Methods

- (void)didUpdate:(CGSize)size on:(RNRichTextView *)view {
  RCTLogInfo(@"[RNRichTextViewManager] didUpdate: (%f, %f)", size.width, size.height);
  
  // [self.bridge.uiManager setIntrinsicContentSize:size forView:view];
}

@end
