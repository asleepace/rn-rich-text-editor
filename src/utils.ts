export const SampleText = `
<p>Hello, world!</p>
<ul>
  <li>One</li>
  <li>Two</li>
  <li>Three</li>
</ul>
`;

export const styleText = (text: string): string => text ||

`
<html>
<head>
  <style type="text/css">
  html {
    font-family: Helvetica;
    color: red;
  }
  body {
    font-family: HelveticaNeue, Helvetica, Arial, sans-serif;
    font-size: 18px;
    line-height: 20px;
    color: black;
  }
  code {
    background-color: #EEE;
    border-radius: 2px;
    padding: 8px;
  }
  </style>
</head><body>${text}</body></html>`