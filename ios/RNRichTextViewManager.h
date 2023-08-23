//
//  RNRichTextViewManager.h
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/23/23.
//

#import <Foundation/Foundation.h>
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTBridge.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNRichTextViewManager : RCTViewManager <RCTBridgeModule, UITextViewDelegate>

@end

NS_ASSUME_NONNULL_END
