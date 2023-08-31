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
import { convertCocoaHtmlToPadletHtml } from './html';

const NATIVE_NAME = 'RNRichTextView';
const RNRichTextView = requireNativeComponent<RichTextEditor>(NATIVE_NAME);

export type RichTextFont = {
  fontFamily: string;
  
}

export type RichTextEditorRef = {
  insertTag(tag: string): void;
  showKeyboard(): void;
  hideKeyboard(): void;
  getHTML(): string;
}

export type RichTextEditor = {
  onSizeChange?: (event: NativeSyntheticEvent<{ height: number }>) => void;
  onChangeText?: (event: NativeSyntheticEvent<{ text?: string, html?:string }>) => void;
  style?: StyleProp<ViewStyle>;
  ref: React.RefObject<{}>;
  customStyle?: string;
  editable?: boolean;
  html?: string
}

export type RichTextAttriubtes = {
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

export const RichTextEditor = React.forwardRef((props: any, ref) => {

  const nativeRef = React.useRef(null)

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
      editable={true}
      style={{ minHeight: 64.0, backgroundColor: 'white' }}
      onSizeChange={(event) => {
        console.log('[RichTextEditor] on size change: ', event.nativeEvent)
      }}
      onChangeText={({ nativeEvent }) => {
        if (nativeEvent.html) {
          console.log('[RichTextEditor] on change text: ', nativeEvent.html)
          //convertCocoaHtmlToPadletHtml(nativeEvent.html)
        } else {
          console.log(nativeEvent.text)
        }
      }}
      customStyle={`
        body, strong, em, b, i {
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

        strong, b {
          font-family: -apple-system;
          font-weight: bold;
          color: black;
        }

        em, i {
          font-family: -apple-system;
          font-style: italic;
          color: black;
        }

        pdlt-mention {
          color: powderblue;
          font-weight: bold;
        }

        p {
          font-family: -apple-system;
          font-weight: 400;
          line-height: 24px;
          font-size: 16px;
          color: black;
        }

        del {
          
        }

        ins { 

        }

        poem {
          font-family: Chalkduster;
          text-align: center;
        }
      `}
      html={`<p>Hello, world <b>this is bold</b> and this is <i>italic</i></p>`}
      // onLayout={(event) => {
      //   console.log('[RichTextEditor] on layout: ', event.nativeEvent)
      // }}
    />
  )
})
