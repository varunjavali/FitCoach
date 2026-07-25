const express = require("express");

const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");

const {
  createWorkout,
  getWorkouts,
  getClientWorkouts,
  getWorkout,
  updateWorkout,
  deleteWorkout,
} = require("../controllers/workoutController");

// Create workout
router.post("/", authMiddleware, createWorkout);

// All workouts of trainer
router.get("/", authMiddleware, getWorkouts);

// Workouts of one client
router.get(
  "/client/:clientId",
  authMiddleware,
  getClientWorkouts
);

// Single workout
router.get("/:id", authMiddleware, getWorkout);

// Update workout
router.put("/:id", authMiddleware, updateWorkout);

// Delete workout
router.delete("/:id", authMiddleware, deleteWorkout);

module.exports = router;