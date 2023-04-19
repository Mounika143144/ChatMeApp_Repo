importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBcw2RruVPM0e4SBkakRNkURtKtROSklV0",
  appId: "1:1078460833504:web:d8fb7f6b23178dda737a85",
  messagingSenderId: "1078460833504",
  projectId: "chatmeflutterapp",
  authDomain: "chatmeflutterapp.firebaseapp.com",
  databaseURL: "https://chatmeflutterapp-default-rtdb.firebaseio.com",
  storageBucket: "chatmeflutterapp.appspot.com",
  measurementId: "G-13YJMMBGHK"
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});