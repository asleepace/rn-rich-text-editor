console.clear()

const output =
`<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Content-Style-Type" content="text/css">
<title></title>
<meta name="Generator" content="Cocoa HTML Writer">
<style type="text/css">
p.p1 {margin: 0.0px 0.0px 16.0px 0.0px; line-height: 24.0px; font: 16.0px '.AppleSystemUIFont'; color: #000000; -webkit-text-stroke: #000000}
span.s1 {font-family: '.SFUI-Regular'; font-weight: normal; font-style: normal; font-size: 16.00px; font-kerning: none}
span.s2 {font-family: '.SFUI-Bold'; font-weight: bold; font-style: normal; font-size: 16.00px; font-kerning: none}
span.s3 {font-family: '.SFUI-RegularItalic'; font-weight: normal; font-style: italic; font-size: 16.00px; font-kerning: none}
</style>
</head>
<body>
<p class="p1"><span class="s1">Hello, world </span><span class="s2">this is bold</span><span class="s1"> and this is </span><span class="s3">italic</span></p>
</body>
</html>`;

function extractStylesFromDocument(doc: string) {
  const result = doc.match(/<style[^>]*>([\s\S]*?)<\/style>/)
  if (!result?.length) throw Error("invalid regex") 
  const [_, styleString] = result
  const styleItems = styleString.trim().split('\n')
  const styles = styleItems.reduce((css, line) => {
    const [name, attributes] = line.replace("}","").split(" {")
    css[name] = attributes.split(";").reduce((prev, curr) => {
      const [key, value] = curr.split(": ")
      prev[key.trim()] = value.trim()
      return prev
    }, {} as Record<string, string>)
    return css
  }, {} as Record<string, any>)
  console.log(styles)
  return styles
}

const styles = extractStylesFromDocument(output)


type ParseElement = {
  item: string
  kind: 'value' | 'start' | 'close'
}


function convertBodyToHTML(htmlString: string, cssMaping: Record<string, string>) {
  const regex = /<([^>]*)>/g;
  const splits: string[] = output.split(regex)
  const startOfBody = splits.indexOf("body") + 1
  const endOfBody = splits.indexOf("/body")
  const body = splits.slice(startOfBody, endOfBody)

  const tags: ParseElement[] = []

  const toStyle = (opening: string) => {
    const [parent, child] = opening.replace(/"/g, "").split(" class=")
    console.log({ parent, child })
    return [parent, child].join(".")
  }

  const isElementBracket = (index: number): boolean => {
    if (index < 0) return false
    if (index >= body.length) return false
    const e = body[index]
    return e === "" || e === '\n' // TODO: test this?
  }

  for (let i=0; i<body.length; i++) {
    const element = body[i]

    // skip blank elements
    if (element === "") continue

    const isPrevElementBracket = isElementBracket(i - 1)
    const isNextElementBracket = isElementBracket(i + 1)

    // element is opening tag
    if (isPrevElementBracket && element.includes(" class=")) {
      const openingTag = toStyle(element)
      tags.push({ item: openingTag, kind: 'start' })
      continue
    }

    // element is closing tag
    if (isNextElementBracket && element.includes("/")) {
      tags.push({ item: element, kind: 'close' })
      continue
    }

    // element is regular text
    tags.push({ item: element, kind: 'value' })
  }

  return tags
}

const test = convertBodyToHTML(output, {})
console.log(test)