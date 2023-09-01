//
//  RNRichTextView.h
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/23/23.
//

#import "RichTextDelegate.h"
#import <UIKit/UIFont.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CTStringAttributes.h>
#import <CoreText/CoreText.h>

#import <React/RCTView.h>
#import <React/RCTBridge.h>
#import <React/RCTComponent.h>
#import <React/RCTLog.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNRichTextView : RCTView <RCTBridgeModule, UITextViewDelegate>

@property (nonatomic, copy) RCTBubblingEventBlock onSizeChange;
@property (nonatomic, copy) RCTBubblingEventBlock onChangeText;
@property (nonatomic, copy) RCTBubblingEventBlock onChangeStyle;

@property (nonatomic, weak) id<RichTextViewDelegate> delegate;

@property (nonatomic, copy) NSString *plainText;
@property (nonatomic, copy) NSString *markdown;
@property (nonatomic, copy) NSString *html;

@property (nonatomic, strong) NSString *customStyle;

@property (nonatomic, assign) BOOL editable;

- (void)showKeyboard;
- (void)hideKeyboard;
- (void)resize;

- (void)insertTag:(NSString *)tag;
- (NSString *)generateHTML;

@end

NS_ASSUME_NONNULL_END
