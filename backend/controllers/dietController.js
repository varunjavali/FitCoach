const Diet = require("../models/Diet");

// Create Diet
exports.createDiet = async (req, res) => {
  try {
    const diet = await Diet.create({
      trainer: req.trainer._id,
      client: req.body.client,
      title: req.body.title,
      day: req.body.day,
      meals: req.body.meals,
      waterIntake: req.body.waterIntake,
      notes: req.body.notes,
    });

    res.status(201).json({
      message: "Diet created successfully",
      diet,
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// Get all diets of logged-in trainer
exports.getDiets = async (req, res) => {
  try {
    const diets = await Diet.find({
      trainer: req.trainer._id,
    })
      .populate("client", "name")
      .sort({ createdAt: -1 });

    res.json(diets);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// Get diets of a client
exports.getClientDiets = async (req, res) => {
  try {
    const diets = await Diet.find({
      trainer: req.trainer._id,
      client: req.params.clientId,
    })
      .populate("client", "name")
      .sort({ createdAt: -1 });

    res.json(diets);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// Get single diet
exports.getDiet = async (req, res) => {
  try {
    const diet = await Diet.findOne({
      _id: req.params.id,
      trainer: req.trainer._id,
    }).populate("client", "name");

    if (!diet) {
      return res.status(404).json({
        message: "Diet not found",
      });
    }

    res.json(diet);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// Update diet
exports.updateDiet = async (req, res) => {
  try {
    const diet = await Diet.findOneAndUpdate(
      {
        _id: req.params.id,
        trainer: req.trainer._id,
      },
      {
        client: req.body.client,
        title: req.body.title,
        day: req.body.day,
        meals: req.body.meals,
        waterIntake: req.body.waterIntake,
        notes: req.body.notes,
      },
      { new: true }
    );

    if (!diet) {
      return res.status(404).json({
        message: "Diet not found",
      });
    }

    res.json({
      message: "Diet updated successfully",
      diet,
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// Delete diet
exports.deleteDiet = async (req, res) => {
  try {
    const diet = await Diet.findOneAndDelete({
      _id: req.params.id,
      trainer: req.trainer._id,
    });

    if (!diet) {
      return res.status(404).json({
        message: "Diet not found",
      });
    }

    res.json({
      message: "Diet deleted successfully",
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};