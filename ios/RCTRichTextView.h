//
//  RCTRichTextView.h
//  Padlet
//
//  Created by Colin Teahan on 3/3/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTBridge.h>
#import <React/RCTComponent.h>
//#import <React/RCTBridge.h>
//#import <React/RCTLog.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCTRichTextView : UITextView <UITextViewDelegate>

@property (nonatomic, copy) RCTBubblingEventBlock onSizeChange;

@property (nonatomic, copy) NSString *text;
@property (assign) CGFloat maxHeight;
@property (assign) CGFloat minHeight;
@property (assign) CGFloat lineHeight;

- (void)insertTag:(NSString *)tag;
- (NSString *)generateHTML;

@end

NS_ASSUME_NONNULL_END
