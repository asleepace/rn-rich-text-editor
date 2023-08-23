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
  [self.textView setBackgroundColor:[UIColor blueColor]];
  [self addSubview:self.textView];
  [self bringSubviewToFront:self.textView];
  [self.textView setScrollEnabled:false];
  
  UILayoutGuide *safeArea = self.safeAreaLayoutGuide;
  self.textView.translatesAutoresizingMaskIntoConstraints = false;
  
  [NSLayoutConstraint activateConstraints:@[
    [self.textView.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor],
    [self.textView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor],
    [self.textView.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor],
  ]];
  RCTLogInfo(@"[RNRichTextView] initializing textView: %@", self.textView.frame);
}

- (BOOL)autoresizesSubviews {
  return true;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
