import React from 'react';
import { Button, InputAccessoryView, ScrollView, StyleSheet, View } from 'react-native';
import { RichTextEditor, RichTextEditorRef } from './RichTextEditor';

interface ButtonListProps {
  insert: (tag: string) => void;
  getHTML: () => void;
}

function ButtonList({ insert, getHTML }: ButtonListProps) {
  return (
    <ScrollView style={styles.button} horizontal={true}>
      <Button title={"B"} onPress={() => insert("<b>")} />
      <Button title={"I"} onPress={() => insert("<i>")} />
      <Button title={"U"} onPress={() => insert("<u>")} />
      <Button title={"S"} onPress={() => insert("<del>")} />
      <Button title={"x²"} onPress={() => insert("<sup>")} />
      <Button title={"x₂"} onPress={() => insert("<sub>")} />
      <Button title={"[]"} onPress={() => insert("<ins>")} />
      <Button title={"H"} onPress={() => insert("<mark>")} />
      <Button title={"</>"} onPress={() => insert("<code>")} />
      <Button title={"HTML"} onPress={getHTML} />
    </ScrollView>
  )
}

export function TextEditor() {

  const editorRef = React.useRef<RichTextEditorRef>(null)

  const insert = React.useCallback((tag: string) => {
    editorRef.current?.insertTag?.(tag)
  }, [editorRef])

  const getHTML = React.useCallback(() => {
    const html = editorRef.current?.getHTML?.()
    console.log({ html })
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