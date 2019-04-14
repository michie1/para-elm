'use strict';

require("./styles.scss");

const { Elm } = require('./Main');
const app = Elm.Main.init({
  node: document.getElementById('main')
});

const config = {
  apiKey: "AIzaSyDqnEt2g982eddnHr7-J42BTp9nIMjEkak",
  authDomain: "para-elm.firebaseapp.com",
  databaseURL: "https://para-elm.firebaseio.com",
  projectId: "para-elm",
  storageBucket: "para-elm.appspot.com",
  messagingSenderId: "988726686013"
};
firebase.initializeApp(config);

const database = firebase.firestore();
const doc = database.collection('config')
  .doc('iqgn07usRJsFj9tZvetY');

doc.onSnapshot((snapshot) => {
  const {
    red,
    blue,
    green,
    distance
  } = snapshot.data();

  app.ports.infoForElm.send({
    tag: 'UpdatedRed',
    data: red,
  });

  app.ports.infoForElm.send({
    tag: 'UpdatedBlue',
    data: blue,
  });

  app.ports.infoForElm.send({
    tag: 'UpdatedGreen',
    data: green,
  });

  app.ports.infoForElm.send({
    tag: 'UpdatedDistance',
    data: distance,
  });
});

app.ports.infoForOutside
  .subscribe((msg) => {
    if (msg.tag === 'UpdateRed') {
      update('red', msg.data);
    } else if (msg.tag === 'UpdateBlue') {
      update('blue', msg.data);
    } else if (msg.tag === 'UpdateGreen') {
      update('green', msg.data);
    } else if (msg.tag === 'UpdateDistance') {
      update('distance', msg.data);
    }
  });

function update(field, value) {
  doc.set({
    [field]: value
  }, {
    merge: true
  });
}

