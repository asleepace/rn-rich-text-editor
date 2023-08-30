export type ParseElement = {
  item: string
  kind: 'value' | 'start' | 'close'
}

// regex will match everything between < and >, including the brackets
const regex = /<([^>]*)>/g;

const BODY_START = "body"
const BODY_CLOSE = "/body"

function toStyle(opening: string) {
  return opening.replace(" class=\"", ".").replace("\"","")
}

function checkIfElementIsBracket(index: number, body: string[]) {
  if (index >= body.length) return false
  if (index < 0) return false
  if (body[index] === "") return true
  if (body[index] === '\n') return true
  return false
}

/**
 * This method takes a string of HTML generated by Cocoa (iOS) and parses it into an array of elements,
 * which can then be reconstructed with the buildPadletHtml function.
 */
export function parseCocoaHtml(htmlString: string) {

  // split the string into an array of strings and tags
  const splits: string[] = htmlString.split(regex)

  // find the starting and closing index of the body
  const bodyStartIndex = splits.indexOf(BODY_START)
  const bodyCloseIndex = splits.indexOf(BODY_CLOSE)

  // extract only the body html elements (start + 1)
  const body = splits.slice(bodyStartIndex + 1, bodyCloseIndex)

  // convert elements into parsed syntax
  return body.reduce((tree, item, index) => {

    if (item === "") return tree  // skip if empty element

    // check if the next or previous element is a bracket
    const isPrevElementBracket = checkIfElementIsBracket(index - 1, body)
    const isNextElementBracket = checkIfElementIsBracket(index + 1, body)

    if (isPrevElementBracket) {
      tree.push({ item: toStyle(item), kind: 'start' })

    } else if (isNextElementBracket) {
      tree.push({ item, kind: 'close' })

    } else {
      tree.push({ item, kind: 'start' })
    }

    return tree

  }, [] as ParseElement[])
}

// function convertBodyToHTML(htmlString: string, cssMaping: Record<string, string>) {
//   const regex = /<([^>]*)>/g;
//   const splits: string[] = output.split(regex)
//   const startOfBody = splits.indexOf("body") + 1
//   const endOfBody = splits.indexOf("/body")
//   const body = splits.slice(startOfBody, endOfBody)

//   const tags: ParseElement[] = []

//   const toStyle = (opening: string) => {
//     const [parent, child] = opening.replace(/"/g, "").split(" class=")
//     return [parent, child].join(".")
//   }

//   const isElementBracket = (index: number): boolean => {
//     if (index < 0) return false
//     if (index >= body.length) return false
//     const e = body[index]
//     return e === "" || e === '\n' // TODO: test this?
//   }

//   for (let i=0; i<body.length; i++) {
//     const element = body[i]

//     // skip blank elements
//     if (element === "") continue

//     const isPrevElementBracket = isElementBracket(i - 1)
//     const isNextElementBracket = isElementBracket(i + 1)

//     // element is opening tag
//     if (isPrevElementBracket && element.includes(" class=")) {
//       const openingTag = toStyle(element)
//       tags.push({ item: openingTag, kind: 'start' })
//       continue
//     }

//     // element is closing tag
//     if (isNextElementBracket && element.includes("/")) {
//       tags.push({ item: element, kind: 'close' })
//       continue
//     }

//     // element is regular text
//     tags.push({ item: element, kind: 'value' })
//   }

//   return tags
// }