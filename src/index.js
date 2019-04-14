'use strict';

require("./styles.scss");

const { Elm } = require('./Main');
const app = Elm.Main.init({
  node: document.getElementById('main')
});

app.ports.infoForElm.send({
  tag: 'UpdatedRed',
  data: "0.34",
});

app.ports.infoForOutside
  .subscribe((msg) => {
    console.log('foo', msg);
  });

