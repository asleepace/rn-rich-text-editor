import { ParseElement } from "./parseCocoaHtml"
/**
 * This function tags an array of parsed elements which denote opening tags, closing tags, and text.
 * Output will be a string of generated HTML based on the tags.
 * 
 * How it works:
 * 
 *  1. Pop the first element from the array.
 * 
 *  2. Check which kind of element it is:
 * 
 *      value: this is a text element, so append it to the current string.
 * 
 *      start: this is an opening tag, so append it to the current string and push on the stack.
 * 
 *      close: this is a closing tag, so pop the stack and append the closing tag to the current string.
 * 
 *  3. Repeat until the array is empty.
 * 
 *  4. Close any remaining open tags by popping from the stack.
 *
 */

class OpenTagsStack {

  constructor(private stack: string[] = []) {}

  push(element: ParseElement): string {
    const tag = `<${element.item}>`
    this.stack.push(tag)
    return tag
  }

  pop(): string {
    const tag = this.stack.pop()
    if (tag === undefined) throw new Error("stack is empty")
    return tag.replace("<", "</")
  }

  closeTag(html: string): string {
    return html.replace("<", "</")
  }

  closeAll(html: string): string {
    return this.stack.reduceRight((html, tag) =>
       html.concat(this.closeTag(tag)
    ), html)
  }
}

export function buildPadletHtml(elements: ParseElement[]) {
  const openTagsStack = new OpenTagsStack()
  const generatedHtml = elements.reduce((html, element) => {
    switch (element.kind) {
      case 'value':
        return html.concat(element.item)

      case 'start':
        const tag = openTagsStack.push(element)
        return html.concat(tag)

      case 'close':
        return html.concat(openTagsStack.pop())
    }
  }, "")

  // close any remaining open tags by popping from the stack.
  return openTagsStack.closeAll(generatedHtml)
}
