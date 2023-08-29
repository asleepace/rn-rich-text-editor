//
//  RNRichTextViewManager.h
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/23/23.
//

#import "RNRichTextView.h"
#import "RichTextDelegate.h"
#import <Foundation/Foundation.h>
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTBridge.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNRichTextViewManager : RCTViewManager <RCTBridgeModule, RichTextViewDelegate>

@end

NS_ASSUME_NONNULL_END
