//
//  RCTRichTextManager.m
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/16/23.
//

#import "RCTRichTextViewManager.h"
#import "RCTRichTextView.h"
#import <React/RCTBridge.h>

@implementation RCTRichTextViewManager

RCT_EXPORT_MODULE()

RCT_EXPORT_VIEW_PROPERTY(height, NSNumber *)
RCT_EXPORT_VIEW_PROPERTY(text, NSString *)
RCT_EXPORT_VIEW_PROPERTY(onSelection, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onHeightChange, RCTBubblingEventBlock)

- (UIView *)view {
  RCTRichTextView *richTextView = [[RCTRichTextView alloc] init];
  richTextView.delegate = self;
  return richTextView;
}

+ (BOOL)requiresMainQueueSetup
{
  return true;
}


// allows react-native side to open an attribute tag
RCT_EXPORT_METHOD(insertTag:(nonnull NSNumber *)reactTag html:(NSString *)tag)
{
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RCTRichTextView *> *viewRegistry) {
    RCTRichTextView *view = viewRegistry[reactTag];
    RCTLogInfo(@"[TM] insertTag called with: %@, %@", reactTag, tag);
    if ([view isKindOfClass:[RCTRichTextView class]]) {
      [view insertTag:tag];
    } else {
      RCTLogInfo(@"[TM] must be a view!");
    }
  }];
};

// returns the generated HTML output from the string
RCT_EXPORT_METHOD(getHTML:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RCTRichTextView *> *viewRegistry) {
        RCTRichTextView *view = viewRegistry[reactTag];
        if ([view isKindOfClass:[RCTRichTextView class]]) {
          [view generateHTML];
        } else {
          RCTLogInfo(@"[TM] must be a view!");
        }
    }];
}


#pragma mark - Delegate Methods


- (void)textViewDidChange:(UITextView *)textView {
  RCTLogInfo(@"[TM] textViewDidChange height: %f", textView.frame.size.height);
  RCTLogInfo(@"[TM] textViewDidChange content height: %f", textView.contentSize.height);
  RCTLogInfo(@"- - - - - - - - - - - - -");
}

@end
