const Progress = require("../models/Progress");

// Create Progress
const Progress = require("../models/Progress");
const Client = require("../models/Client");

exports.createProgress = async (req, res) => {
  try {
    // Logged-in client
    const client = await Client.findById(req.client._id);

    if (!client) {
      return res.status(404).json({
        message: "Client not found",
      });
    }

    const progress = await Progress.create({
      trainer: client.trainer,
      client: client._id,

      date: req.body.date,
      weight: req.body.weight,
      height: req.body.height,
      bmi: req.body.bmi,
      bodyFat: req.body.bodyFat,
      chest: req.body.chest,
      waist: req.body.waist,
      biceps: req.body.biceps,
      forearm: req.body.forearm,
      thigh: req.body.thigh,
      shoulder: req.body.shoulder,
      neck: req.body.neck,
      notes: req.body.notes,
      photo: req.body.photo,
    });

    res.status(201).json({
      message: "Progress submitted successfully",
      progress,
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// Delete progress
exports.deleteProgress = async (req, res) => {
  try {
    const progress = await Progress.findOneAndDelete({
      _id: req.params.id,
      trainer: req.trainer._id,
    });

    if (!progress) {
      return res.status(404).json({
        message: "Progress not found",
      });
    }

    res.json({
      message: "Progress deleted successfully",
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};