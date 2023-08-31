//
//  HTMLDocumentTree.m
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/31/23.
//

#import "HTMLDocumentTree.h"

@interface HTMLDocumentTree()


@property (strong, nonatomic) NSMutableArray<HTMLDocumentTree *> *children;

@end

@implementation HTMLDocumentTree

@synthesize styles;

- (id)initWithAttributedString:(NSAttributedString *)attributedString {
  if (self = [super init]) {
    self.children = [NSMutableArray new];
    self.current = attributedString;
    self.styles = [NSArray new];
  }
  return self;
}


#pragma mark - Insertion


- (BOOL)insert:(HTMLDocumentTree *)nextElement {
  
  // check that the child contains all parent styles
  if (![self hasCommonStyleWith:nextElement]) return false;
  
  // try inserting nextElement on the right most child first
  if ([self didInsertOnChild:nextElement]) return true;
  
  // now we insert as a child on this element with only the new styles
  [nextElement removeParentStyles:self.styles];
  
  // append to the children and return true
  [self.children addObject:nextElement];
  
  return true;
}

// helper method which should only be called from the insert() method above.
// will try and insert the next element on the child and return true if succesful.
- (BOOL)didInsertOnChild:(HTMLDocumentTree *)nextElement {
  if (!self.children.lastObject) return false;
  return [self.children.lastObject insert:nextElement];
}


#pragma mark - HTML Generation


- (NSArray<NSString *> *)html {
  
  NSMutableArray<NSString *> *generatedHtml = [NSMutableArray arrayWithArray:self.styles];
  
  [generatedHtml addObject:self.current.string];
  
  for (HTMLDocumentTree *childElement in self.children) {
    [generatedHtml addObjectsFromArray:[childElement html]];
  }
  
  NSRange firstCharRange = NSMakeRange(0, 1);
  for (NSString *style in self.styles) {
    NSString *closingTag = [style stringByReplacingCharactersInRange:firstCharRange withString:@"</"];
    [generatedHtml addObject:closingTag];
  }
  
  return generatedHtml;
}


#pragma mark - Helper Methods


- (void)removeParentStyles:(NSArray<NSString *> *)parentStyles {
  NSMutableArray<NSString *> *newStyles = [NSMutableArray new];
  for (NSString *currentStyles in self.styles) {
    if ([parentStyles containsObject:currentStyles]) continue;
    [newStyles addObject:currentStyles];
  }
  self.styles = newStyles.copy;
}

//- (NSArray<NSString *> *)getNewStylesFromElement:(HTMLDocumentTree *)nextElement {
//  NSMutableArray<NSString *> *newStyles = [NSMutableArray new];
//  for (NSString *childStyle in nextElement.styles) {
//    if (![self.styles containsObject:childStyle]) {
//      [newStyles addObject:childStyle];
//    }
//  }
//  return newStyles;
//}


- (BOOL)hasCommonStyleWith:(HTMLDocumentTree *)childElement {
  for (NSString *parentStyle in self.styles) {
    if (![childElement.styles containsObject:parentStyle]) {
      return false;
    }
  }
  return true;
}


@end
