const jwt = require("jsonwebtoken");
const Client = require("../models/Client");

module.exports = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
      return res.status(401).json({
        message: "Authorization token missing",
      });
    }

    const token = authHeader.split(" ")[1];

    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET
    );

    const client = await Client.findById(decoded.id);

    if (!client) {
      return res.status(401).json({
        message: "Client not found",
      });
    }

    req.client = client;

    next();

  } catch (err) {
    console.error(err);

    return res.status(401).json({
      message: "Unauthorized",
    });
  }
};