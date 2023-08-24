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
}

@property (strong, nonatomic) UITextView *textView;

@end

@implementation RNRichTextView

@synthesize textView, onSizeChange;

RCT_EXPORT_MODULE()


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

- (BOOL)autoresizesSubviews {
  return true;
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
  if (lastReportedSize.height == updatedFrame.size.height) {
    return;
  }
  
  // update the container views frame
  lastReportedSize = updatedFrame.size;
  self.frame = updatedFrame;
  
  // report size changes to react-native
  [self.delegate didUpdate:updatedFrame.size on:self];
  
  // report size changes to JS
  self.onSizeChange(@{ @"height": @(updatedFrame.size.height) });
  
  // may help with animations
  [UIView animateWithDuration:0.01 animations:^{
    [self layoutIfNeeded];
  }];
}

#pragma mark - UITextView Delegate Methods

// most important method for reporting size changes to react-native
- (void)textViewDidChange:(UITextView *)textView {
  [self reportSize:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  [self reportSize:textView];
}


@end
