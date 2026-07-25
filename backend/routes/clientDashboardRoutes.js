const express = require("express");

const router = express.Router();

const clientAuthMiddleware = require("../middleware/clientAuthMiddleware");

const {
  getDashboard,
} = require("../controllers/clientDashboardController");

router.get("/", clientAuthMiddleware, getDashboard);

module.exports = router;