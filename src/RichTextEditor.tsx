import React, { SyntheticEvent, useEffect } from 'react';
import ReactNative, {
  Animated,
  NativeModules,
  StyleProp,
  StyleSheet,
  UIManager,
  ViewStyle,
  requireNativeComponent,
  View,
  NativeSyntheticEvent
} from 'react-native';

const NATIVE_NAME = 'RNRichTextView';
const RNRichTextView = requireNativeComponent<RichTextEditor>(NATIVE_NAME);

export type RichTextEditorRef = {
  insertTag(tag: string): void;
  showKeyboard(): void;
  hideKeyboard(): void;
  getHTML(): string;
}

export type RichTextEditor = {
  onSizeChange?: (event: NativeSyntheticEvent<{ height: number }>) => void;
  style?: StyleProp<ViewStyle>;
  ref: React.RefObject<{}>;
  editable?: boolean;
  html?: string
}

export const RichTextEditor = React.forwardRef((props: any, ref) => {

  const nativeRef = React.useRef(null)
  const [height, setHeight] = React.useState(44)
  const [didResize, setDidResize] = React.useState(false)

  const shouldResize = React.useCallback(() => {
    if (!nativeRef.current) return
    if (didResize) return
    const current = ReactNative.findNodeHandle(nativeRef.current)
    NativeModules.RNRichTextViewManager.resize(current)
    console.log('[JW] resize called!')
  }, [nativeRef.current, didResize, setDidResize])

  // initialize refs
  useEffect(() => {
    if (didResize) return
    setTimeout(shouldResize, 100)
  }, [shouldResize, didResize])

  // callback methods
  const insertTag = React.useCallback((tag: string) => {
    console.log('[RichTextEditor] insert tag called: ', tag)
    UIManager.dispatchViewManagerCommand(
      ReactNative.findNodeHandle(nativeRef.current),
      UIManager.getViewManagerConfig(NATIVE_NAME).Commands.insertTag,
      [tag]
    )
  }, [nativeRef])

  const getHTML = React.useCallback(() => {
    UIManager.dispatchViewManagerCommand(
      ReactNative.findNodeHandle(nativeRef.current),
      UIManager.getViewManagerConfig(NATIVE_NAME).Commands.getHTML,
      []
    )
  }, [nativeRef])

  const onSelection = React.useCallback((data: SyntheticEvent) => {
    console.log('[RichTextEditor] on selection: ', {data})
  }, [])

  React.useImperativeHandle(ref, () => ({
    insertTag,
    getHTML,
  }), [insertTag, getHTML])

  // React.useEffect(() => {
  //   setTimeout(() => {
  //     resize()
  //   }, 100)
  // }, [resize])

  return (
    <RNRichTextView
      ref={nativeRef}
      editable={true}
      style={{ minHeight: 64.0, backgroundColor: 'white' }}
      onSizeChange={(event) => {
        setHeight(event.nativeEvent.height)
      }}
      html={`
        <!doctype html>
        <html>
        <head>
          <style>
            body {

              font-family: -apple-system;
              font-weight: 400;
              line-height: 24px;
              font-size: 16px;
              color: black;
            }

            pre {
              background-color: #F2F2F7;
            }

            code {
              font-family: monospace;
              font-size: 14px;
              line-height: 24px;
              background-color: #F2F2F7;
              border-radius: 4px;
              padding: 8px;
            }

            mark {
              background-color: yellow;
              border-radius: 4px;
              padding: 4px;
            }

            img {
              width: auto;
              height: 120px;
              border-radius: 8px;
              border: 1px solid black;
              aspect-fit: cover;
            }

            p {

            }
          </style>
        </head>
        <body>
          <h1>Native Rich Text Editor</h1>
          <p>This is some pretty cool text which will <b>appear bold</b> and can have <u>underline</u> as well as <mark>marked text</mark> as well as:</p>
          <pre><code>const code = true;</code></pre>
          <br />
          <b>Supported Styles:</b>
          <br />
          <ul>
            <li>Plain text</li>
            <li>Markdown</li>
            <li>HTML</li>
          </ul>
          <br>
          <p>Written in <strike>React</strike> native!</p>
          <br />
          <p style="text-align: center;">
            <img src="https://m.media-amazon.com/images/I/517QJJQCGvL.png" />
          </p>
          <br />
          <i>Yup, that's an <u>inline image</u>!</i>
          <br />
          <b style="color:powderblue;">@asleepace</b>
          <br />
        </body>
        </html>
      `}
      // onLayout={(event) => {
      //   console.log('[RichTextEditor] on layout: ', event.nativeEvent)
      // }}
    />
  )
})
