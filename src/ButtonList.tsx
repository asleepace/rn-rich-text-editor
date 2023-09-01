import React, { useCallback, useEffect, useState } from 'react';
import { Button, ScrollView, StyleSheet } from 'react-native';

interface ButtonListProps {
  activeStyles: ActiveStyles
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
}

export type StyleName = keyof ActiveStyles

export type ButtonProps = {
  style: StyleName
  title: string
  tag: string
}

export function ButtonList({ insert, generateHtml, activeStyles = {} }: ButtonListProps) {

  const [style, setStyle] = useState<ActiveStyles>({ ...activeStyles })

  useEffect(() => {
    console.log('[ButtonList] activeStyles changed: ', { activeStyles })
    setStyle({ ...activeStyles })
  }, [activeStyles])

  const onToggleSyle = useCallback((item: StyleName, tag: string) => {
    setStyle((prevStyle) => ({ ...prevStyle, [item]: !prevStyle[item] }))
    insert(tag)
  }, [insert, setStyle])

  const buttons: ButtonProps[] = React.useMemo(() => {
    return [
      { title: 'B', tag: '<b>', style: 'isBold' },
      { title: 'I', tag: '<i>', style: 'isItalic' },
      { title: 'U', tag: '<u>', style: 'isUnderline' },
      { title: 'S', tag: '<del>', style: 'isStrikeThrough' },
      { title: 'x²', tag: '<sup>', style: 'isSuperscript' },
      { title: 'x₂', tag: '<sub>', style: 'isSubscript' },
      { title: '[]', tag: '<ins>', style: 'isMonospace' },
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
            color={style[item.style] ? activeColor: normalColor}
            title={item.title}
            onPress={() => onToggleSyle(item.style, item.tag)}
          />
        ))
      }
      <Button color={normalColor} title={"HTML"} onPress={() => generateHtml()} />
    </ScrollView>
  )
}

const normalColor = '#389ef2'
const activeColor = '#f39539'

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