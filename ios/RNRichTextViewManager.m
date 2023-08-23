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

//RCT_EXPORT_VIEW_PROPERTY(height, NSNumber *)
//RCT_EXPORT_VIEW_PROPERTY(text, NSString *)
//RCT_EXPORT_VIEW_PROPERTY(onSelection, RCTBubblingEventBlock)
//RCT_EXPORT_VIEW_PROPERTY(onSizeChange, RCTBubblingEventBlock)

- (UIView *)view {
  RNRichTextView *richTextView = [[RNRichTextView alloc] init];
  [richTextView initializeTextView];
  //richTextView.delegate = self;
  return richTextView;
}

+ (BOOL)requiresMainQueueSetup {
  return true;
}

@end
