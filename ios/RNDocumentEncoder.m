//
//  RNDocumentEncoder.m
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/30/23.
//

#import <React/RCTLog.h>
#import "RNDocumentEncoder.h"
#import "RNStyle.h"

@interface RNDocumentEncoder()
{
  RNStyle *prevStyle;
  RNStyle *style;
}

@property (strong, nonatomic) NSAttributedString *document;
@property (strong, nonatomic) NSMutableArray *openStack;
@property (strong, nonatomic) NSMutableString *generatedHtml;

@end

@implementation RNDocumentEncoder

- (id)initWithDocument:(NSAttributedString *)document {
  if (self = [super init]) {
    self.generatedHtml = [NSMutableString stringWithString:@"<body>"];
    self.openStack = [NSMutableArray new];
    self.document = document;
  }
  return self;
}


- (NSString *)htmlEncode {
  NSRange range = NSMakeRange(0, self.document.length);
  NSAttributedStringEnumerationOptions options = NSAttributedStringEnumerationLongestEffectiveRangeNotRequired;
  
  // initialize prevStyle with body?
  style = [[RNStyle alloc] init];
  
  // enumerate the attributed string which will split the string into different chunks with different attributes,
  // which means each iteration an attribute has changed.
  [self.document enumerateAttributesInRange:range options:options usingBlock:
     ^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
    
    NSAttributedString *substring = [self.document attributedSubstringFromRange:range];
    
    RCTLogInfo(@"[RNDocumentEncoder] substring: %@ start: %lu length: %lu", substring, range.location, range.length);
    
    // update the previous style (order matters)
    prevStyle = style;
    style = [RNStyle styleFrom:attrs];
    
    // handle opening elements
    if (prevStyle.isBold == false && style.isBold) [self.generatedHtml appendString:@"<b>"];
    if (prevStyle.isItalic == false && style.isItalic) [self.generatedHtml appendString:@"<i>"];

    // append the current string
    [self.generatedHtml appendString:substring.string];
    
    // handle closing elements
    if (prevStyle.isItalic && style.isItalic == false) [self.generatedHtml appendString:@"</i>"];
    if (prevStyle.isBold && style.isBold == false) [self.generatedHtml appendString:@"</b>"];
    
  }];
  
  // handle all closing tags one more time in same order
  if (style.isItalic) [self.generatedHtml appendString:@"</i>"];
  if (style.isBold) [self.generatedHtml appendString:@"</b>"];
  [self.generatedHtml appendString:@"</body>"];
  
  // return the generated string
  return self.generatedHtml.copy;
}


#pragma mark - Helper Methods

- (void)print {
  RCTLogInfo(@"[NSDocumentEncoder] output: %@", self.generatedHtml);
}

- (BOOL)isStylePresent:(NSString *)style {
  return [self.openStack indexOfObject:style] != -1;
}


@end
