import { buildPadletHtml } from "./buildPadletHtml";
import { extractStyles } from "./extractStyles";
import { parseCocoaHtml } from "./parseCocoaHtml";

export function convertCocoaHtmlToPadletHtml(htmlString: string) {
  const parsedElements = parseCocoaHtml(htmlString)
  const generatedHtml = buildPadletHtml(parsedElements)
  return generatedHtml
}