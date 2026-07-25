const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");
const clientAuthMiddleware = require("../middleware/clientAuthMiddleware");

const router = express.Router();


const {
  register,
  login,
  clientLogin,
  clientChangePassword,
} = require("../controllers/authController");

router.post("/register", register);

router.post("/login", login);
router.post("/client-login", clientLogin);
router.put(
  "/client-change-password",
  clientAuthMiddleware,
  clientChangePassword
);

module.exports = router;