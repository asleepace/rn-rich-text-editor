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
export function buildPadletHtml(elements: ParseElement[]) {
  const openTagsStack: string[] = []
  const generatedHtml = elements.reduce((html, element) => {
    switch (element.kind) {
      case 'value':
        return html.concat(element.item)

      case 'start':
        const tag = `<${element.item}>`
        openTagsStack.push(tag)
        return html.concat(tag)

      case 'close':
        const closingTag = openTagsStack.pop()!
        return html.concat(closingTag.replace("<", "</"))
    }
  }, "")

  // close any remaining open tags by popping from the stack.
  return openTagsStack.reduceRight((html, openingTag) => {
    return html.concat(openingTag.replace("<", "</"))
  }, generatedHtml)  
}
