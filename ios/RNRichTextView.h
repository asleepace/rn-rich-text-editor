//
//  RNRichTextView.h
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/23/23.
//

#import <UIKit/UIFont.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CTStringAttributes.h>
#import <CoreText/CoreText.h>

#import <React/RCTView.h>
#import <React/RCTBridge.h>
#import <React/RCTLog.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNRichTextView : RCTView <RCTBridgeModule, UITextViewDelegate>

@property (nonatomic, copy) NSString *text;

- (void)initializeTextView;

@end

NS_ASSUME_NONNULL_END
