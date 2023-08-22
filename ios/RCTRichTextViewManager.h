//
//  RCTRichTextViewManager.h
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/16/23.
//
#import <Foundation/Foundation.h>
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTBridge.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCTRichTextViewManager : RCTViewManager <RCTBridgeModule, UITextViewDelegate>

@end

NS_ASSUME_NONNULL_END
