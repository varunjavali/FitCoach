const express = require("express");

const router = express.Router();

const clientAuthMiddleware = require("../middleware/clientAuthMiddleware");

const {
  loginClient,
  changePassword,
} = require("../controllers/clientAuthController");

router.post("/login", loginClient);

router.put(
  "/change-password",
  clientAuthMiddleware,
  changePassword
);

module.exports = router;