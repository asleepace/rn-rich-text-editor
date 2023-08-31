//
//  HTMLDocumentTree.m
//  RNRichTextEditor
//
//  Created by Colin Teahan on 8/31/23.
//

#import "HTMLDocumentTree.h"
#import "NSAttributedString+HTMLElements.h"

@interface HTMLDocumentTree()


@end

@implementation HTMLDocumentTree

@synthesize styles;


#pragma mark - Class Methods


//
// convenience method which returns a blank root node.
//
+ (HTMLDocumentTree *)createRoot {
  NSAttributedString *blankString = [[NSAttributedString alloc] initWithString:@"<body>"];
  HTMLDocumentTree *root = [[HTMLDocumentTree alloc] initWithAttributedString:blankString];
  root.isRoot = true;
  return root;
}

//
//  convenience method which creates a new tree node from an attributed string (with one style).
//
+ (HTMLDocumentTree *)createNode:(NSAttributedString *)attributedString {
  return [[HTMLDocumentTree alloc] initWithAttributedString:attributedString];
}

//
//  convenience method which creates a new tree from an attributed string (with many styles).
//
+ (HTMLDocumentTree *)createTree:(NSAttributedString *)attributedString {
  HTMLDocumentTree *root = [HTMLDocumentTree createRoot];
  [attributedString
    enumerateAttributesInRange:NSMakeRange(0, attributedString.length)
                       options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                    usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
    
    NSAttributedString *substring = [attributedString attributedSubstringFromRange:range];
    HTMLDocumentTree *node = [HTMLDocumentTree createNode:substring];
    [root insert:node];
  }];
  
  return root;
}


#pragma mark - Instance Methods


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
  
  // append closing body tag if root
  if (self.isRoot) [generatedHtml addObject:@"</body>"];
  
  return generatedHtml;   // [openTags, currentHtml, childrenHtml, closingTags]
}


- (NSSting *)htmlString {
  return [[self html] componentsJoinedByString:@""];
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
