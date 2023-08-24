import React from 'react';
import { Button, InputAccessoryView, ScrollView, StyleSheet, View } from 'react-native';
import { RichTextEditor } from './RichTextEditor';

interface ButtonListProps {
  insert: (tag: string) => void;
  getHTML: () => void;
}

function ButtonList({ insert, getHTML }: ButtonListProps) {
  return (
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
  )
}

export function TextEditor() {

  const editorRef = React.useRef<RichTextEditor>(null)

  const insert = React.useCallback((tag: string) => {
    editorRef?.current?.insertTag?.(tag)
  }, [editorRef])

  const getHTML = React.useCallback(() => {
    editorRef?.current?.getHTML?.()
  }, [editorRef])

  return (
    <View style={styles.overlay}>
      <InputAccessoryView>
        <View style={styles.editor}>
          <RichTextEditor ref={editorRef} />
        </View>
        <ButtonList insert={insert} getHTML={getHTML} />
      </InputAccessoryView>
      <View style={styles.bottom} />
    </View>
  );
}

const styles = StyleSheet.create({
  editor: {
    justifyContent: 'flex-end',
    backgroundColor: 'white',
    borderTopLeftRadius: 16,
    borderTopRightRadius: 16,
    // backgroundColor: "white",
    fontFamily: 'Roboto',
    minHeight: 60,
    // flexGrow: 1,
    flexShrink: 1,
    padding: 8,
  },
  overlay: {
    position: 'absolute',
    left: 0, right:0, top: 0, bottom: 0,
    backgroundColor: '#333',
    justifyContent: 'flex-end',
    flex: 1,
  },
  button :{
    maxHeight: 60,
    backgroundColor: '#F2F2F7',
    flexDirection: 'row',
    flexShrink: 1,
    padding: 8,
  },
  bottom: {
    // flex: 1, 
    // flexGrow: 1,
    minHeight:44, 
    backgroundColor: '#DDD'
  }
});