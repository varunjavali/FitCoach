const express = require("express");

const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const clientAuthMiddleware = require("../middleware/clientAuthMiddleware");

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

// Get all progress records
router.get("/", authMiddleware, getProgressList);

// Get progress of a specific client
router.get(
  "/client/:clientId",
  authMiddleware,
  getClientProgress
);

// Get single progress record
router.get("/:id", authMiddleware, getProgress);

// Update progress
router.put("/:id", authMiddleware, updateProgress);

// Delete progress
router.delete("/:id", authMiddleware, deleteProgress);
router.post(
  "/",
  clientAuthMiddleware,
  createProgress
);

module.exports = router;