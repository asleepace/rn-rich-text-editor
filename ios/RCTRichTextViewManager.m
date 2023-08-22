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
    return [[RCTRichTextView alloc] init];
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
      
    RCTLogInfo(@"[RCTRichTextManager] insertTag called with: %@, %@", reactTag, tag);
    if ([view isKindOfClass:[RCTRichTextView class]]) {
      [view insertTag:tag];
    } else {
      RCTLogInfo(@"[RCTRichTextManager] must be a view!");
    }
      
    [view insertTag:tag];
  }];
};

// returns the generated HTML output from the string
RCT_EXPORT_METHOD(getHTML:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RCTRichTextView *> *viewRegistry) {
        RCTRichTextView *view = viewRegistry[reactTag];
        [view generateHTML];
    }];
}


#pragma mark - Delegate Methods


- (void)onHeightChange:(NSNumber *)height {
  
  
}

@end
