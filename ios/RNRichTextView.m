//
//  RNRichTextView.m
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/23/23.
//

#import "RNRichTextView.h"
#import <WebKit/WKWebView.h>

@interface RNRichTextView()
{
  CGSize lastReportedSize;
  // added from previous class
  __block NSMutableString *htmlString;
  NSMutableArray *openTags;
  NSMutableArray *nextTags;
  NSMutableArray *nextHTML;
  CGRect originalFrame;
  CGRect keyboardFrame;
  NSMutableDictionary *selectedAttr;
}

@property (strong, nonatomic) NSAttributedString *attributedString;
@property (strong, nonatomic) UITextView *textView;

@end

@implementation RNRichTextView

@synthesize textView, editable, onSizeChange, html, attributedString = _attributedString;

RCT_EXPORT_MODULE()

//const NSStringDrawingOptions drawOptions = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
//const UIViewAnimationOptions viewOptions = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut;

+ (BOOL)requiresMainQueueSetup {
  return true;
}

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

- (id)init {
  
  if (self = [super init]) {
    
    RCTLogInfo(@"[RNRichTextView] init called!");
    
    lastReportedSize = CGSizeZero;
    openTags = [NSMutableArray new];
    nextTags = [NSMutableArray new];
    nextHTML = [NSMutableArray new];
    
    // initialize with scroll set to false and frame set to zero
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
  }
  
  return self;
}

- (void)setPlaceholder {
  self.textView.textColor = [UIColor lightGrayColor];
  self.textView.text = @"Enter anything here...";
}

- (void)clearPlaceholder {
  if ([self.textView.text isEqualToString:@"Enter anything here..."]) {
    self.textView.text = nil;
    self.textView.textColor = [UIColor blackColor];
  }
}

- (BOOL)autoresizesSubviews {
  return true;
}

#pragma mark - Custom Properties


- (void)setEditable:(BOOL)editable {
  RCTLogInfo(@"[RNRichTextView] setEditable: %@", editable ? @"true" : @"false");
  [self.textView setEditable:editable];
}

- (void)hideKeyboard {
  [self.textView resignFirstResponder];
}

- (void)showKeyboard {
  [self.textView becomeFirstResponder];
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
  
  // see the setter method for more details on this method
  self.attributedString = [[NSMutableAttributedString alloc] initWithData:data options:options documentAttributes:nil error:nil];
}

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


#pragma mark - Attributed Text Styling


- (void)setAttributedString:(NSAttributedString *)attributedString {
  RCTLogInfo(@"[RNRichTextEditor] setting attributed string...");
  self.textView.attributedText = [self trim:attributedString];
  [self resize];
}

- (NSAttributedString *)attributedString {
  NSAttributedString *current = self.textView.attributedText;
  RCTLogInfo(@"[RNRichTextEditor] getting attributed string: %@", current.string);
  return current;
}


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

- (void)resize {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self reportSize:self.textView];
  });
}


- (void)reportSize:(UITextView *)textView {
  [self.textView sizeToFit];
  [self.textView layoutIfNeeded];
  
  CGRect updatedFrame = self.frame;
  updatedFrame.size = CGSizeMake(updatedFrame.size.width, self.textView.frame.size.height);
  
  // check if the height has changed, if not return early.
  if (lastReportedSize.height == updatedFrame.size.height) {
    return;
  }
  
  // update the container views frame
  lastReportedSize = updatedFrame.size;
  self.frame = updatedFrame;
  
  // report size changes to react-native
  [self.delegate didUpdate:updatedFrame.size on:self];
  
  // report size changes to JS
  // self.onSizeChange(@{ @"height": @(updatedFrame.size.height) });
  
  // may help with animations
  [self sizeToFit];
  [self layoutIfNeeded];
}

#pragma mark - UITextView Delegate Methods

// most important method for reporting size changes to react-native
- (void)textViewDidChange:(UITextView *)textView {
  [self reportSize:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  [self setPlaceholder];
  [self reportSize:textView];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
  [self clearPlaceholder];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
  UITextPosition* beginning = textView.beginningOfDocument;
  UITextRange* selectedRange = textView.selectedTextRange;
  UITextPosition* selectionStart = selectedRange.start;
  UITextPosition* selectionEnd = selectedRange.end;
  const NSInteger location = [textView offsetFromPosition:beginning toPosition:selectionStart];
  const NSInteger length = [textView offsetFromPosition:selectionStart toPosition:selectionEnd];
  if (length == 0) return;
  //RCTLogInfo(@"[RichTextEditor] location: %lu length: %lu", location, length);
  NSRange range = NSMakeRange(location, length);
  [self getAttributesInRange:range];
  //self.onSelection(selectedAttr);
}

//- (void)textViewDidChangeSelection:(UITextView *)textView {
//  NSAttributedString *subString = [textView.attributedText attributedSubstringFromRange:textView.selectedRange];
//  RCTLogInfo(@"[RNRichTextView] textViewDidChangeSelection: %@", subString);
//}

#pragma mark - Inserting HTML Tags

- (void)getAttributesInRange:(NSRange)range {
  selectedAttr = [NSMutableDictionary new];
  [selectedAttr setObject:@(true) forKey:@"isBold"];
  [selectedAttr setObject:@(true) forKey:@"isItalic"];
  [selectedAttr setObject:@(true) forKey:@"isStrikethrough"];
  [selectedAttr setObject:@(true) forKey:@"isSuperscript"];
  [selectedAttr setObject:@(true) forKey:@"isSubscript"];
  [selectedAttr setObject:@(true) forKey:@"isCode"];
  [selectedAttr setObject:@(true) forKey:@"isMarked"];
  
  RCTLogInfo(@"[RNRichTextView] getAttributesInRange: %@", self.attributedString);
  
  [self.attributedString enumerateAttributesInRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:
     ^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
    UIFont *font = [attrs objectForKey:NSFontAttributeName];
    UIFontDescriptor *fontDescriptor = font.fontDescriptor;
    UIFontDescriptorSymbolicTraits traits = fontDescriptor.symbolicTraits;
    if (![self isFontBold:traits]) [self->selectedAttr setObject:@(false) forKey:@"isBold"];
    if (![self isFontItalic:traits]) [self->selectedAttr setObject:@(false) forKey:@"isItalic"];
    if (![self isFontStrikethrough:attrs]) [self->selectedAttr setObject:@(false) forKey:@"isStrikethrough"];
    if (![self isFontSubscript:attrs]) [self->selectedAttr setObject:@(false) forKey:@"isSubscript"];
    if (![self isFontSuperscript:attrs]) [self->selectedAttr setObject:@(false) forKey:@"isSuperscript"];
    if (![self isFontInserted:attrs]) [self->selectedAttr setObject:@(false) forKey:@"isInserted"];
        
    // these two should be rendered seperatly
    if (![self isFontCode:attrs]) [self->selectedAttr setObject:@(false) forKey:@"isCode"];
    if (![self isFontMarked:attrs]) [self->selectedAttr setObject:@(false) forKey:@"isMarked"];
  }];
}


- (void)insertTag:(NSString *)tag {
  NSRange range = self.textView.selectedRange;
  RCTLogInfo(@"[RNRichTextView] insertTag: %@ range: %lu length: %lu", tag, range.location, range.length);
  RCTLogInfo(@"[RNRichTextView] attributedString: %@", self.attributedString);
  NSAttributedString *firstHalf = [self.attributedString attributedSubstringFromRange:NSMakeRange(0, range.location)];
  RCTLogInfo(@"[RNRichTextView] firstHalf: %@", firstHalf);
  NSAttributedString *midHalf = [self.attributedString attributedSubstringFromRange:range];
  RCTLogInfo(@"[RNRichTextView] midHalf: %@", midHalf);
  NSInteger selection = range.location + range.length;
  NSInteger endlength = self.attributedString.length - selection;
  NSAttributedString *lastHalf  = [self.attributedString attributedSubstringFromRange:NSMakeRange(selection, endlength)];
  NSMutableAttributedString *combinedString = [NSMutableAttributedString new];
  [combinedString appendAttributedString:firstHalf];
  [combinedString appendAttributedString:[self addAttribute:midHalf fromTag:tag]];
  [combinedString appendAttributedString:lastHalf];
  self.attributedString = combinedString.copy;
  self.textView.attributedText = self.attributedString;
}

- (NSAttributedString *)addAttribute:(NSAttributedString *)string fromTag:(NSString *)tag {
    NSMutableAttributedString *mut = [[NSMutableAttributedString alloc] initWithAttributedString:string];
    [string enumerateAttributesInRange:NSMakeRange(0, string.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        UIFont *font = [attrs objectForKey:NSFontAttributeName];
        UIFontDescriptorSymbolicTraits sym = font.fontDescriptor.symbolicTraits;
        
        if ([tag isEqualToString:@"<b>"]) sym = [self toggle:UIFontDescriptorTraitBold key:@"isBold" on:sym];
        else if ([tag isEqualToString:@"<i>"]) sym = [self toggle:UIFontDescriptorTraitItalic key:@"isItalic" on:sym];
        else if ([tag isEqualToString:@"<del>"]) attrs = [self strikethrough:attrs];
        else if ([tag isEqualToString:@"<sup>"]) attrs = [self subOrSup:attrs tag:@"isSuperscript" value:@1];
        else if ([tag isEqualToString:@"<sub>"]) attrs = [self subOrSup:attrs tag:@"isSubscript" value:@-1];
        else if ([tag isEqualToString:@"<ins>"]) attrs = [self subOrSup:attrs tag:@"isInserted" value:@1];
        else if ([tag isEqualToString:@"<code>"]) attrs = @{};
        
        UIFontDescriptor *fd =  [font.fontDescriptor fontDescriptorWithSymbolicTraits:sym];
        UIFont *updatedFont = [UIFont fontWithDescriptor:fd size:0.0];
        NSMutableDictionary *newAttr = [NSMutableDictionary new];
        [newAttr addEntriesFromDictionary:attrs];
        [newAttr addEntriesFromDictionary:@{ NSFontAttributeName: updatedFont }];
        [mut setAttributes:newAttr range:range];
    }];
    return mut;
}

- (UIFontDescriptorSymbolicTraits)toggle:(uint32_t)attr key:(NSString *)key on:(UIFontDescriptorSymbolicTraits)traits {
    if ([[selectedAttr objectForKey:key] isEqualToNumber:@(true)] && (traits & attr))
        traits ^= attr;
    else
        traits |= attr;
    return traits;
}

- (NSDictionary *)strikethrough:(NSDictionary *)attr {
    NSMutableDictionary *mutable = attr.mutableCopy;
    if ([selectedAttr[@"isStrikethrough"] isEqualToNumber:@(true)] && [mutable objectForKey:@"NSStrikethrough"])
        [mutable removeObjectForKey:@"NSStrikethrough"];
    else
        [mutable setObject:@2 forKey:@"NSStrikethrough"];
    return mutable.copy;
}

- (NSDictionary *)subOrSup:(NSDictionary *)attr tag:(NSString *)tag value:(NSNumber *)num {
    NSMutableDictionary *mutable = attr.mutableCopy;
    //RCTLogInfo(@"[RichTextEditor] sub or sup: %@ tag: %@", selectedAttr[attr], attr);
    if ([selectedAttr[tag] isEqualToNumber:@(true)] && [mutable objectForKey:@"NSSuperScript"])
        [mutable removeObjectForKey:@"NSSuperScript"];
    else
        [mutable setObject:num forKey:@"NSSuperScript"];
    return mutable.copy;
}


- (BOOL)isFontBold:(UIFontDescriptorSymbolicTraits)traits {
    return (traits & UIFontDescriptorTraitBold) != 0;
}

- (BOOL)isFontItalic:(UIFontDescriptorSymbolicTraits)traits {
    return (traits & UIFontDescriptorTraitItalic) != 0;
}

- (BOOL)isFontStrikethrough:(NSDictionary *)attr {
    return !![attr objectForKey:@"NSStrikethrough"];
}

- (BOOL)isFontCode:(NSDictionary *)attr {
    UIFont *font = [attr objectForKey:NSFontAttributeName];
    return [font.familyName isEqualToString:@"Courier"] && !![attr objectForKey:@"NSBackgroundColor"];
}

- (BOOL)isFontMarked:(NSDictionary *)attr {
    return !![attr objectForKey:@"NSBackgroundColor"];
}

- (BOOL)isFontSuperscript:(NSDictionary *)attr {
    return [[attr objectForKey:@"NSSuperScript"] intValue] > 0;
}

- (BOOL)isFontSubscript:(NSDictionary *)attr {
    return [[attr objectForKey:@"NSSuperScript"] intValue] < 0;
}

- (BOOL)isFontInserted:(NSDictionary *)attr {
    return !![attr objectForKey:@"NSUnderline"];
}

#pragma mark - Generate HTML

- (NSString *)generateHTML {
  htmlString = [NSMutableString stringWithString:@"<p>"];
  NSRange range = NSMakeRange(0, self.attributedString.length);
  [self.attributedString enumerateAttributesInRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:
    ^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
      NSString *text = [self.attributedString.string substringWithRange:range];
      //RCTLogInfo(@"[RichTextEditor] '%@'", text);
      NSString *currentTags = [self getTagForAttribute:attrs]; // call this before closeOpenTags!
      NSString *closingTags = [self closeOpenTags];
      [htmlString appendString:closingTags];
      [htmlString appendString:currentTags];
      [htmlString appendString:text];
      nextHTML = [NSMutableArray new]; // next html applies only to the current element
      nextTags = [NSMutableArray new]; // next tags only apply to the current element
  }];
  //RCTLogInfo(@"[RichTextEditor] open tags: %@", openTags);
  [htmlString appendString:[self closeOpenTags]];
  [htmlString appendString:@"</p>"];
  //RCTLogInfo(@"[RichTextEditor] generated html: %@", htmlString);
  return htmlString.copy;
}

// This methods returns an array of html tags that is present on the current attributed text
// which will then be added to our generated html output. Since there can already be open tags
// we want to prevent multiple instances of the same tag being open at once, so even if a trait
// is present, we first check if it has already been opened before adding to the html array.

- (NSString *)getTagForAttribute:(NSDictionary *)attributes {
    UIFont *font = [attributes objectForKey:NSFontAttributeName];
    UIFontDescriptor *fontDescriptor = font.fontDescriptor;
    UIFontDescriptorSymbolicTraits traits = fontDescriptor.symbolicTraits;
    if ([self isFontBold:traits]) [self addTag:@"<b>"];
    if ([self isFontItalic:traits]) [self addTag:@"<i>"];
    if ([self isFontStrikethrough:attributes]) [self addTag:@"<del>"];
    if ([self isFontSubscript:attributes]) [self addTag:@"<sub>"];
    if ([self isFontSuperscript:attributes]) [self addTag:@"<sup>"];
    if ([self isFontInserted:attributes]) [self addTag:@"<ins>"];
    
    // these two should be rendered seperatly
    if ([self isFontCode:attributes]) [self addTag:@"<code>"];
    else if ([self isFontMarked:attributes]) [self addTag:@"<mark>"];
    
    return [nextHTML componentsJoinedByString:@""];
}

// This method checks to see if any open tags need to be closed after iterating to the next element,
// if the next element is missing a tag that is currently open, then we need to close that tag before
// moving on. We compare the next elements atttributes to the current open tags, if the next elements
// tags are missing, then we add the closing tag and remove that tag from openTags.

- (NSString *)closeOpenTags {
    NSMutableArray *closingTags = [NSMutableArray new];
    NSArray *openTagsFrozenCopy = [openTags copy];
    for (NSString *openedTag in [openTagsFrozenCopy reverseObjectEnumerator]) {
        if (!isFound(openedTag, nextTags)) {
            [closingTags addObject:closeTag(openedTag)];
            [openTags removeObject:openedTag];
        }
    }
    return [closingTags componentsJoinedByString:@""];
}


// This helper methods converts a given tag into the cooresponding mathcing tag
// for example it will convert the tag <strong> to </strong>
NSString * closeTag(NSString *tag) {
    return [NSString stringWithFormat:@"</%@",[tag substringFromIndex:1]];
}

// Add Tag is called each time an attribute is found on the current string segment, this will always add
// the tag to nextTags (which is used to detect when to close tags) it then checks the openTags array to
// make sure the tag isn't already open. If it is not open, this then adds the tag to openTags as well as
// the current strings nextHTML array (which is used to generated the html).

- (void)addTag:(NSString *)tag {
    [nextTags addObject:tag];
    if (isFound(tag, openTags)) return;
    [openTags addObject:tag];
    [nextHTML addObject:tag];
}

// This helper method checks if a given string exists on a given array, and returns
// true if found or false if not found.
BOOL isFound(NSString *item, NSArray *array) {
    for (NSString *tag in array) {
        if ([item isEqualToString:tag])
            return true;
    } return false;
}

@end
