import { buildPadletHtml } from "./buildPadletHtml";
import { extractStyles } from "./extractStyles";
import { parseCocoaHtml } from "./parseCocoaHtml";

export function convertCocoaHtmlToPadletHtml(htmlString: string) {
  console.log({ htmlString })
  const parsedElements = parseCocoaHtml(htmlString)
  console.log({ parsedElements })
  const generatedHtml = buildPadletHtml(parsedElements)
  console.log({ generatedHtml })
  return generatedHtml
}