const mongoose = require("mongoose");

const mealSchema = new mongoose.Schema({
  mealType: {
    type: String,
    required: true,
  },
  food: {
    type: String,
    required: true,
  },
  quantity: {
    type: String,
    required: true,
  },
  calories: {
    type: Number,
    default: 0,
  },
});

const dietSchema = new mongoose.Schema(
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
    meals: [mealSchema],
    waterIntake: {
      type: Number,
      default: 3,
    },
    notes: {
      type: String,
      default: "",
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("Diet", dietSchema);