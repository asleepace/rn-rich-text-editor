//
//  RNStylist.h
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/25/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNStylist : NSObject

@property (strong, nonatomic) NSDictionary *normal;
@property (assign, nonatomic) CGFloat defaultFontSize;

- (id)initWithStyle:(NSString *)css;
- (NSDictionary *)attributesForTag:(NSString *)tag;
- (NSString *)createHtmlDocument:(NSString *)body;

NSString *createHtmlString(NSString *body, NSString *styles);

@end

NS_ASSUME_NONNULL_END
