const mongoose = require("mongoose");

const clientSchema = new mongoose.Schema(
  {
    trainer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Trainer",
      required: true,
    },

    name: {
      type: String,
      required: true,
      trim: true,
    },

    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },

    password: {
      type: String,
      required: true,
    },

    phone: {
      type: String,
      required: true,
      trim: true,
    },

    age: {
      type: Number,
      default: null,
    },

    gender: {
      type: String,
      enum: ["Male", "Female", "Other"],
      default: "Male",
    },

    height: {
      type: Number,
      default: null,
    },

    weight: {
      type: Number,
      default: null,
    },

    goal: {
      type: String,
      default: "",
      trim: true,
    },

    joiningDate: {
      type: Date,
      default: Date.now,
    },

    medicalHistory: {
      type: String,
      default: "",
      trim: true,
    },

    notes: {
      type: String,
      default: "",
      trim: true,
    },

    isActive: {
      type: Boolean,
      default: true,
    },
    isFirstLogin: {
      type: Boolean,
      default: true,
    },


    lastLogin: {
      type: Date,
      default: null,
    },
    
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("Client", clientSchema);