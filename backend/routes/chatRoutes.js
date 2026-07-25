const express = require("express");

const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const clientAuthMiddleware = require("../middleware/clientAuthMiddleware");
const chatAuthMiddleware = require("../middleware/chatAuthMiddleware");
const upload = require("../middleware/uploadMiddleware");

const {
  getConversation,
  getMyConversation,
  markAsRead,
  uploadChatMedia,
} = require("../controllers/chatController");

// Media upload (image/audio/video) — accepts either a trainer or a
// client JWT since both apps share this endpoint. Must come before
// nothing else conflicts since this router only has GET/PUT routes
// below.
router.post(
  "/upload",
  chatAuthMiddleware,
  upload.single("file"),
  uploadChatMedia
);

// Trainer loads conversation
router.get(
  "/trainer/:clientId",
  authMiddleware,
  getConversation
);

// Client loads own conversation
router.get(
  "/client",
  clientAuthMiddleware,
  getMyConversation
);

// Client marks trainer messages as read
router.put(
  "/read",
  clientAuthMiddleware,
  markAsRead
);

module.exports = router;