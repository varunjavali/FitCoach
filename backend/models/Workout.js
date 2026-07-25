const mongoose = require("mongoose");

const exerciseSchema = new mongoose.Schema({
  exerciseName: {
    type: String,
    required: true,
  },
  sets: {
    type: Number,
    required: true,
  },
  reps: {
    type: Number,
    required: true,
  },
  weight: {
    type: Number,
    default: 0,
  },
  rest: {
    type: Number,
    default: 60,
  },
});

const workoutSchema = new mongoose.Schema(
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
    title: {
      type: String,
      required: true,
    },
    day: {
      type: String,
      required: true,
    },
    exercises: [exerciseSchema],
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("Workout", workoutSchema);