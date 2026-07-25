const mongoose = require("mongoose");

const progressSchema = new mongoose.Schema(
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

    date: {
      type: Date,
      default: Date.now,
    },

    weight: {
      type: Number,
      required: true,
    },

    height: {
      type: Number,
      required: true,
    },

    bmi: {
      type: Number,
      required: true,
    },

    bodyFat: {
      type: Number,
      default: 0,
    },

    chest: {
      type: Number,
      default: 0,
    },

    waist: {
      type: Number,
      default: 0,
    },

    biceps: {
      type: Number,
      default: 0,
    },

    forearm: {
      type: Number,
      default: 0,
    },

    thigh: {
      type: Number,
      default: 0,
    },

    shoulder: {
      type: Number,
      default: 0,
    },

    neck: {
      type: Number,
      default: 0,
    },

    notes: {
      type: String,
      default: "",
    },

    photo: {
      type: String,
      default: "",
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("Progress", progressSchema);