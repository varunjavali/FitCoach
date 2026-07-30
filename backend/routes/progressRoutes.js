const express = require("express");

const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");

const {
  createProgress,
  getProgressList,
  getClientProgress,
  getProgress,
  updateProgress,
  deleteProgress,
} = require("../controllers/progressController");

// Create Progress
router.post("/", authMiddleware, createProgress);

// Get all progress
router.get("/", authMiddleware, getProgressList);

// Get progress by client
router.get(
  "/client/:clientId",
  authMiddleware,
  getClientProgress
);

// Get single progress
router.get(
  "/:id",
  authMiddleware,
  getProgress
);

// Update progress
router.put(
  "/:id",
  authMiddleware,
  updateProgress
);

// Delete progress
router.delete(
  "/:id",
  authMiddleware,
  deleteProgress
);

module.exports = router;