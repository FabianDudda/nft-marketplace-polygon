import React, { useEffect } from "react";
import { app } from "..//firebase";
const db = app.firestore();
import { doc, getDoc, setDoc } from "firebase/firestore";

const test = () => {
  useEffect(() => {
    newDoc();
    readDoc();
  }, [newDoc(), readDoc()]);

  async function newDoc() {
    // Add a new document in collection "cities"
    await setDoc(doc(db, "test", "LA"), {
      name: "Los Angeles",
      state: "CA",
      country: "USA",
    });
  }

  async function readDoc() {
    const docRef = doc(db, "test", "GrZNGFlo7CjC3FLyaOcg");
    const docSnap = await getDoc(docRef);

    if (docSnap.exists()) {
      console.log("Document data:", docSnap.data());
    } else {
      // doc.data() will be undefined in this case
      console.log("No such document!");
    }
  }

  return <></>;
};

export default test;
