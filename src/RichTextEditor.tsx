import React, { SyntheticEvent } from 'react';
import ReactNative, {
  NativeModules,
  StyleProp,
  StyleSheet,
  UIManager,
  View,
  ViewStyle,
  requireNativeComponent
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

  // const onLayout = React.useCallback((event: any) => {
  //   console.log('[RichTextEditor] on layout: ', {event});
  // }, [])

  const nativeRef = React.useRef<any>(null)

  const insertTag = React.useCallback((tag: string) => {
    console.log('[RichTextEditor] insert tag called: ', tag)

    const rctRichTextTag = ReactNative.findNodeHandle(nativeRef.current)
    const rctRichTextConfig = UIManager.getViewManagerConfig('RCTRichText')

    console.log('[RCTRichTextConfig] viewTag:', rctRichTextTag)
    console.log('[RCTRichTextConfig] manager:', rctRichTextConfig)

    UIManager.dispatchViewManagerCommand(
      rctRichTextTag,
      rctRichTextConfig.Commands.insertTag,
      [tag]
    )
  }, [nativeRef])

  const getHTML = React.useCallback(() => {
    UIManager.dispatchViewManagerCommand(
      ReactNative.findNodeHandle(nativeRef.current),
      UIManager.getViewManagerConfig('RCTRichText').Commands.getHTML,
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
    <View style={props.style}>
      <RCTRichTextView
        ref={nativeRef}
        style={styles.frame}
        onSelection={onSelection}
        text={styleText(SampleText)}
        textStyle={{
          fontSize: 16.0,
          fontFamily: 'Roboto',
        }}
      />
    </View>
  );
})

export { RichTextEditor };

const styles = StyleSheet.create({
  frame: {
    flex: 1,
    zIndex: 100,
  },
  container :{
    flex: 1,
    zIndex: 100,
    backgroundColor: 'white',
    left: 0,
    right: 0,
    bottom: 0,
    position: 'absolute',
  }
});
