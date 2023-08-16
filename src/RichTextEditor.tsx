import React, { SyntheticEvent } from 'react';
import ReactNative, {
  NativeModules,
  StyleProp,
  StyleSheet,
  ViewStyle,
  requireNativeComponent,
} from 'react-native';

import { SampleText, styleText } from './utils';

const RCTRichTextView = requireNativeComponent<RichTextEditor>('RCTRichText');
const { RCTRichTextManager } = NativeModules;

interface RichTextEditorProps {
  style?: StyleProp<ViewStyle>;
  onSelection?: (data: any) => void;
  ref: React.RefObject<{}>;
}

export type RichTextEditor = {
  insertTag: (tag: string) => void;
  getHTML: () => void;
}

const RichTextEditor = React.forwardRef((props: RichTextEditorProps, ref) => {

  const onLayout = React.useCallback((event: any) => {
    console.log('[RichTextEditor] on layout: ', {event});
  }, [])

  const nativeRef = React.useRef<any>(null)

  const insertTag = React.useCallback((tag: string) => {
    console.log('[RichTextEditor] insert tag called: ', tag)
    console.log('[RichTextEdutor] current tag:', getTag())
    RCTRichTextManager.insertTag(tag, getTag())
  }, [nativeRef])

  const getHTML = React.useCallback(() => {
    RCTRichTextManager.getHTML(getTag())
  }, [nativeRef])

  const getTag = React.useCallback(() => {
    return ReactNative.findNodeHandle(nativeRef.current) // TODO: this is broken :(
  }, [nativeRef])

  const onSelection = React.useCallback((data: SyntheticEvent) => {
    console.log('[RichTextEditor] on selection: ', {data})
  }, [])

  React.useImperativeHandle(ref, () => ({
    insertTag,
    getHTML,
  }), [insertTag, getHTML])

  return (
    <RCTRichTextView
      ref={nativeRef}
      style={[styles.frame, props.style]}
      onSelection={onSelection}
      text={styleText(SampleText)}
      onLayout={onLayout}
      textStyle={{
        fontSize: 16.0,
        fontFamily: 'Roboto',
      }}
    />
  );
})

export { RichTextEditor };

const styles = StyleSheet.create({
  frame: {
    flex: 1,
    zIndex: 100,
  },
  behind: {
    position: 'absolute',
    left: 0,
    right: 0,
    top: -10,
    bottom: 0,
    backgroundColor: 'red',
    zIndex: 99,
    flex: 1,
  },
});
