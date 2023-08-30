import React from 'react';
import { Button, InputAccessoryView, ScrollView, StyleSheet, View } from 'react-native';
import { RichTextEditor, RichTextEditorRef } from './RichTextEditor';
import { convertCocoaHtmlToPadletHtml } from './html';

interface ButtonListProps {
  insert: (tag: string) => void;
  getHTML: () => void;
}

function ButtonList({ insert, getHTML }: ButtonListProps) {

  const [isBold, setIsBold] = React.useState(false)
  const [isItalic, setIsItalic] = React.useState(false)
  const [isUnderline, setIsUnderline] = React.useState(false)
  const [isStrikeThrough, setIsStrikeThrough] = React.useState(false)
  const [isSubscript, setIsSubscript] = React.useState(false)
  const [isSuperscript, setIsSuperscript] = React.useState(false)
  const [isMonospace, setIsMonospace] = React.useState(false)
  const [isMarked, setIsMarked] = React.useState(false)
  const [isCode, setIsCode] = React.useState(false)

  return (
    <ScrollView style={styles.button} horizontal={true}>
      <Button color={isBold ? '#f39539' : '#389ef2' } title={"B"} onPress={() => {
        setIsBold(!isBold)
        insert("<b>")
      }} />
      <Button color={isItalic ? '#f39539' : '#389ef2'} title={"I"} onPress={() => {
        setIsItalic(!isItalic)
        insert("<i>")
      }} />
      <Button color={isUnderline ? '#f39539' : '#389ef2'} title={"U"} onPress={() => {
        setIsUnderline(!isUnderline)
        insert("<u>")
      }} />
      <Button color={isStrikeThrough ? '#f39539' : '#389ef2'} title={"S"} onPress={() => {
        setIsStrikeThrough(!isStrikeThrough)
        insert("<del>")
      }} />
      <Button color={isSuperscript ? '#f39539' : '#389ef2'} title={"x²"} onPress={() => {
        setIsSuperscript(!isSuperscript)
        insert("<sup>")
      }} />
      <Button color={isSubscript ? '#f39539' : '#389ef2'} title={"x₂"} onPress={() => {
        setIsSubscript(!isSubscript)
        insert("<sub>")
      }} />
      <Button color={isMonospace ? '#f39539' : '#389ef2'} title={"[]"} onPress={() => {
        setIsMonospace(!isMonospace)
        insert("<ins>")
      }} />
      <Button color={isMarked ? '#f39539' : '#389ef2'} title={"H"} onPress={() => {
        setIsMarked(!isMarked)
        insert("<mark>")
      }} />
      <Button color={isMarked ? '#f39539' : '#389ef2'} title={"</>"} onPress={() => {
        setIsCode(!isCode)
        insert("<code>")
      }} />
      <Button color={'#389ef2'} title={"HTML"} onPress={getHTML} />
    </ScrollView>
  )
}

export function TextEditor() {

  const editorRef = React.useRef<RichTextEditorRef>(null)

  const insert = React.useCallback((tag: string) => {
    console.log('[TextEditor] insert tag called: ', tag)
    editorRef.current?.insertTag?.(tag)
  }, [editorRef])

  const getHTML = React.useCallback(() => {
    const html = editorRef.current?.getHTML?.() ?? ""
    const padletHtml = convertCocoaHtmlToPadletHtml(html)
    console.log({ padletHtml })
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