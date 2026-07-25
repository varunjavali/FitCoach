const express = require("express");

const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");

const {
  createDiet,
  getDiets,
  getClientDiets,
  getDiet,
  updateDiet,
  deleteDiet,
} = require("../controllers/dietController");

// Create diet
router.post("/", authMiddleware, createDiet);

// Get all diets of logged-in trainer
router.get("/", authMiddleware, getDiets);

// Get diets of one client
router.get(
  "/client/:clientId",
  authMiddleware,
  getClientDiets
);

// Get single diet
router.get("/:id", authMiddleware, getDiet);

// Update diet
router.put("/:id", authMiddleware, updateDiet);

// Delete diet
router.delete("/:id", authMiddleware, deleteDiet);

module.exports = router;