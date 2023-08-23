//
//  RNRichTextView.m
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/23/23.
//

#import "RNRichTextView.h"

@interface RNRichTextView()
{
  
}

@property (strong, nonatomic) UITextView *textView;

@end

@implementation RNRichTextView

@synthesize textView;

RCT_EXPORT_MODULE()

//- (id)init {
//  RCTLogInfo(@"[RNRichTextView] init called!");
//  if (self = [super init]) {
//    [self initializeTextView];
//    
//  }
//  return self;
//}

+ (BOOL)requiresMainQueueSetup {
  return true;
}

- (void)initializeTextView {
  self.textView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:nil];
  [self.textView setText:@"Hello, world!"];
  [self.textView setBackgroundColor:[UIColor clearColor]];
  [self.textView setFont:[UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular]];
  [self addSubview:self.textView];
  [self bringSubviewToFront:self.textView];
  [self.textView setScrollEnabled:false];
  
  // this will allow the text view to grow in height
  UILayoutGuide *safeArea = self.safeAreaLayoutGuide;
  self.textView.translatesAutoresizingMaskIntoConstraints = false;
  [NSLayoutConstraint activateConstraints:@[
//    [self.textView.topAnchor constraintEqualToAnchor:safeArea.topAnchor],
    [self.textView.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor],
    [self.textView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor],
    [self.textView.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor],
  ]];
}

- (BOOL)autoresizesSubviews {
  return true;
}

- (void)textViewDidChange:(UITextView *)textView {
  [self setNeedsLayout];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
