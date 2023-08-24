import React, { SyntheticEvent } from 'react';
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

export type RichTextEditor = {
  insertTag?: (tag: string) => void;
  getHTML?: () => void;
  onSizeChange?: (event: NativeSyntheticEvent<{ height: number }>) => void;
  style?: StyleProp<ViewStyle>;
  ref: React.RefObject<{}>;
  html?: string
}

export const RichTextEditor = React.forwardRef((props: any, ref) => {

  const [height, setHeight] = React.useState(44)

  // initialize refs
  const nativeRef = React.useRef<any>(null)

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

  return (
    <RNRichTextView
      ref={nativeRef}
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
            p {

            }
          </style>
        </head>
        <body>
          <p>This is some pretty cool text which will <b>appear bold</b> and can have <em>underline</em></p>
        </body>
        </html>
      `}
      // onLayout={(event) => {
      //   console.log('[RichTextEditor] on layout: ', event.nativeEvent)
      // }}
    />
  )
})
