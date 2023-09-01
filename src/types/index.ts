

export type ReflexTextAttributes = 'bold' | 'italic' | 'underline' | 'strikethrough' | 'link' | 'code'

export type ReflexElementStyle = {
  attributes: ReflexTextAttributes[]
  fontFamily?: string
  fontWeight?: string
  fontSize?: number
  color?: string
}

export type ReflexEdtiorOptions = {
  autoComplete?: boolean
  autoCapitalize?: boolean
}

export type RichTextActiveAttriubtes = {
  isBold: boolean;
  isItalic: boolean;
  isUnderline: boolean;
  isStrikeThrough: boolean;
  isSubscript: boolean;
  isSuperscript: boolean;
  isMonospace: boolean;
  isMarked: boolean;
  isCode: boolean;
}