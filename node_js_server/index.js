const express = require("express");
var admin = require("firebase-admin");
// PASTE YOUR SERVICE KEY JSON in a new file serviceKey.json
var serverKey = require("./serviceKey.json");

const app = express();

app.use(express.json());

app.get("/", (req, res) => {
	res.send("Hello World!");
});

app.get("/ping", (req, res) => {
	res.send("pong");
});

app.post("/notify", async (req, res) => {
	const { title, body } = req.body;
	try {
		console.log("title: ", title);

		if (admin.apps.length === 0) {
			admin.initializeApp({
				credential: admin.credential.cert(serverKey),
			});
		}

		// TODO: GET registaionTokens from database
		const registrationToken = [];

		var message = {
			tokens: registrationToken,
			notification: {
				title: title,
				body: body,
			},
		};

		await admin.messaging().sendMulticast(message);

		res.send("Message send successfully");
	} catch (e) {
		res.status(500).send({
			error: "Internal Server Error",
		});
	}
});

app.listen(3000, () => {
	console.log("App listening on port 3000!");
});
