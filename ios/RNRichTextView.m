//
//  RNRichTextView.m
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/23/23.
//

#import "RNRichTextView.h"

@interface RNRichTextView()

@property (strong, nonatomic) UITextView *textView;

@end

@implementation RNRichTextView

@synthesize textView, onSizeChange;

RCT_EXPORT_MODULE()


+ (BOOL)requiresMainQueueSetup {
  return true;
}

- (void)initializeTextView {
  self.textView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:nil];
  [self.textView setDelegate:self];
  [self setBackgroundColor:[UIColor brownColor]];
//  [self.textView setBackgroundColor:[UIColor yellowColor]];
  [self addSubview:self.textView];
  [self bringSubviewToFront:self.textView];
  [self.textView setScrollEnabled:false];
  
  
  // set up text editor styles
  [self styleAtrributedText];
  [self.textView setFont:[UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular]];
  
  // this will allow the text view to grow in height
  UILayoutGuide *safeArea = self.safeAreaLayoutGuide;
  self.textView.translatesAutoresizingMaskIntoConstraints = false;
  
  // this line might not be needed
  // self.translatesAutoresizingMaskIntoConstraints = false;
  
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

- (void)styleAtrributedText {
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.headIndent = 15; // <--- indention if you need it
  paragraphStyle.firstLineHeadIndent = 15;
  paragraphStyle.lineSpacing = 7; // <--- magic line spacing here!
  NSDictionary *attrsDictionary = @{ NSParagraphStyleAttributeName: paragraphStyle }; // <-- there are many more attrs, e.g NSFontAttributeName
  self.textView.attributedText = [[NSAttributedString alloc] initWithString:@"Hello World over many lines!" attributes:attrsDictionary];
}

- (void)textViewDidChange:(UITextView *)textView {
  CGRect nextFrame = self.frame;
  CGFloat nextHeight = self.textView.frame.size.height + self.textView.contentSize.height;
  self.onSizeChange(@{ @"height": @(nextHeight) });
  nextFrame.size = CGSizeMake(nextFrame.size.width, nextHeight);
  self.frame = nextFrame;
  
  [self.delegate didUpdate:self.frame.size on:self];
}

/*
 Only override drawRect: if you perform custom drawing.
 An empty implementation adversely affects performance during animation.
 */
//- (void)drawRect:(CGRect)rect {
//  RCTLogInfo(@"[RNRichTextView] drawing rect changed: %f", self.frame.size.height);
//}


@end
