//
//  RCTRichTextManager.m
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/16/23.
//

#import "RCTRichTextManager.h"
#import "RCTRichTextView.h"
#import <React/RCTBridge.h>

@implementation RCTRichTextManager

- (UIView *)view {
    return [[RCTRichTextView alloc] init];
}

+ (BOOL)requiresMainQueueSetup
{
    return true;
}

RCT_EXPORT_MODULE()
RCT_EXPORT_VIEW_PROPERTY(text, NSString *)
RCT_EXPORT_VIEW_PROPERTY(onSelection, RCTBubblingEventBlock)

// allows react-native side to open an attribute tag
RCT_EXPORT_METHOD(insertTag:(NSString *)tag with:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RCTRichTextView *> *viewRegistry) {
        RCTRichTextView *view = viewRegistry[reactTag];
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

@end
