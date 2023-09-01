import React, { useCallback } from 'react';
import { Button, ScrollView, StyleSheet } from 'react-native';

interface ButtonListProps {
  activeStyles: ActiveStyles
  insertHtml(html: string): void
  insert(tag: string): void
  generateHtml(): void
}

export type ActiveStyles = {
  isBold?: boolean
  isItalic?: boolean
  isUnderline?: boolean
  isStrikeThrough?: boolean
  isSubscript?: boolean
  isSuperscript?: boolean
  isMonospace?: boolean
  isMarked?: boolean
  isCode?: boolean
  isUnordedList?: boolean
}

export type StyleName = keyof ActiveStyles

export type ButtonProps = {
  style: StyleName
  title: string
  tag: string
}

export function ButtonList({ insert, insertHtml, generateHtml, activeStyles = {} }: ButtonListProps) {

  const onToggleSyle = useCallback((item: StyleName, tag: string) => {
    insert(tag)
  }, [insert])

  const buttons: ButtonProps[] = React.useMemo(() => {
    return [
      { title: 'B', tag: '<b>', style: 'isBold' },
      { title: 'I', tag: '<i>', style: 'isItalic' },
      { title: 'U', tag: '<u>', style: 'isUnderline' },
      { title: 'S', tag: '<del>', style: 'isStrikeThrough' },
      { title: 'x²', tag: '<sup>', style: 'isSuperscript' },
      { title: 'x₂', tag: '<sub>', style: 'isSubscript' },
      { title: 'M', tag: '<ins>', style: 'isMonospace' },
      { title: 'H', tag: '<mark>', style: 'isMarked' },
      { title: '</>', tag: '<code>', style: 'isCode' },
    ]
  }, [])

  return (
    <ScrollView style={styles.button} horizontal={true}>
      {
        buttons.map((item) => (
          <Button
            key={item.title}
            color={activeStyles[item.style] ? activeColor: normalColor}
            title={item.title}
            onPress={() => onToggleSyle(item.style, item.tag)}
          />
        ))
      }
      <Button color={normalColor} title={"[ : ]"} onPress={() => insertHtml('<ul><li></li>')} />
      <Button color={normalColor} title={"[ 1 ]"} onPress={() => insertHtml('<ol><li></li>')} />
      <Button color={normalColor} title={"Done"} onPress={() => generateHtml()} />
    </ScrollView>
  )
}

const normalColor = '#389ef2'
const activeColor = '#f39539'

const styles = StyleSheet.create({
  button :{
    maxHeight: 60,
    backgroundColor: '#F2F2F7',
    flexDirection: 'row',
    flexShrink: 1,
    padding: 8,
  }
})