/**
 * This function tags an array of parsed elements which denote opening tags, closing tags, and text.
 * Output will be a string of generated HTML based on the tags.
 * 
 * Algorithm works by taking the first element and checking the type:
 * 
 *  - If the element is an openeing tag it will append to the html and add to the open tags stack.
 * 
 *  - If the element is a value, then it is added to the current string and the function is called again.
 * 
 *  - If the element is a closing tag, then it will pop the last open tag from the stack and append the closing tag to the html.
 */
export function buildPadletHtml(elements: ParseElement[]) {
  const openTagStack: string[] = []
  const generatedHtml = elements.reduce((html, element) => {
    switch (element.kind) {
      case 'value':
        return html.concat(element.item)

      case 'start':
        const openingTag = `<${element.item}>`
        openTagStack.push(openingTag)
        return html.concat(openingTag)

      case 'close':
        const closingTag = openTagStack.pop()!
        return html.concat(closingTag.replace("<", "</"))
    }
  }, "")

  // close any remaining open tags by popping from the stack.
  return openTagStack.reduceRight((html, openingTag) => {
    return html.concat(openingTag.replace("<", "</"))
  }, generatedHtml)  
}
