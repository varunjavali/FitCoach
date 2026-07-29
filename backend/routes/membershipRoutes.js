const express = require("express");

const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");

const {
  renewMembership,
  getMembershipHistory,
  getCurrentMembership,
  cancelMembership,
} = require("../controllers/membershipController");

router.post("/renew/:clientId", authMiddleware, renewMembership);

router.get(
  "/history/:clientId",
  authMiddleware,
  getMembershipHistory
);

router.get(
  "/current/:clientId",
  authMiddleware,
  getCurrentMembership
);

router.put(
  "/cancel/:membershipId",
  authMiddleware,
  cancelMembership
);

module.exports = router;