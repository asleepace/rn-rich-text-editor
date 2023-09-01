import React from 'react';
import { InputAccessoryView, StyleSheet, View } from 'react-native';
import { ButtonList } from './ButtonList';
import { RichTextEditor, RichTextEditorRef } from './RichTextEditor';


export function TextEditor() {

  const editorRef = React.useRef<RichTextEditorRef>(null)

  const [activeStyles, setActiveStyles] = React.useState({})

  console.log('[TextEditor] editorRef:', editorRef)

  return (
    <View style={styles.overlay}>
      <InputAccessoryView>
        <View style={styles.editor}>
          <RichTextEditor ref={editorRef} onChangeStyle={(active) => setActiveStyles({ ...activeStyles, ...active })} />
        </View>
        <ButtonList 
          insert={(tag: string) => editorRef.current?.insertTag?.(tag)} 
          insertHtml={(html: string) => editorRef.current?.insertHtml?.(html)}
          generateHtml={() => editorRef.current?.generateHtml?.()} 
          activeStyles={activeStyles} />
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
    fontFamily: 'Roboto',
    minHeight: 60,
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
  bottom: {
    minHeight:44, 
    backgroundColor: '#DDD'
  }
});