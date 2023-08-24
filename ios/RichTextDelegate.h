//
//  RichTextDelegate.h
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/23/23.
//

#import <Foundation/Foundation.h>
#import "RNRichTextView.h"

@protocol RichTextViewDelegate <NSObject>

@required
- (void)didUpdate:(CGSize)size on:(id)view;

@end
