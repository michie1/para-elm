'use strict';

require("./styles.scss");

const { Elm } = require('./Main');
const app = Elm.Main.init({
  node: document.getElementById('main')
});

app.ports.infoForElm.send({
  tag: 'Get',
  data: {
    foo: 'hallo'
  }
});

app.ports.infoForOutside.subscribe((msg) => {
  console.log('foo', msg);
});

