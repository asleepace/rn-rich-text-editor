//
//  RNStyle.m
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/29/23.
//

#import "RNStyle.h"
#import <React/RCTLog.h>

@interface RNStyle()

@end

@implementation RNStyle

@synthesize font;

const NSString *kUnderline = @"NSUnderline";
const NSString *kStrikethrough = @"NSStrikethrough";
const NSString *kBackgroundColor = @"NSBackgroundColor";
const NSString *kSuperscript = @"NSSuperScript";
const NSString *kCodefamily = @"Courier";

+ (RNStyle *)styleFrom:(NSDictionary *)fontAttributes {
  return [[RNStyle alloc] initWithFontAttributes:fontAttributes];
}


- (id)initWithFontAttributes:(NSDictionary *)fontAttributes {
  if (self = [super init]) {
    self.attributes = fontAttributes;
  }
  return self;
}


#pragma mark - Getters

- (UIFont *)


- (void)setPropertiesFromTraits {
  self.font = [attributes objectForKey:NSFontAttributeName];
  _traits = self.font.fontDescriptor.symbolicTraits;
}

- (UIFontDescriptorSymbolicTraits)getTraits {
  return self.font.fontDescriptor.symbolicTraits;
}

- (void)setTraits:(UIFontDescriptorSymbolicTraits)traits {
  UIFontDescriptor *updatedFontDescriptor = [self.font.fontDescriptor fontDescriptorWithSymbolicTraits:traits];
  UIFont *updatedFont = [UIFont fontWithDescriptor:updatedFontDescriptor size:self.font.pointSize];
  
  NSMutableDictionary *newAttributes = [[NSMutableDictionary alloc] initWithDictionary:attributes];
  [newAttributes setObject:updatedFont forKey:NSFontAttributeName];
  attributes = newAttributes.copy;
}

- (BOOL)isBold {
  return (_traits & UIFontDescriptorTraitBold) != 0;
}

- (BOOL)isItalic {
  return (_traits & UIFontDescriptorTraitItalic) != 0;
}

- (BOOL)isStrikethrough {
  return [[attributes objectForKey:kStrikethrough] boolValue];
}

- (BOOL)isUnderlined {
  return [[attributes objectForKey:kUnderline] boolValue];
}

- (BOOL)isCode {
  return [self.font.familyName isEqualToString:@"Courier"] && !![attributes objectForKey:kBackgroundColor];
}

- (BOOL)isHighlighted {
  return !![attributes objectForKey:kBackgroundColor];
}

- (BOOL)isSuperscript {
    return [[attributes objectForKey:kSuperscript] intValue] > 0;
}

- (BOOL)isSubscript:(NSDictionary *)attr {
  return [[attributes objectForKey:kSuperscript] intValue] < 0;
}


#pragma mark - Style from Tag


- (void)setStyleFrom:(NSString *)tag {
  RCTLogInfo(@"[RNStyle] setStyleFrom: %@", tag);
  
  if ([tag isEqualToString:@"<b>"]) {
    self.traits ^= UIFontDescriptorTraitBold;
  }
  else if ([tag isEqualToString:@"<i>"]) {
    self.traits ^= UIFontDescriptorTraitItalic;
  }
  else if ([tag isEqualToString:@"<u>"]) {
    
  }
  
}


#pragma mark - Debugging


- (NSDictionary *)toDictionary {
  return @{
    @"isBold": @(self.isBold),
    @"isItalic": @(self.isItalic),
    @"isUnderlined": @(self.isUnderlined),
    @"isStrikethrough": @(self.isStrikethrough),
    @"isHighlighted": @(self.isHighlighted),
    @"isSuperscript": @(self.isSuperscript),
    @"isSubscript": @(self.isSubscript),
    @"isCode": @(self.isCode)
  };
}


@end
