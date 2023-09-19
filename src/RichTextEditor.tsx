import React, { forwardRef, useImperativeHandle, useRef } from 'react';
import {
  NativeSyntheticEvent,
  StyleProp,
  UIManager,
  ViewStyle,
  findNodeHandle,
  requireNativeComponent
} from 'react-native';
import { ActiveStyles } from './ButtonList';
import { CSSStyles } from './styles';

export type RichTextFont = {
  fontFamily: string; 
}

export type RichTextEditorRef = {
  insertHtml(html: string): void;
  insertTag(tag: string): void;
  showKeyboard(): void;
  hideKeyboard(): void;
  generateHtml(): string;
}

export type RichTextEditor = {
  onChangeStyle?:(event: NativeSyntheticEvent<{ active: ActiveStyles }>) => void;
  onSizeChange?: (event: NativeSyntheticEvent<{ height: number }>) => void;
  onChangeText?: (event: NativeSyntheticEvent<{ text?: string, html?:string }>) => void;
  style?: StyleProp<ViewStyle>;
  ref: React.RefObject<{}>;
  customStyle?: string;
  editable?: boolean;
  html?: string
}

export type RichTextEditorProps = {
  onChangeStyle(active: ActiveStyles): void
}

// access native component by name (manager is automatically appended)
const NativeComponent = 'RNRichTextView';
const RNRichTextView = requireNativeComponent<RichTextEditor>(NativeComponent);

// allows javascript to call native methods on the component via a ref
const { dispatchViewManagerCommand, getViewManagerConfig } = UIManager;
const { Commands } = getViewManagerConfig(NativeComponent);


export const RichTextEditor = forwardRef((props: RichTextEditorProps, ref) => {

  // access native component
  const editor = useRef(null)

  // expose methods to outside classes
  useImperativeHandle(ref, () => ({
    insertTag(tag: string) {
      dispatchViewManagerCommand(findNodeHandle(editor.current), Commands.insertTag, [tag])
    },
    generateHtml() {
      console.log('[RichTextEditor] generate html called:', Commands)
      dispatchViewManagerCommand(findNodeHandle(editor.current), Commands.generateHtml)
    },
    insertHtml(html: string) {
      dispatchViewManagerCommand(findNodeHandle(editor.current), Commands.insertHtml, [html])
    }
  }), [])


  return (
    <RNRichTextView
      html={
        `<p>This is an example of a list with <strong>bold elements </strong>along with some <em>italic text </em>and some other items.</p><p>This is a single new line sentence.</p><p><br></p><p>This is a <mark>double</mark> newline line sentence which should have several break before the next list item.</p><p><br></p><ul><li><p>This is the first element</p></li><li><p>This is the <strong>bold</strong> <em>element</em></p></li><li><p><em>This is the continued list</em></p></li></ul><p><br></p><p>This is some text after the list!</p></p>`
      }
      ref={editor}
      editable={true}
      customStyle={CSSStyles}
      style={{ minHeight: 64.0, backgroundColor: 'white' }}
      onChangeStyle={({ nativeEvent }) => {
        console.log('[RichTextEditor] on change style: ', nativeEvent.active)
        props.onChangeStyle(nativeEvent.active)
      }}
      onSizeChange={({ nativeEvent }) => {
        console.log('[RichTextEditor] on size change: ', nativeEvent)
      }}
      onChangeText={({ nativeEvent }) => {
        console.log('[RichTextEditor] on change text: ', nativeEvent.html)
      }}
    />
  )
})
