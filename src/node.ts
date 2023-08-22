
const ROOT = 0b1111
const PLAIN = 0b0001
const BOLD  = 0b0010
const ITALIC = 0b0100
const LINE = 0b1000


class HTMLNode {

  constructor(
    public html: string,
    public tags: number,
    public children: HTMLNode[] = []
  ) {}


  getLastChild(): HTMLNode | undefined {
    if (this.children.length === 0) return undefined
    const lastIndex = this.children.length - 1
    return this.children[lastIndex]
  }

  append(html: string, tags: number): boolean {

    // check if tags match, otherwise return false
    const doTagsMatch = (this.tags & tags) !== 0
    console.log(`[i] "${this.html}" do tags match "${html}": ${doTagsMatch}`)
    if (doTagsMatch === false) return false


    // check if can append on the last child
    const didAppendOnChild = this.getLastChild()?.append(html, tags)
    console.log(`[i] "${this.html}" didAppendOnChild: ${didAppendOnChild}`)
    if (didAppendOnChild) return true

    // otherwise add as new child
    console.log(`[i] "${this.html}" adding child "${html}"`)
    const node = new HTMLNode(html, tags)
    this.children.push(node)
    return true
  }

  getClosingTag(): string {
    return this.html.startsWith("<") ? "</" + this.html.substring(1) : ""
  }

  print(): string {
    const str = this.children.reduce((val, child) => val + child.print(), this.html)
    return str + this.getClosingTag()
  }

}


// test cases 
console.clear()

const root = new HTMLNode("<body>", ROOT)
root.append("<p>", PLAIN)
root.append("This is a text block ", PLAIN)
root.append("<b>", BOLD | PLAIN)
root.append("with bold text ", BOLD | PLAIN)
root.append("that can be switch back", PLAIN)

console.log(root)
console.log(root.print())