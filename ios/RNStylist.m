//
//  RNStylist.m
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/25/23.
//

#import "RNStylist.h"
#import <UIKit/UIKit.h>
//#import <UIKit/UIFont.h>
//#import <QuartzCore/QuartzCore.h>
//#import <CoreText/CTStringAttributes.h>
//#import <CoreText/CoreText.h>

@interface RNStylist()

@property (strong, nonatomic) NSString *css;

@end

@implementation RNStylist

//@synthesize defaultFontSize;

- (id)initWithStyle:(NSString *)css {
  if (self = [super init]) {
    self.css = css;
  }
  return self;
}

- (CGFloat)getDefaultFontSize {
  if (_defaultFontSize) return _defaultFontSize;
  NSDictionary *pTagAttributes = [self attributesForTag:@"<p>"];
  UIFont *currentFont = [pTagAttributes objectForKey:NSFontAttributeName];
  [self setDefaultFontSize:currentFont.pointSize];
  return currentFont.pointSize;
}

- (void)setDefaultFontSize:(CGFloat)defaultFontSize {
  _defaultFontSize = defaultFontSize;
}

- (NSString *)getClosingTag:(NSString *)openTag {
  return [NSString stringWithFormat:@"</%@", [openTag substringFromIndex:1]];
}

- (NSDictionary *)attributesForTag:(NSString *)tag {
  printf("[RNStyle] getting attributes for tag: %@", tag);
  if (tag.length == 0) return [self attributesForTag:@"<p>"];
  NSString *closingTag = [self getClosingTag:tag];
  NSString *tagsString = [NSString stringWithFormat:@"%@example%@", tag, closingTag];
  NSString *html = createHtmlString(tagsString, self.css);
  NSData *data = [html dataUsingEncoding:NSUnicodeStringEncoding];
  NSParagraphStyle *paragraphStyle = createParagraphStyle();
  NSAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:data options:@{
    NSParagraphStyleAttributeName: paragraphStyle,
    NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
    NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding),
  } documentAttributes:nil error:nil];
  return [attributedString attributesAtIndex:0 effectiveRange:nil];
}

NSParagraphStyle *createParagraphStyle(void) {
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.headIndent = 0;
  paragraphStyle.firstLineHeadIndent = 0;
  paragraphStyle.lineSpacing = 8;
  return paragraphStyle.copy;
}

NSString *createHtmlString(NSString *body, NSString *styles) {
  NSString *document = [NSString stringWithFormat:@"<!doctype html>\n<html>\n<head>\n<style>\n%@\n</style>\n</head>\n<body>\n%@\n</body>\n</html>", styles, body];
  printf("[RNStyle] document: \n%s\n", [document cStringUsingEncoding:NSUTF8StringEncoding]);
  return document;
}

- (NSString *)createHtmlDocument:(NSString *)body {
  NSString *document = [NSString stringWithFormat:@"<!doctype html>\n<html>\n<head>\n<style>\n%@\n</style>\n</head>\n<body>\n%@\n</body>\n</html>", self.css, body];
  printf("[RNStyle] createHtmlDocument: \n%s\n", [document cStringUsingEncoding:NSUTF8StringEncoding]);
  return document;
}

@end
