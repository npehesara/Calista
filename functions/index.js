const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.chemicalAlert = functions.database
  .ref("/chemicalTank/{type}")
  .onUpdate((change, context) => {

    const before = change.before.val();
    const after = change.after.val();

    console.log("Before:", before, "After:", after);

    if (after <= 10 && before > 10) {

      const message = {
        notification: {
          title: "⚠ Low Chemical Alert",
          body: `${context.params.type} level is ${after}%`
        },
        topic: "calista"
      };

      return admin.messaging().send(message);
    }

    return null;
  });