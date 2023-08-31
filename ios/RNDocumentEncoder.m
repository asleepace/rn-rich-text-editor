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
  RNStyle *nextStyle;
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
  nextStyle = [[RNStyle alloc] init];
  
  // enumerate the attributed string which will split the string into different chunks with different attributes,
  // which means each iteration an attribute has changed.
  [self.document enumerateAttributesInRange:range options:options usingBlock:
     ^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
    
    NSAttributedString *substring = [self.document attributedSubstringFromRange:range];
    
    RCTLogInfo(@"[RNDocumentEncoder] substring: %@ start: %lu length: %lu", substring, range.location, range.length);
    
    // update the previous style
    prevStyle = nextStyle;
    nextStyle = [RNStyle styleFrom:attrs];
    
    // handle opening elements
    [self handleOpeningElementBold];
    [self handleOpeningElementItalic];
    
    // append the current string
    [self.generatedHtml appendString:substring.string];
    
    // handle closing elements
    [self handleClosingElementItalic];
    [self handleClosingElementBold];
  }];
  
  // handle all closing tags one more time
  if (nextStyle.isItalic) [self.generatedHtml appendString:@"</i>"];
  if (nextStyle.isBold) [self.generatedHtml appendString:@"</b>"];
  [self.generatedHtml appendString:@"</body>"];
  
  // return the generated string
  return self.generatedHtml.copy;
}

- (void)handleOpeningElementBold {
  if (prevStyle.isBold == false && nextStyle.isBold) {
    [self.generatedHtml appendString:@"<b>"];
  }
}

- (void)handleClosingElementBold {
  if (prevStyle.isBold && nextStyle.isBold == false) {
    [self.generatedHtml appendString:@"</b>"];
  }
}

- (void)handleOpeningElementItalic {
  if (prevStyle.isItalic == false && nextStyle.isItalic) {
    [self.generatedHtml appendString:@"<i>"];
  }
}

- (void)handleClosingElementItalic {
  if (prevStyle.isItalic && nextStyle.isItalic == false) {
    [self.generatedHtml appendString:@"</i>"];
  }
}


#pragma mark - Helper Methods

- (void)print {
  RCTLogInfo(@"[NSDocumentEncoder] output: %@", self.generatedHtml);
}

- (BOOL)isStylePresent:(NSString *)style {
  return [self.openStack indexOfObject:style] != -1;
}


@end
