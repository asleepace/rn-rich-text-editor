//
//  RCTRichTextView.m
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/16/23.
//
#import "RCTRichTextView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CTStringAttributes.h>
#import <CoreText/CoreText.h>

#import <UIKit/UIFont.h>

@interface RCTRichTextView()
{
    __block NSMutableString *htmlString;
    NSMutableArray *openTags;
    NSMutableArray *nextTags;
    NSMutableArray *nextHTML;
    CGRect originalFrame;
    CGRect keyboardFrame;
    NSMutableDictionary *selectedAttr;
}

@end

@implementation RCTRichTextView

@synthesize text, maxHeight, minHeight, lineHeight, onSizeChange;

+ (BOOL)requiresMainQueueSetup
{
    return true;
}


#pragma mark - Contants


const NSStringDrawingOptions drawOptions = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
const UIViewAnimationOptions viewOptions = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut;


#pragma mark - Lifecycle Methods


- (id)init {
    printf("[RichTextEditor] init!\n");
    if (self = [super init]) {
      self.scrollEnabled = false;
        openTags = [NSMutableArray new];
        nextTags = [NSMutableArray new];
        nextHTML = [NSMutableArray new];
//        maxHeight = 600.0f;
//        minHeight = 100.0f;
//        lineHeight = 22.0f;
//        self.delegate = self;
        [self addKeyboardListener];
    }
    return self;
}

- (void)setAutolayoutItems {
  UILayoutGuide *safeArea = self.superview.safeAreaLayoutGuide;
  
  if (!safeArea.leadingAnchor) return;
  printf("[RV] safeArea: %f", safeArea.leadingAnchor);
  self.translatesAutoresizingMaskIntoConstraints = false;
  
  [NSLayoutConstraint activateConstraints:@[
    [self.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor],
    [self.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor],
    [self.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor],
  ]];
}

- (void)setBounds:(CGRect)bounds {
  [super setBounds:bounds];
  printf("[RV] setBounds called!\n");
}


// take from answer #2
// https://stackoverflow.com/questions/16868117/uitextview-that-expands-to-text-using-auto-layout
- (void)layoutSubviews {
  [super layoutSubviews];
  printf("[RV] layoutSubviews called!\n");
//  if (CGSizeEqualToSize(self.bounds.size, [self intrinsicContentSize])) {
//    [self invalidateIntrinsicContentSize];
//  }
}

- (CGSize)intrinsicContentSize
{
  printf("[RV] intrinsicContentSize called!\n");
  CGSize intrinsicContentSize = self.contentSize;
  intrinsicContentSize.width += (self.textContainerInset.left + self.textContainerInset.right ) / 2.0f;
  intrinsicContentSize.height += (self.textContainerInset.top + self.textContainerInset.bottom) / 2.0f;
//  self.onSizeChange(@{ @"height": @(intrinsicContentSize.height) });
  return intrinsicContentSize;
}

- (BOOL)autoresizesSubviews {
    return true;
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//}

- (void)addKeyboardListener {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardWillChange:(NSNotification *)notification {
    keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    printf("[RichTextEditor] keyboard will change: %f\n", keyboardFrame.size.height);
}

#pragma mark - Property Methods

// Set text is a property method that is executed each time we modify the text string for this class, since the text
// attribute is export to JS as a prop of this class, we need to convert the given string into the attributed string
// in order to be parsed with the rich text elements.

- (NSMutableAttributedString *)stringFromHTML:(NSString *)html {
  NSData *data = [html dataUsingEncoding:NSUnicodeStringEncoding];
  NSDictionary *options = @{
    NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
    NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding),
  };
  
//  NSDictionary *attributes = @{
//    NSFontAttributeName: [UIFont systemFontOfSize:18.0]
//  };
  
  
  NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithData:data options:options documentAttributes:nil error:nil];
      
  return attrString;
}


// use this method to set the font, attributes, etc.
- (void)setText:(NSString *)text {
  NSMutableAttributedString *attrString = [self stringFromHTML:text];
  UIFont *font = [UIFont systemFontOfSize:17.0];
  NSRange range = NSMakeRange(0, attrString.length);
  NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
  [attrString addAttributes:attrsDictionary range:range];
  self.attributedText = attrString;
  printf("[RichTextEditor] setting string: %s\n", [attrString.string cStringUsingEncoding:NSUTF8StringEncoding]);
  [self calculateSize];
}

- (NSAttributedString *)trim:(NSAttributedString *)originalString {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:originalString];
    while ([attributedString.string length] > 0
           && [[attributedString.string substringFromIndex:[attributedString.string length] - 1] rangeOfCharacterFromSet:NSCharacterSet.newlineCharacterSet].location != NSNotFound)
    {
        [attributedString deleteCharactersInRange:NSMakeRange([attributedString length] - 1, 1)];
    }
    return attributedString;
}

- (CGRect)calculateSize {
//    CGRect oldFrame = self.frame;
//    CGFloat oldWidth = oldFrame.size.width;
//    CGFloat newHeight = MIN(lineHeight * floor((self.contentSize.height / lineHeight) + 0.5), maxHeight);
//    CGFloat heightChange = newHeight - oldFrame.size.height;
//    CGRect nextFrame = CGRectMake(0, oldFrame.origin.y - heightChange, oldWidth, newHeight);
//    if (newHeight < minHeight) return oldFrame;
//    [UIView animateWithDuration:0.1 delay:0.0 options:viewOptions animations:^{
//        [self setFrame:nextFrame];
//        [self layoutIfNeeded];
//        [self layoutSubviews];
//    } completion:^(BOOL finished) {
//        [self layoutIfNeeded];
//        [self layoutSubviews];
//    }];
  
  
  printf("[RCTRichTextView] height: %f\n", self.frame.size.height);
  printf("[RCTRichTextView] content height: %f\n", self.contentSize.height);
  
  
    return self.frame;
}

- (NSNumber *)height {
  return @(self.contentSize.height);
}


- (void)insertTag:(NSString *)tag {
    NSRange range = self.selectedRange;
    //RCTLogInfo(@"[RichTextEditor] selected start: %lu length: %lu total length: %lu", range.location, range.length, self.attributedText.length);
    NSAttributedString *firstHalf = [self.attributedText attributedSubstringFromRange:NSMakeRange(0, range.location)];
    //RCTLogInfo(@"[RichTextEditor] first half: %@", firstHalf);
    NSAttributedString *midHalf = [self.attributedText attributedSubstringFromRange:range];
    //RCTLogInfo(@"[RichTextEditor] mid half: %@", midHalf);
    NSInteger selection = range.location + range.length;
    NSInteger endlength = self.attributedText.length - selection;
    NSAttributedString *lastHalf  = [self.attributedText attributedSubstringFromRange:NSMakeRange(selection, endlength)];
    //RCTLogInfo(@"[RichTextEditor] last half: %@", lastHalf);
    //NSAttributedString *middle = [self stringFromHTML:tag];
    NSMutableAttributedString *combinedString = [NSMutableAttributedString new];
    [combinedString appendAttributedString:firstHalf];
    [combinedString appendAttributedString:[self addAttribute:midHalf fromTag:tag]];
    [combinedString appendAttributedString:lastHalf];
    self.attributedText = combinedString.copy;
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


#pragma mark - Generating Output HTML


- (void)getHTMLString {
    //RCTLogInfo(@"[RichTextEditor] attributed string: %@", self.attributedText);
    NSError *error;
    NSRange range = NSMakeRange(0, self.attributedText.length);
    NSDictionary *dict = @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType };
    NSData *data = [self.attributedText dataFromRange:range documentAttributes:dict error:&error];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //RCTLogInfo(@"[RichTextEditor] string: %@", string);
}

- (NSString *)generateHTML {
    htmlString = [NSMutableString stringWithString:@"<p>"];
    NSRange range = NSMakeRange(0, self.attributedText.length);
    [self.attributedText enumerateAttributesInRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:
     ^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        NSString *text = [self.attributedText.string substringWithRange:range];
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


#pragma mark - Delegate Methods


- (void)textViewDidEndEditing:(UITextView *)textView {
    [self generateHTML];
    //[self animateTextField:false];
}

- (void)textViewDidChange:(UITextView *)textView {
    // [self generateHTML];
    [self calculateSize];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    //[self animateTextField:true];
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

- (void)getAttributesInRange:(NSRange)range {
    selectedAttr = [NSMutableDictionary new];
    [selectedAttr setObject:@(true) forKey:@"isBold"];
    [selectedAttr setObject:@(true) forKey:@"isItalic"];
    [selectedAttr setObject:@(true) forKey:@"isStrikethrough"];
    [selectedAttr setObject:@(true) forKey:@"isSuperscript"];
    [selectedAttr setObject:@(true) forKey:@"isSubscript"];
    [selectedAttr setObject:@(true) forKey:@"isCode"];
    [selectedAttr setObject:@(true) forKey:@"isMarked"];
    [self.attributedText enumerateAttributesInRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        UIFont *font = [attrs objectForKey:NSFontAttributeName];
        UIFontDescriptor *fontDescriptor = font.fontDescriptor;
        UIFontDescriptorSymbolicTraits traits = fontDescriptor.symbolicTraits;
        if (![self isFontBold:traits]) [selectedAttr setObject:@(false) forKey:@"isBold"];
        if (![self isFontItalic:traits]) [selectedAttr setObject:@(false) forKey:@"isItalic"];
        if (![self isFontStrikethrough:attrs]) [selectedAttr setObject:@(false) forKey:@"isStrikethrough"];
        if (![self isFontSubscript:attrs]) [selectedAttr setObject:@(false) forKey:@"isSubscript"];
        if (![self isFontSuperscript:attrs]) [selectedAttr setObject:@(false) forKey:@"isSuperscript"];
        if (![self isFontInserted:attrs]) [selectedAttr setObject:@(false) forKey:@"isInserted"];
        
        // these two should be rendered seperatly
        if (![self isFontCode:attrs]) [selectedAttr setObject:@(false) forKey:@"isCode"];
        if (![self isFontMarked:attrs]) [selectedAttr setObject:@(false) forKey:@"isMarked"];
    }];
}


-(void)animateTextField:(BOOL)up
{
    //RCTLogInfo(@"[RichTextEditor] animate text field called!");
  printf("[RV] animate text view called!");
  const int movementDistance = -keyboardFrame.size.height; // tweak as needed
  const float movementDuration = 0.3f; // tweak as needed
  int movement = (up ? movementDistance : -movementDistance);
  [UIView beginAnimations: @"animateTextField" context: nil];
  [UIView setAnimationBeginsFromCurrentState: YES];
  [UIView setAnimationDuration: movementDuration];
  self.frame = CGRectOffset(self.frame, 0, movement);
  [UIView commitAnimations];
}


#pragma mark - Helper Methods


// This helper methods converts a given tag into the cooresponding mathcing tag
// for example it will convert the tag <strong> to </strong>
NSString * closeTag(NSString *tag) {
    return [NSString stringWithFormat:@"</%@",[tag substringFromIndex:1]];
}


// This helper method checks if a given string exists on a given array, and returns
// true if found or false if not found.
BOOL isFound(NSString *item, NSArray *array) {
    for (NSString *tag in array) {
        if ([item isEqualToString:tag])
            return true;
    } return false;
}

// Helper function for formatting arrays as strings
NSString *ap(NSArray *array)
{
    return [NSString stringWithFormat:@"[ %@ ]", [array componentsJoinedByString:@", "]];
}

// Helper function for printing frames
NSString *fp(CGRect r)
{
    return [NSString stringWithFormat:@"( x:%f, y:%f w:%f h:%f )",r.origin.x, r.origin.y, r.size.width, r.size.height];
}

#pragma mark - Checking Attributes


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


@end
