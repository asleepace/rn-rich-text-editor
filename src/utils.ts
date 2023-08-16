export const SampleText = `<b>Bold Text</b><br>
<i>Italic Text</i><br>
<em>Emphasized Text</em><br>
<mark>Marked Text</mark><br>
<del>Deleted Text</del><br>
<ins>Inserted Text</ins><br>
<sub>Subscript Text</sub><br>
<sup>Superscript Text</sup><br>
<code>const myVar = "colin";</code><br></br>`;

export const styleText = (text: string): string =>`
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
</head><body><p>${text}</p></body></html>`