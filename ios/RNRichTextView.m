//
//  RNRichTextView.m
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/23/23.
//

#import "RNRichTextView.h"
#import "HTMLCoder.h"
#import "RNStylist.h"
#import "RNStyle.h"

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

@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *typingAttributes;
@property (strong, nonatomic) NSAttributedString *attributedString;
@property (strong, nonatomic) UITextView *textView;

@property (strong, nonatomic) HTMLCoder *coder;
@property (strong, nonatomic) RNStylist *stylist;
@property (strong, nonatomic) RNStyle *style;

@end

@implementation RNRichTextView

@synthesize coder, textView, editable, onSizeChange, onChangeText, customStyle, html, attributedString = _attributedString;

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

    // initialize the coder
    self.coder = [[HTMLCoder alloc] init];
    
    // initialize with scroll set to false and frame set to zero
    self.textView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:nil];
    [self.textView setDelegate:self];
    [self addSubview:self.textView];
    [self bringSubviewToFront:self.textView];
    [self.textView setScrollEnabled:false];
    [self.textView setAllowsEditingTextAttributes:true];
    
    // background colors
    [self setBackgroundColor:[UIColor clearColor]];
    [self.textView setBackgroundColor:[UIColor clearColor]];
    [self.textView setTextColor:[UIColor blackColor]];
    
    // this will allow the text view to grow in height
    UILayoutGuide *safeArea = self.safeAreaLayoutGuide;
    self.textView.translatesAutoresizingMaskIntoConstraints = false;
    
    // we can achieve different effects by choosing if we anchor the top or bottom,
    // currently anchoring the top works better as there is a bit of delay when we
    // resize the text.
    [NSLayoutConstraint activateConstraints:@[
      [self.textView.topAnchor constraintEqualToAnchor:safeArea.topAnchor],
      [self.textView.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor],
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


- (void)setCustomStyle:(NSString *)customStyle {
  RCTLogInfo(@"[RNRichTextView] setCustomStyle: %@", customStyle);
  self.stylist = [[RNStylist alloc] initWithStyle:customStyle];
  self.textView.typingAttributes = [self.stylist attributesForTag:@"<p>"]; // TODO: test which tag to insert
  self.style = [RNStyle styleFrom:self.textView.typingAttributes];
}


- (void)didSetProps:(NSArray<NSString *> *)changedProps {
  RCTLogInfo(@"[RNRichTextView] didSetProps: %@", changedProps);
}

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



#pragma mark - Text & HTML



- (void)setHtml:(NSString *)html {
  RCTLogInfo(@"[RNRichTextView] setHTML: %@", html);
  self.attributedString = [self.coder attributedStringFrom:htmlString];
  NSDictionary *attributes = [self.stylist attributesForTag:@"<body>"];
  [self.textView setTypingAttributes:attributes];
}



- (NSString *)generateHTML {
  return [self.coder htmlFrom:self.attributedString];
}



#pragma mark - Attributed String



- (void)setAttributedString:(NSAttributedString *)attributedString {
  RCTLogInfo(@"[RNRichTextEditor] setting attributed string...");
  self.textView.attributedText = attributedString;
  [self resize];
}

- (NSAttributedString *)attributedString {
  NSAttributedString *current = self.textView.attributedText;
  RCTLogInfo(@"[RNRichTextEditor] getting attributed string: %@", current.string);
  return current;
}




#pragma mark - Dynamic Sizing



// this method will call the reportSize method with the current textView, and will trigger after  the
// next run loop has occurred.
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
}



#pragma mark - UITextView Delegate Methods


// most important method for reporting size changes to react-native
- (void)textViewDidChange:(UITextView *)textView {
  [self reportSize:textView];
  [self notifyChangeListeners];
  RNStyle *style = [RNStyle styleFrom:self.textView.typingAttributes];
  RCTLogInfo(@"[RNRichTextView] typing attributes: %@", [style toDictionary]);
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  [self reportSize:textView];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
  RCTLogInfo(@"[RNRichTextView] textViewDidBeginEditing...");
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
  RNStyle *style = [RNStyle styleFrom:self.textView.typingAttributes];
  RCTLogInfo(@"[RNRichTextView] typing attributes: %@", [style toDictionary]);
}

- (void)notifyChangeListeners {
  NSString *currentText = self.textView.attributedText.string;
  self.onChangeText(@{ @"text": currentText ? currentText : @"" });
}



#pragma mark - Inserting Tags



- (void)insertTag:(NSString *)tag {
  RCTLogInfo(@"[RNRichTextView] inserting tag: %@", tag);
}







@end
