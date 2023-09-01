//
//  RNStyle.h
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/29/23.
//
//  This class handles the styling for each attribute passed into editor,
//  and contain information on how to style certain text.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RNStyle : NSObject

// base font family, size, etc.
@property (strong, nonatomic) UIFont *font;
@property (assign, nonatomic) UIFontDescriptorSymbolicTraits traits;
@property (strong, nonatomic) UIColor *foregroundColor;
@property (strong, nonatomic) UIColor *backgroundColor;

// simple font modifiers which can alter other styles
@property (assign, nonatomic) BOOL isStrikethrough;
@property (assign, nonatomic) BOOL isUnderlined;
@property (assign, nonatomic) BOOL isItalic;
@property (assign, nonatomic) BOOL isBold;

// composite font modifiers which consist of several styles
@property (assign, nonatomic) BOOL isHighlighted;
@property (assign, nonatomic) BOOL isSuperscript;
@property (assign, nonatomic) BOOL isSubscript;
@property (assign, nonatomic) BOOL isCode;

// methods
+ (RNStyle *)styleFrom:(NSDictionary *)fontAttributes;
- (NSDictionary *)toDictionary;
- (BOOL)isSame:(RNStyle *)otherStyle;
- (NSString *)stringHash;

@end
