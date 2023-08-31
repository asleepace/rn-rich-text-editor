//
//  HTMLDocumentTree.h
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/31/23.
//

#import <Foundation/Foundation.h>

@interface HTMLDocumentTree : NSObject

@property (strong, nonatomic) NSArray<NSString *> *styles;
@property (strong, nonatomic) NSAttributedString *current;

- (BOOL)insert:(HTMLDocumentTree *)nextElement;

@end

