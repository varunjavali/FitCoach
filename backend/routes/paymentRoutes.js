const express = require("express");

const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");

const {
  addPayment,
  getPayments,
  getClientPayments,
  getPayment,
  deletePayment,
} = require("../controllers/paymentController");

// Protect all routes
router.use(authMiddleware);

// Add Payment
router.post("/", addPayment);

// Get All Payments
router.get("/", getPayments);

// Get Payments of One Client
router.get("/client/:clientId", getClientPayments);

// Get Single Payment
router.get("/:id", getPayment);

// Delete Payment
router.delete("/:id", deletePayment);

module.exports = router;