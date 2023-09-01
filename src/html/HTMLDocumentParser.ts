/**
 * This is efficetly the same algoithm as the one in HTMLDocumentTree.m (iOS) and isn't currently being used
 */


type CocoaStyles = '<b>' | '<i>' | '<u>' | '<del>' | '<mark>' | '<li>' | '<code>' | '<body>'

type CocoaString = {
  html: string
  style: CocoaStyles[]
}

//
//  1. Insertions happen on the right.
//  2. Child must contain all the styles of the parent.
//  3. Inserted children will only have styles which are not present in the parent.
//
class HTMLDocumentTree {

  constructor(
    private value: CocoaString,
    private styles: CocoaStyles[] = [],
    private children: HTMLDocumentTree[] = []
  ) {}

  // will return true if succeeded, try to insert as far to the
  // right and down as possible first.
  public insert(child: CocoaString): boolean {

    // exit if the child not does not has common style ancestors
    if (!this.hasCommonStyleWith(child.style)) return false

    // try and insert to the right first
    const lastChildIndex = this.children.length - 1
    if (lastChildIndex >= 0) {
      const lastInsertedChild = this.children[lastChildIndex]
      const didInsertOnChild = lastInsertedChild.insert(child)
      if (didInsertOnChild) return true
    }

    // extract only the new styles which are present
    const newStyles = child.style.filter((newStyle) => {
      return this.styles.includes(newStyle) ? undefined : newStyle
    })

    // create the new node and insert as child
    const newNode = new HTMLDocumentTree(child, newStyles)
    this.children.push(newNode)

    return true
  }

  // child styles will always share a common styles with their ancestors,
  // we check if all the styles match
  private hasCommonStyleWith(childStyle: CocoaStyles[]): boolean {
    return this.styles.every(style => childStyle.includes(style))
  }

  public html() {
    const generatedHtml: string[] = []
    const generatedClosingTags = this.styles.map((child) => {
      return "</" + child.slice(1)
    })
    const generatedChildrenHtml = this.children.reduce<string[]>((html, child) =>
       html.concat(child.html()), 
    [])
    generatedHtml.push(...this.styles)
    generatedHtml.push(this.value.html)
    generatedHtml.push(...generatedChildrenHtml)
    generatedHtml.push(...generatedClosingTags)
    return generatedHtml;
  }


  public debugPrint() {
    console.log(`[${this.value.html}] (${this.children.length} children)`)
    this.children.map(c => c.debugPrint())
  }
}