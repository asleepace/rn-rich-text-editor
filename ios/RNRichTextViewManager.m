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
RCT_EXPORT_VIEW_PROPERTY(editable, BOOL)
RCT_EXPORT_VIEW_PROPERTY(html, NSString *)
RCT_EXPORT_VIEW_PROPERTY(onSizeChange, RCTBubblingEventBlock)

//RCT_EXPORT_VIEW_PROPERTY(height, NSNumber *)
//RCT_EXPORT_VIEW_PROPERTY(onSelection, RCTBubblingEventBlock)
//RCT_EXPORT_VIEW_PROPERTY(onSizeChange, RCTBubblingEventBlock)

- (UIView *)view {
  RNRichTextView *richTextView = [[RNRichTextView alloc] init];
  richTextView.delegate = self;
//  [richTextView initializeTextView];
  return richTextView;
}

+ (BOOL)requiresMainQueueSetup {
  return true;
}

#pragma mark - Exposed Methods


RCT_EXPORT_METHOD(showKeyboard:(nonnull NSNumber *)reactTag) {
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNRichTextView *> *viewRegistry) {
    RNRichTextView *view = viewRegistry[reactTag];
    if ([view isKindOfClass:[RNRichTextView class]]) return;
    [view showKeyboard];
  }];
}

RCT_EXPORT_METHOD(hideKeyboard:(nonnull NSNumber *)reactTag) {
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNRichTextView *> *viewRegistry) {
    RNRichTextView *view = viewRegistry[reactTag];
    if ([view isKindOfClass:[RNRichTextView class]]) return;
    [view hideKeyboard];
  }];
}

// returns the generated HTML output from the string
RCT_EXPORT_METHOD(resize:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNRichTextView *> *viewRegistry) {
        RNRichTextView *view = viewRegistry[reactTag];
        if ([view isKindOfClass:[RNRichTextView class]]) {
          [view resize];
        } else {
          RCTLogInfo(@"[TM] must be a view!");
        }
    }];
}

// allows react-native side to open an attribute tag
RCT_EXPORT_METHOD(insertTag:(nonnull NSNumber *)reactTag html:(NSString *)tag)
{
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNRichTextView *> *viewRegistry) {
    RNRichTextView *view = viewRegistry[reactTag];
    if ([view isKindOfClass:[RNRichTextView class]]) {
      [view insertTag:tag];
    } else {
      RCTLogInfo(@"[TM] must be a view!");
    }
  }];
};

// returns the generated HTML output from the string
RCT_EXPORT_METHOD(getHTML:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RNRichTextView *> *viewRegistry) {
        RNRichTextView *view = viewRegistry[reactTag];
        if ([view isKindOfClass:[RNRichTextView class]]) {
          [view generateHTML];
        } else {
          RCTLogInfo(@"[TM] must be a view!");
        }
    }];
}


#pragma mark - Delegate Methods


// when the content size changes in the text view we need to notify react-native of
// the changes to allow the view to grow.
- (void)didUpdate:(CGSize)size on:(nonnull RNRichTextView *)view {
  RCTLogInfo(@"[RNRichTextManager] didUpdate height: %f", size.height);
  [self.bridge.uiManager setIntrinsicContentSize:size forView:view];
}

@end
