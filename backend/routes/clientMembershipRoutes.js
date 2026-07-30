const express = require("express");
const router = express.Router();

const clientAuthMiddleware = require("../middleware/clientAuthMiddleware");

const {
  getMyMembership,
} = require("../controllers/clientMembershipController");

router.get(
  "/current",
  clientAuthMiddleware,
  getMyMembership
);

module.exports = router;