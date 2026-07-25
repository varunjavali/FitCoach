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
} = require("../controllers/clientController");
const {
  getMyWorkouts,
  getMyDiets,
} = require("../controllers/clientController");

// Client-facing routes (client JWT, not trainer JWT) — must be
// registered BEFORE the trainer authMiddleware gate below, otherwise
// authMiddleware rejects the client's token trying to look it up as
// a Trainer and these routes never get hit.
router.get(
  "/workouts",
  clientAuthMiddleware,
  getMyWorkouts,
);
router.get(
  "/diets",
  clientAuthMiddleware,
  getMyDiets,
);

// Trainer-facing routes below this line
router.use(authMiddleware);

router.post("/", addClient);

router.get("/", getClients);

router.get("/:id", getClient);

router.put("/:id", updateClient);

router.delete("/:id", deleteClient);

module.exports = router;