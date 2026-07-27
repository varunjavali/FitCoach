const express = require("express");

const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const clientAuthMiddleware = require("../middleware/clientAuthMiddleware");

const {
  addClient,
  getClients,
  getClient,
  updateClient,
  deleteClient,
  updateBalance,
  getMyWorkouts,
  getMyDiets,
  getMyProgress,
  addMyProgress,
} = require("../controllers/clientController");

/* ==========================================================
   CLIENT APP ROUTES (Client Login)
========================================================== */

router.get(
  "/workouts",
  clientAuthMiddleware,
  getMyWorkouts
);

router.get(
  "/diets",
  clientAuthMiddleware,
  getMyDiets
);

router.get(
  "/progress",
  clientAuthMiddleware,
  getMyProgress
);

router.post(
  "/progress",
  clientAuthMiddleware,
  addMyProgress
);

/* ==========================================================
   TRAINER APP ROUTES
========================================================== */

router.use(authMiddleware);

// Add Client
router.post("/", addClient);

// Get All Clients
router.get("/", getClients);

// Get Single Client
router.get("/:id", getClient);

// Update Client
router.put("/:id", updateClient);

// Update Client Balance
router.put(
  "/:id/update-balance",
  updateBalance
);

// Delete Client
router.delete("/:id", deleteClient);

module.exports = router;