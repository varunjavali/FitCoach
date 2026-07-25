const Progress = require("../models/Progress");

// Create Progress
exports.createProgress = async (req, res) => {
  try {
    const progress = await Progress.create({
      trainer: req.trainer._id,
      client: req.body.client,
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
      message: "Progress added successfully",
      progress,
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// Get all progress entries
exports.getProgressList = async (req, res) => {
  try {
    const progress = await Progress.find({
      trainer: req.trainer._id,
    })
      .populate("client", "name")
      .sort({ date: -1 });

    res.json(progress);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// Get progress of one client
exports.getClientProgress = async (req, res) => {
  try {
    const progress = await Progress.find({
      trainer: req.trainer._id,
      client: req.params.clientId,
    }).sort({ date: -1 });

    res.json(progress);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// Get single progress
exports.getProgress = async (req, res) => {
  try {
    const progress = await Progress.findOne({
      _id: req.params.id,
      trainer: req.trainer._id,
    }).populate("client", "name");

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

// Update progress
exports.updateProgress = async (req, res) => {
  try {
    const progress = await Progress.findOneAndUpdate(
      {
        _id: req.params.id,
        trainer: req.trainer._id,
      },
      {
        client: req.body.client,
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
      },
      { new: true }
    );

    if (!progress) {
      return res.status(404).json({
        message: "Progress not found",
      });
    }

    res.json({
      message: "Progress updated successfully",
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