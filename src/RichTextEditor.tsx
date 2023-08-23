import React, { SyntheticEvent } from 'react';
import ReactNative, {
  Animated,
  NativeModules,
  StyleProp,
  StyleSheet,
  UIManager,
  ViewStyle,
  requireNativeComponent
} from 'react-native';

import { SampleText, styleText } from './utils';

const NATIVE_NAME = 'RCTRichTextView';
const RCTRichTextView = requireNativeComponent(NATIVE_NAME);

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

  const heightRef = React.useRef(new Animated.Value(0))
  const nativeRef = React.useRef<any>(null)

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

  console.log('[RichTextEditor] render:', heightRef.current)


  return (
    <RCTRichTextView
      ref={nativeRef}
      style={{ flex: 1 }}
      onLayout={(event) => {
        console.log('[RichTextEditor] on layout: ', event.nativeEvent.layout.height)
      }}

      onSizeChange={({ nativeEvent}) => {
        console.log('[RichTextEditor] on height change: ', nativeEvent)
        if (!heightRef.current) return

        // Animated.timing(heightRef.current, {
        //   toValue: nativeEvent.height,
        //   duration: 0,
        //   useNativeDriver: false,
        // }).start()
      }}
      // onSelection={onSelection}
      text={styleText(SampleText)}
      textStyle={{
        fontSize: 16.0,
        fontFamily: 'Roboto',
      }}
    />
  )
})

export { RichTextEditor };

const styles = StyleSheet.create({
  editor: {
    backgroundColor: 'red',
    fontSize: 18.0,
    color: '#111',
    flexGrow: 1,
    flex: 1,
  },
});
