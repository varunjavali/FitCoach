const express = require("express");

const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");

const {
  addPayment,
  getPayments,
  getPayment,
  getClientPayments,
  deletePayment,
} = require("../controllers/paymentController");

router.use(authMiddleware);

router.post("/", addPayment);

router.get("/", getPayments);

router.get("/client/:clientId", getClientPayments);

router.get("/:id", getPayment);

router.delete("/:id", deletePayment);

module.exports = router;