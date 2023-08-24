//
//  RNRichTextView.m
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/23/23.
//

#import "RNRichTextView.h"

@interface RNRichTextView()
{
  CGSize lastReportedSize;
  NSAttributedString *attributedString;
}

@property (strong, nonatomic) UITextView *textView;

@end

@implementation RNRichTextView

@synthesize textView, onSizeChange, html;

RCT_EXPORT_MODULE()

//const NSStringDrawingOptions drawOptions = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
//const UIViewAnimationOptions viewOptions = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut;

+ (BOOL)requiresMainQueueSetup {
  return true;
}

- (void)initializeTextView {
  
  lastReportedSize = CGSizeZero;
  
  self.textView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:nil];
  [self.textView setDelegate:self];
  [self addSubview:self.textView];
  [self bringSubviewToFront:self.textView];
  [self.textView setScrollEnabled:false];
  
  // background colors
  [self setBackgroundColor:[UIColor clearColor]];
  [self.textView setBackgroundColor:[UIColor clearColor]];
  [self.textView setTextColor:[UIColor blackColor]];
  
  // set up text editor styles
  [self styleAtrributedText];
  
  // this will allow the text view to grow in height
  UILayoutGuide *safeArea = self.safeAreaLayoutGuide;
  self.textView.translatesAutoresizingMaskIntoConstraints = false;
  
  // this line might not be needed
  // self.translatesAutoresizingMaskIntoConstraints = false;
  
  // we can achieve different effects by choosing if we anchor the top or bottom,
  // currently anchoring the top works better as there is a bit of delay when we
  // resize the text.
  [NSLayoutConstraint activateConstraints:@[
    [self.textView.topAnchor constraintEqualToAnchor:safeArea.topAnchor],
    [self.textView.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor],
    //[self.textView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor],
    [self.textView.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor],
  ]];
  
  // tell the text view to become a first response
  [self.textView becomeFirstResponder];
}

- (BOOL)autoresizesSubviews {
  return true;
}

#pragma mark - Set Text Based on HTML

- (void)setHtml:(NSString *)html {
  RCTLogInfo(@"[RNRichTextView] setting html: \n%@", html);
  NSData *data = [html dataUsingEncoding:NSUnicodeStringEncoding];
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.headIndent = 0;
  paragraphStyle.firstLineHeadIndent = 0;
  paragraphStyle.lineSpacing = 8;
  NSDictionary *options = @{
    NSParagraphStyleAttributeName: paragraphStyle,
    NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
    NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding),
    NSFontAttributeName: [UIFont systemFontOfSize:16.0]
  };
  
  attributedString = [[NSMutableAttributedString alloc] initWithData:data options:options documentAttributes:nil error:nil];
  self.textView.attributedText = [self trim:attributedString];
  [self reportSize:self.textView];
}

// when setting an attributed string from HTML we need to strip away extra whitespaces and newlines added by the editor,
// at some point we may need to track which were already there from the original post.
- (NSAttributedString *)trim:(NSAttributedString *)originalString {
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:originalString];
  while ([attributedString.string length] > 0 && [[attributedString.string substringFromIndex:[attributedString.string length] - 1] rangeOfCharacterFromSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].location != NSNotFound) {
    [attributedString deleteCharactersInRange:NSMakeRange([attributedString length] - 1, 1)];
  }
  return attributedString;
}

#pragma mark - Attributed Text Styling

- (void)styleAtrributedText {
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.headIndent = 0;
  paragraphStyle.firstLineHeadIndent = 0;
  //paragraphStyle.lineHeightMultiple = 20;
  paragraphStyle.lineSpacing = 8;
  NSDictionary *attrsDictionary = @{
    NSParagraphStyleAttributeName: paragraphStyle,
    NSFontAttributeName: [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular],
  };
  self.textView.attributedText = [[NSAttributedString alloc] initWithString:@"Hello World over many lines!" attributes:attrsDictionary];
}

#pragma mark - Dynamic Sizing

- (void)reportSize:(UITextView *)textView {
  CGRect updatedFrame = self.frame;
  updatedFrame.size = CGSizeMake(updatedFrame.size.width, self.textView.frame.size.height);
  
  // check if the height has changed, if not return early.
  //if (lastReportedSize.height == updatedFrame.size.height) {
  //  return;
  //}
  
  // update the container views frame
  lastReportedSize = updatedFrame.size;
  self.frame = updatedFrame;
  
  // report size changes to react-native
  [self.delegate didUpdate:updatedFrame.size on:self];
  
  // report size changes to JS
  // self.onSizeChange(@{ @"height": @(updatedFrame.size.height) });
  
  // may help with animations
  [UIView animateWithDuration:0.01 animations:^{
    [self layoutIfNeeded];
  }];
}

#pragma mark - UITextView Delegate Methods

// most important method for reporting size changes to react-native
- (void)textViewDidChange:(UITextView *)textView {
  [self.textView sizeToFit];
  [self.textView layoutIfNeeded];
  [self reportSize:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  [self reportSize:textView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
  NSAttributedString *subString = [textView.attributedText attributedSubstringFromRange:textView.selectedRange];
  RCTLogInfo(@"[RNRichTextView] textViewDidChangeSelection: %@", subString);
}

#pragma mark - Inserting HTML Tags
//
//- (void)insertTag:(NSString *)tag {
//  NSRange range = self.textView.selectedRange;
//  NSAttributedString *firstHalf = [attributedString attributedSubstringFromRange:NSMakeRange(0, range.location)];
//  NSAttributedString *midHalf = [attributedString attributedSubstringFromRange:range];
//  NSInteger selection = range.location + range.length;
//  NSInteger endlength = attributedString.length - selection;
//  NSAttributedString *lastHalf  = [attributedString attributedSubstringFromRange:NSMakeRange(selection, endlength)];
//  NSMutableAttributedString *combinedString = [NSMutableAttributedString new];
//  [combinedString appendAttributedString:firstHalf];
//  [combinedString appendAttributedString:[self addAttribute:midHalf fromTag:tag]];
//  [combinedString appendAttributedString:lastHalf];
//  attributedString = combinedString.copy;
//}
//
//- (NSAttributedString *)addAttribute:(NSAttributedString *)string fromTag:(NSString *)tag {
//    NSMutableAttributedString *mut = [[NSMutableAttributedString alloc] initWithAttributedString:string];
//    [string enumerateAttributesInRange:NSMakeRange(0, string.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
//        UIFont *font = [attrs objectForKey:NSFontAttributeName];
//        UIFontDescriptorSymbolicTraits sym = font.fontDescriptor.symbolicTraits;
//        
//        if ([tag isEqualToString:@"<b>"]) sym = [self toggle:UIFontDescriptorTraitBold key:@"isBold" on:sym];
//        else if ([tag isEqualToString:@"<i>"]) sym = [self toggle:UIFontDescriptorTraitItalic key:@"isItalic" on:sym];
//        else if ([tag isEqualToString:@"<del>"]) attrs = [self strikethrough:attrs];
//        else if ([tag isEqualToString:@"<sup>"]) attrs = [self subOrSup:attrs tag:@"isSuperscript" value:@1];
//        else if ([tag isEqualToString:@"<sub>"]) attrs = [self subOrSup:attrs tag:@"isSubscript" value:@-1];
//        else if ([tag isEqualToString:@"<ins>"]) attrs = [self subOrSup:attrs tag:@"isInserted" value:@1];
//        else if ([tag isEqualToString:@"<code>"]) attrs = @{};
//        
//        UIFontDescriptor *fd =  [font.fontDescriptor fontDescriptorWithSymbolicTraits:sym];
//        UIFont *updatedFont = [UIFont fontWithDescriptor:fd size:0.0];
//        NSMutableDictionary *newAttr = [NSMutableDictionary new];
//        [newAttr addEntriesFromDictionary:attrs];
//        [newAttr addEntriesFromDictionary:@{ NSFontAttributeName: updatedFont }];
//        [mut setAttributes:newAttr range:range];
//    }];
//    return mut;
//}
//
//- (UIFontDescriptorSymbolicTraits)toggle:(uint32_t)attr key:(NSString *)key on:(UIFontDescriptorSymbolicTraits)traits {
//    if ([[selectedAttr objectForKey:key] isEqualToNumber:@(true)] && (traits & attr))
//        traits ^= attr;
//    else
//        traits |= attr;
//    return traits;
//}
//
//- (NSDictionary *)strikethrough:(NSDictionary *)attr {
//    NSMutableDictionary *mutable = attr.mutableCopy;
//    if ([selectedAttr[@"isStrikethrough"] isEqualToNumber:@(true)] && [mutable objectForKey:@"NSStrikethrough"])
//        [mutable removeObjectForKey:@"NSStrikethrough"];
//    else
//        [mutable setObject:@2 forKey:@"NSStrikethrough"];
//    return mutable.copy;
//}
//
//- (NSDictionary *)subOrSup:(NSDictionary *)attr tag:(NSString *)tag value:(NSNumber *)num {
//    NSMutableDictionary *mutable = attr.mutableCopy;
//    //RCTLogInfo(@"[RichTextEditor] sub or sup: %@ tag: %@", selectedAttr[attr], attr);
//    if ([selectedAttr[tag] isEqualToNumber:@(true)] && [mutable objectForKey:@"NSSuperScript"])
//        [mutable removeObjectForKey:@"NSSuperScript"];
//    else
//        [mutable setObject:num forKey:@"NSSuperScript"];
//    return mutable.copy;
//}
//
//
//- (BOOL)isFontBold:(UIFontDescriptorSymbolicTraits)traits {
//    return (traits & UIFontDescriptorTraitBold) != 0;
//}
//
//- (BOOL)isFontItalic:(UIFontDescriptorSymbolicTraits)traits {
//    return (traits & UIFontDescriptorTraitItalic) != 0;
//}
//
//- (BOOL)isFontStrikethrough:(NSDictionary *)attr {
//    return !![attr objectForKey:@"NSStrikethrough"];
//}
//
//- (BOOL)isFontCode:(NSDictionary *)attr {
//    UIFont *font = [attr objectForKey:NSFontAttributeName];
//    return [font.familyName isEqualToString:@"Courier"] && !![attr objectForKey:@"NSBackgroundColor"];
//}
//
//- (BOOL)isFontMarked:(NSDictionary *)attr {
//    return !![attr objectForKey:@"NSBackgroundColor"];
//}
//
//- (BOOL)isFontSuperscript:(NSDictionary *)attr {
//    return [[attr objectForKey:@"NSSuperScript"] intValue] > 0;
//}
//
//- (BOOL)isFontSubscript:(NSDictionary *)attr {
//    return [[attr objectForKey:@"NSSuperScript"] intValue] < 0;
//}
//
//- (BOOL)isFontInserted:(NSDictionary *)attr {
//    return !![attr objectForKey:@"NSUnderline"];
//}


@end
