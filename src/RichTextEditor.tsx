import React, { SyntheticEvent } from 'react';
import ReactNative, {
  NativeModules,
  StyleProp,
  StyleSheet,
  ViewStyle,
  requireNativeComponent,
} from 'react-native';

const RCTRichTextView = requireNativeComponent('RCTRichText');
const RCTRichTextManager = NativeModules.RCTRichTextManager;

interface Props {
  style?: StyleProp<ViewStyle>;
  onSelection?: (data: any) => void;
}

interface State {
  text: string;
}

function styleText(text: string): string {
  return `
<html>
<head>
  <style type="text/css">
  body {
    font-size: 16px;
    line-height: 18px;
    font-family: Roboto;
    color: black;
  }
  code {
    background-color: #EEE;
    border-radius: 2px;
    padding: 8px;
  }
  </style>
</head><body><p>${text}</p></body></html>`;
}

const SampleText = `<b>Bold Text</b><br>
<i>Italic Text</i><br>
<em>Emphasized Text</em><br>
<mark>Marked Text</mark><br>
<del>Deleted Text</del><br>
<ins>Inserted Text</ins><br>
<sub>Subscript Text</sub><br>
<sup>Superscript Text</sup><br>
<code>const myVar = "colin";</code><br></br>`;

/*
<b>Bold TextM/b><br>
<i>Italic Text</i><br>
<em>Emphasized Text</em><br>
<mark>Marked Text</mark><br>
<del>Deleted Text</del><br>
<ins>Inserted Text</ins><br>
<sub>Subscript Text</sub><br>
<sup>Superscript Text</sup><br>
<code>const myVar = "colin";</code><br></br> */

export default class RichTextEditor extends React.Component<Props, State> {
  private rtf: React.RefObject<any> = React.createRef();

  constructor(props: Props) {
    super(props);
  }

  onLayout = (event: any) => {
    console.log('[RichTextEditor] on layout: ', {event});
  };

  public insertTag = (tag: string) => {
    console.log('[RichTextEditor] insert tag called: ', tag);
    console.log('[RichTextEdutor] current tag:', this.getTag());
    RCTRichTextManager.insertTag(tag, this.getTag());
  };

  public getHTML = () => {
    RCTRichTextManager.getHTML(this.getTag());
  };

  private getTag = () => {
    return ReactNative.findNodeHandle(this.rtf.current); // TODO: this is broken :(
  };

  private onSelection = (data: SyntheticEvent) => {
    console.log('[RichTextEditor] on selection:', data.nativeEvent);
    this.props.onSelection?.(data.nativeEvent);
  };

  render(): React.ReactElement {
    const {style} = this.props;
    return (
      <RCTRichTextView
        ref={this.rtf}
        style={[styles.frame, style]}
        onSelection={this.onSelection}
        text={styleText(SampleText)}
        onLayout={this.onLayout}
        textStyle={{
          fontSize: 16.0,
          fontFamily: 'Roboto',
        }}
      />
    );
  }
}

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
