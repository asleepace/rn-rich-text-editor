//
//  NSAttributedString+HTMLElements.m
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/31/23.
//

#import "NSAttributedString+HTMLElements.h"
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

@interface NSAttributedString()

@end

@implementation NSAttributedString (HTMLElements)

const NSString *KeyUnderline = @"NSUnderline";
const NSString *KeyStrikethrough = @"NSStrikethrough";
const NSString *KeyBackgroundColor = @"NSBackgroundColor";
const NSString *KeySuperscript = @"NSSuperScript";
const NSString *KeyCodefamily = @"Courier";

- (NSArray<NSString *> *)styles {
  NSMutableArray<NSString *> *currentStyles = [NSMutableArray new];
  NSDictionary *attributes = [self attributes];
  UIFont *font = [attributes objectForKey:NSFontAttributeName];
  UIFontDescriptor *fontDescriptor = font.fontDescriptor;
  [self handleBoldElements:fontDescriptor.symbolicTraits on:&currentStyles];
  [self handleItalicElements:fontDescriptor.symbolicTraits on:&currentStyles];
  [self handleUnderlinedElements:&attributes on:&currentStyles];
  [self handleCodeElements:&attributes on:&currentStyles];
  [self handleHighlightedElements:&attributes on:&currentStyles];
  [self handleSuperscriptElements:&attributes on:&currentStyles];
  [self handleSubscriptElements:&attributes on:&currentStyles];
  
  // testing lists
  [self handleListElements:&attributes on:&currentStyles];
  
  return currentStyles;
}


- (void)handleListElements:(NSDictionary **)attributes on:(NSMutableArray **)styles {
  NSParagraphStyle *paragraphStyle = [*attributes objectForKey:NSParagraphStyleAttributeName];
  NSLog(@"[RNRichTextEditor] handleListElements paragraphStyle: %@", paragraphStyle);
  if (!paragraphStyle) return;
  if (!paragraphStyle.textLists) return;
  if (paragraphStyle.textLists.count == 0) return;
  NSLog(@"[RNRichTextEditor] text lists: %@", paragraphStyle.textLists);
  [*styles addObject:@"<li>"];
}


- (NSDictionary *)attributes {
  return [self attributesAtIndex:0 effectiveRange:NULL];
}


- (void)handleBoldElements:(UIFontDescriptorSymbolicTraits)traits on:(NSMutableArray **)styles {
  if (traits & UIFontDescriptorTraitBold) {
    [*styles addObject:@"<strong>"];
  }
}

- (void)handleItalicElements:(UIFontDescriptorSymbolicTraits)traits on:(NSMutableArray **)styles {
  if (traits & UIFontDescriptorTraitItalic) {
    [*styles addObject:@"<em>"];
  }
}

- (void)handleStrikethroughElements:(NSDictionary **)attrs on:(NSMutableArray **)styles {
  if ([[*attrs objectForKey:KeyStrikethrough] boolValue]) {
    [*styles addObject:@"<strike>"];
  }
}

- (void)handleUnderlinedElements:(NSDictionary **)attrs on:(NSMutableArray **)styles {
  if ([[*attrs objectForKey:KeyUnderline] boolValue]) {
    [*styles addObject:@"<strike>"];
  }
}

- (void)handleCodeElements:(NSDictionary **)attrs on:(NSMutableArray **)styles {
  UIFont *font = [*attrs objectForKey:NSFontAttributeName];
  if (![font.familyName isEqualToString:@"Courier"]) return;
  if (![*attrs objectForKey:KeyBackgroundColor]) return;
  [*styles addObject:@"<code>"];
}

- (void)handleHighlightedElements:(NSDictionary **)attrs on:(NSMutableArray **)styles {
  if (![*attrs objectForKey:KeyBackgroundColor]) return;
  [*styles addObject:@"<mark>"];
}

- (void)handleSuperscriptElements:(NSDictionary **)attrs on:(NSMutableArray **)styles {
  if ([[*attrs objectForKey:KeySuperscript] intValue] <= 0) return;
  [*styles addObject:@"<sup>"];
}

- (void)handleSubscriptElements:(NSDictionary **)attrs on:(NSMutableArray **)styles {
  if ([[*attrs objectForKey:KeySuperscript] intValue] >= 0) return;
  [*styles addObject:@"<sub>"];
}


@end
