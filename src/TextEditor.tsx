import React from 'react';
import { Button, InputAccessoryView, ScrollView, StyleSheet, View } from 'react-native';
import { RichTextEditor } from './RichTextEditor';

export function TextEditor() {

  const editorRef = React.useRef<RichTextEditor>(null)

  const insert = React.useCallback((tag: string) => {
    editorRef?.current?.insertTag(tag)
  }, [editorRef])

  const getHTML = React.useCallback(() => {
    editorRef?.current?.getHTML()
  }, [editorRef])

  return (
    <View style={styles.overlay}>
      <InputAccessoryView>
        <View style={styles.editor}>
          <RichTextEditor style={styles.editor} ref={editorRef} />
        </View>
        <ScrollView style={styles.button} horizontal={true}>
          <Button title={"Bold"} onPress={() => insert("<b>")} />
          <Button title={"Italic"} onPress={() => insert("<i>")} />
          <Button title={"Strikethrough"} onPress={() => insert("<del>")} />
          <Button title={"Superscript"} onPress={() => insert("<sup>")} />
          <Button title={"Subscript"} onPress={() => insert("<sub>")} />
          <Button title={"Insert"} onPress={() => insert("<ins>")} />
          <Button title={"Mark"} onPress={() => insert("<mark>")} />
          <Button title={"Code"} onPress={() => insert("<code>")} />
          <Button title={"HTML"} onPress={getHTML} />
        </ScrollView>
      </InputAccessoryView>
      <View style={styles.bottom} />
    </View>
  );
}

const styles = StyleSheet.create({
  editor: {
    borderTopLeftRadius: 16,
    borderTopRightRadius: 16,
    backgroundColor: "white",
    fontFamily: 'Roboto',
    minHeight: 120,
    padding: 8,
  },
  overlay: {
    position: 'absolute',
    left: 0, right:0, top: 0, bottom: 0,
    backgroundColor: 'rgba(0,0,0,0.3)'
  },
  button :{
    backgroundColor: '#EEE',
    flexDirection: 'row',
    padding: 8,
  },
  bottom: {
    flex: 1, 
    zIndex: 100, 
    minHeight:100, 
    position: 'absolute',
     bottom: 0, left: 0, right: 0, 
     backgroundColor: '#DDD'
  }
});