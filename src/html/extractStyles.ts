const NEW_LINE = "\n"
const CLOSING_BRACES = "}"
const EMPTY_STRING = ""
const OPENING_BRACES = " {"
const SEMICOLON = ";"

export function extractStyles(htmlDocument: string) {

  const styleBody = htmlDocument.match(/<style[^>]*>([\s\S]*?)<\/style>/)

  if (!styleBody?.length) throw Error("invalid regex") 

  const paragraph = styleBody.pop()!

  const lines = paragraph.trim().split(NEW_LINE)

  const styles = lines.reduce((css, line) => {

    const [name, attributes] = line.replace(CLOSING_BRACES, EMPTY_STRING).split(OPENING_BRACES)

    css[name] = attributes.split(SEMICOLON).reduce((prev, curr) => {

      const [key, value] = curr.split(": ")
      prev[key.trim()] = value.trim()
      return prev

    }, {} as Record<string, string>)

    return css

  }, {} as Record<string, any>)

  console.log(styles)
  return styles
}