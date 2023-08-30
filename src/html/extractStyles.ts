
export function extractStyles(doc: string) {
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