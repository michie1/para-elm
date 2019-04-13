'use strict';

require("./styles.scss");

const { Elm } = require('./Main');
const app = Elm.Main.init({
  node: document.getElementById('main')
});
