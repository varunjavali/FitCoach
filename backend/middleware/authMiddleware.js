const jwt = require("jsonwebtoken");
const Trainer = require("../models/Trainer");

const authMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.header("Authorization");

    if (!authHeader) {
      return res.status(401).json({
        message: "Access denied. No token provided.",
      });
    }

    if (!authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        message: "Invalid token format.",
      });
    }

    const token = authHeader.replace("Bearer ", "");

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    console.log("Decoded JWT:", decoded);

    const trainer = await Trainer.findById(decoded.id).select("-password");

    console.log("Trainer Found:", trainer);

    if (!trainer) {
      return res.status(401).json({
        message: "Trainer not found.",
      });
    }

    req.trainer = trainer;

    next();
  } catch (err) {
    console.log(err);

    res.status(401).json({
      message: "Invalid or expired token.",
    });
  }
};

module.exports = authMiddleware;