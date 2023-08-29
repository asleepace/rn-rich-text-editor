//
//  HTMLCoder.h
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/29/23.
//

#import <Foundation/Foundation.h>
#import "RNStylist.h"
#import "RNStyle.h"

@interface HTMLCoder : NSObject

@property (strong, nonatomic) RNStylist *stylist;

- (NSAttributedString *)attributedStringFrom:(NSString *)html;
- (NSString *)htmlFrom:(NSAttributedString *)attributedString;


@end

