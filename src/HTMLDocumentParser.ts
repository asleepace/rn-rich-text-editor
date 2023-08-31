/*

<p class="p1">
  <span class="s1">This is some normal text with </span>
    <span class="s2">bold </span>
    <span class="s3">and bolder italics</span>
    <span class="s1"> and back to normal</span>
</p>
*/

console.clear()


type CocoaStyles = '<b>' | '<i>' | '<u>' | '<del>' | '<mark>' | '<li>' | '<code>' | '<body>'

type CocoaString = {
  html: string
  style: CocoaStyles[]
}

// 1. Insertions happen on the right
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

    // try and insert to the right first
    const lastChildIndex = this.children.length - 1
    if (lastChildIndex >= 0) {
      const lastInsertedChild = this.children[lastChildIndex]
      const didInsertOnChild = lastInsertedChild.insert(child)
      if (didInsertOnChild) return true
    }

    // exit if the child not does not has common style ancestors
    if (!this.hasCommonStyleWith(child.style)) return false

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

}



const root = new HTMLDocumentTree({ html: "", style: [] })

console.log(root.insert({ html: "This is a plain text string", style: []  }))

console.log(root)

console.log(root.html())