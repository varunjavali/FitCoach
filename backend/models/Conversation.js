const mongoose = require("mongoose");

const messageSchema = new mongoose.Schema(
  {
    sender: {
      type: String,
      enum: ["trainer", "client"],
      required: true,
    },

    type: {
      type: String,
      enum: ["text", "image", "audio", "video"],
      default: "text",
    },

    text: {
      type: String,
      trim: true,
      default: "",
    },

    mediaUrl: {
      type: String,
      default: null,
    },

    isRead: {
      type: Boolean,
      default: false,
    },

    createdAt: {
      type: Date,
      default: Date.now,
    },
  },
  { _id: false }
);

const conversationSchema = new mongoose.Schema(
  {
    trainer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Trainer",
      required: true,
    },

    client: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Client",
      required: true,
    },

    messages: [messageSchema],
  },
  {
    timestamps: true,
  }
);

// Only one conversation per trainer-client pair
conversationSchema.index(
  {
    trainer: 1,
    client: 1,
  },
  {
    unique: true,
  }
);

module.exports = mongoose.model(
  "Conversation",
  conversationSchema
);