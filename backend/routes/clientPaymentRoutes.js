const express = require("express");
const router = express.Router();

const clientAuthMiddleware = require("../middleware/clientAuthMiddleware");

const {
  getPaymentHistory,
} = require("../controllers/clientPaymentController");

router.get(
  "/history",
  clientAuthMiddleware,
  getPaymentHistory
);

module.exports = router;