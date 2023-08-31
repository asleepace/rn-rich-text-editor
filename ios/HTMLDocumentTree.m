//
//  HTMLDocumentTree.m
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/31/23.
//

#import "HTMLDocumentTree.h"
#import "NSAttributedString+HTMLElements.h"

@interface HTMLDocumentTree()


@property (strong, nonatomic) NSMutableArray<HTMLDocumentTree *> *children;

@end

@implementation HTMLDocumentTree

@synthesize styles;

// convenience method which returns a blank node, which can be used as the root node.
// Note: there is nothing special about the root node.
+ (HTMLDocumentTree *)createRoot {
  NSAttributedString *blankString = [[NSAttributedString alloc] initWithString:@""];
  return [[HTMLDocumentTree alloc] initWithAttributedString:blankString];
}

+ (HTMLDocumentTree *)createNode:(NSAttributedString *)attributedString {
  return [[HTMLDocumentTree alloc] initWithAttributedString:attributedString];
}

- (id)initWithAttributedString:(NSAttributedString *)attributedString {
  if (self = [super init]) {
    self.children = [NSMutableArray new];
    self.current = attributedString;
    self.styles = [attributedString styles];
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
  
  // start array with open element tags (aka styles)
  NSMutableArray<NSString *> *generatedHtml = [NSMutableArray arrayWithArray:self.styles];
  
  // append current plain text string
  [generatedHtml addObject:self.current.string];
  
  // append all children html elements
  for (HTMLDocumentTree *childElement in self.children) {
    [generatedHtml addObjectsFromArray:[childElement html]];
  }
  
  // append all closing tags
  NSRange firstCharRange = NSMakeRange(0, 1);
  for (NSString *style in self.styles) {
    NSString *closingTag = [style stringByReplacingCharactersInRange:firstCharRange withString:@"</"];
    [generatedHtml addObject:closingTag];
  }
  
  // output: [openTags, currentHtml, childrenHtml, closingTags]
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


- (BOOL)hasCommonStyleWith:(HTMLDocumentTree *)childElement {
  for (NSString *parentStyle in self.styles) {
    if (![childElement.styles containsObject:parentStyle]) {
      return false;
    }
  }
  return true;
}


@end
