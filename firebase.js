// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import firebase from "firebase/compat/app";
import "firebase/compat/firestore";

// TODO: Add SDKs for Firebase products that you want to use

// htts://firebase.google.com/docs/web/setup#available-libraries
// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional

const firebaseConfig = {
  apiKey: "AIzaSyCQapL-XD98sOFzV_Z-X6ahso-2Vbllz_c",
  authDomain: "nft-market-polygon.firebaseapp.com",
  projectId: "nft-market-polygon",
  storageBucket: "nft-market-polygon.appspot.com",
  messagingSenderId: "484536035379",
  appId: "1:484536035379:web:625a37f9cbd04a28d7db46",
  measurementId: "G-12Y4QQJ745",
};

// Initialize Firebase
export const app = firebase.initializeApp(firebaseConfig);

export const db = getFirestore(app);
export const auth = getAuth(app);
