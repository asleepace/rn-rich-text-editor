//
//  RNDocumentEncoder.h
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/30/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNDocumentEncoder : NSObject

- (id)initWithDocument:(NSAttributedString *)document;
- (NSString *)htmlEncode;
- (void)print;

@end

NS_ASSUME_NONNULL_END
