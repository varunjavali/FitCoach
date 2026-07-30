const Progress = require("../models/Progress");
const Client = require("../models/Client");

// ===============================
// Create Progress (Trainer)
// ===============================
exports.createProgress = async (req, res) => {
  try {
    const {
      clientId,
      date,
      weight,
      height,
      bmi,
      bodyFat,
      chest,
      waist,
      biceps,
      forearm,
      thigh,
      shoulder,
      neck,
      notes,
      photo,
    } = req.body;

    const client = await Client.findOne({
      _id: clientId,
      trainer: req.trainer._id,
    });

    if (!client) {
      return res.status(404).json({
        message: "Client not found",
      });
    }

    const progress = await Progress.create({
      trainer: req.trainer._id,
      client: client._id,
      date,
      weight,
      height,
      bmi,
      bodyFat,
      chest,
      waist,
      biceps,
      forearm,
      thigh,
      shoulder,
      neck,
      notes,
      photo,
    });

    res.status(201).json(progress);
  } catch (err) {
    console.error(err);
    res.status(500).json({
      message: err.message,
    });
  }
};

// ===============================
// Get All Progress
// ===============================
exports.getProgressList = async (req, res) => {
  try {
    const progress = await Progress.find({
      trainer: req.trainer._id,
    })
      .populate("client", "name email phone")
      .sort({ createdAt: -1 });

    res.json(progress);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// ===============================
// Get Client Progress
// ===============================
exports.getClientProgress = async (req, res) => {
  try {
    const progress = await Progress.find({
      trainer: req.trainer._id,
      client: req.params.clientId,
    }).sort({ createdAt: -1 });

    res.json(progress);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// ===============================
// Get Single Progress
// ===============================
exports.getProgress = async (req, res) => {
  try {
    const progress = await Progress.findOne({
      _id: req.params.id,
      trainer: req.trainer._id,
    }).populate("client", "name email phone");

    if (!progress) {
      return res.status(404).json({
        message: "Progress not found",
      });
    }

    res.json(progress);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// ===============================
// Update Progress
// ===============================
exports.updateProgress = async (req, res) => {
  try {
    const progress = await Progress.findOneAndUpdate(
      {
        _id: req.params.id,
        trainer: req.trainer._id,
      },
      req.body,
      {
        new: true,
      }
    );

    if (!progress) {
      return res.status(404).json({
        message: "Progress not found",
      });
    }

    res.json(progress);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// ===============================
// Delete Progress
// ===============================
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