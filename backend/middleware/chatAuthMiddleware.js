const jwt = require("jsonwebtoken");
const Trainer = require("../models/Trainer");
const Client = require("../models/Client");

// Accepts EITHER a trainer JWT or a client JWT, since the chat
// upload endpoint is shared by both apps. Sets req.senderType so
// controllers can tell which one made the request.
module.exports = async (req, res, next) => {
  try {
    const authHeader = req.header("Authorization");

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        message: "Access denied. No token provided.",
      });
    }

    const token = authHeader.replace("Bearer ", "");

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const trainer = await Trainer.findById(decoded.id).select(
      "-password"
    );

    if (trainer) {
      req.trainer = trainer;
      req.senderType = "trainer";
      return next();
    }

    const client = await Client.findById(decoded.id);

    if (client) {
      req.client = client;
      req.senderType = "client";
      return next();
    }

    return res.status(401).json({
      message: "Invalid token.",
    });
  } catch (err) {
    res.status(401).json({
      message: "Invalid or expired token.",
    });
  }
};
