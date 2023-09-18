//
//  HTMLDocumentTree.h
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/31/23.
//

#import <Foundation/Foundation.h>

@interface HTMLDocumentTree : NSObject

@property (strong, nonatomic) NSMutableArray<HTMLDocumentTree *> *children;
@property (strong, nonatomic) NSArray<NSString *> *styles;
@property (strong, nonatomic) NSArray<NSString *> *blocks;
@property (strong, nonatomic) NSAttributedString *current;
@property (assign, nonatomic) BOOL isRoot;

+ (HTMLDocumentTree *)createRoot;
+ (HTMLDocumentTree *)createNode:(NSAttributedString *)attributedString;
+ (HTMLDocumentTree *)createTree:(NSAttributedString *)attributedString;

- (BOOL)insert:(HTMLDocumentTree *)nextElement;
- (NSArray<NSString *> *)html;
- (NSString *)htmlString;

@end

