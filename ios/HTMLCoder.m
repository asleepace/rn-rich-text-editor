//
//  HTMLCoder.m
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/29/23.
//

#import "HTMLCoder.h"
#import <React/RCTLog.h>

@implementation HTMLCoder

@synthesize stylist;

- (id)init {
  if (self = [super init]) {
    self.stylist = [[RNStylist alloc] init];
  }
  return self;
}

// helper method which returns an attributed string from a given html string,
// this should be used in conjunction with the htmlFrom() method below.
- (NSAttributedString *)attributedStringFrom:(NSString *)html {
  NSString *htmlString = [self.stylist createHtmlDocument:html];
  RCTLogInfo(@"[RNRichTextView] setting html: \n%@ \n %@", html, htmlString);
  NSData *data = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.headIndent = 0;
  paragraphStyle.firstLineHeadIndent = 0;
  paragraphStyle.lineSpacing = 8;
  return [self trim:[[NSAttributedString alloc] initWithData:data options:@{
    NSParagraphStyleAttributeName: paragraphStyle,
    NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
    NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding),
  } documentAttributes:nil error:nil]];
}


// helper method which returns an html string from a given attributed string, this
// should be called once you are finished editing the UITextView.
- (NSString *)htmlFrom:(NSAttributedString *)attributedString {
  NSError *error = nil;
  NSRange range = NSMakeRange(0, attributedString.length);
  NSData *htmlData = [attributedString dataFromRange:range documentAttributes:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } error:&error];
  NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
  RCTLogInfo(@"[RNRichText] generate html: %@", htmlString);
  return htmlString;
  
//  __block NSMutableString *htmlString = [NSMutableString stringWithString:@""];
//  __block NSMutableArray<RNStyle *> *openTags = [NSMutableArray new];
//  
//  __block RNStyle *prevStyle = nil;
//  __block RNStyle *nextStyle = nil;
//  
//  NSRange range = NSMakeRange(0, attributedString.length);
//  [attributedString enumerateAttributesInRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:
//   ^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
//    
//    NSString *rawString = [attributedString.string substringWithRange:range];
//    RCTLogInfo(@"[HTMLCode] string: %@", rawString);
//    
//    // updated the styling
//    prevStyle = nextStyle;
//    nextStyle = [RNStyle styleFrom:attrs];
//    
//    // append opening tags
//    // TODO: implement
//    
//    // append current string
//    [htmlString appendString:rawString];
//    
//    // append closing tags
//    // TODO: implement
//  }];
//  
//  
//  return htmlString.copy; // TODO: implement
}


#pragma mark - Helper Methods


// when setting an attributed string from HTML we need to strip away extra whitespaces and newlines added by the editor,
// at some point we may need to track which were already there from the original post.
- (NSAttributedString *)trim:(NSAttributedString *)originalString {
  RCTLogInfo(@"[RNRichTextView] trimming characters...");
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:originalString];
  while ([attributedString.string length] > 0 && [[attributedString.string substringFromIndex:[attributedString.string length] - 1] rangeOfCharacterFromSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].location != NSNotFound) {
    [attributedString deleteCharactersInRange:NSMakeRange([attributedString length] - 1, 1)];
  }
  return attributedString;
}

@end
