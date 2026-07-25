const Client = require("../models/Client");
const bcrypt = require("bcryptjs");

// Add Client
exports.addClient = async (req, res) => {
  try {
    const { name, email, phone, age, gender, height, weight, goal, medicalHistory, notes } = req.body;

    // Check if email already exists
    const existingClient = await Client.findOne({
      email: email.toLowerCase(),
    });

    if (existingClient) {
      return res.status(400).json({
        message: "Client with this email already exists",
      });
    }

    // Temporary password
    const tempPassword = "Fit@1234";

    // Hash password
    const hashedPassword = await bcrypt.hash(tempPassword, 10);

    const client = await Client.create({
      trainer: req.trainer._id,
      name,
      email: email.toLowerCase(),
      password: hashedPassword,
      phone,
      age,
      gender,
      height,
      weight,
      goal,
      medicalHistory,
      notes,
      isFirstLogin: true,
    });

    res.status(201).json({
      message: "Client created successfully",
      temporaryPassword: tempPassword,
      client,
    });

  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// Get All Clients
exports.getClients = async (req, res) => {
  try {
    const clients = await Client.find({
      trainer: req.trainer._id,
    }).sort({ createdAt: -1 });

    res.json(clients);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Get Single Client
exports.getClient = async (req, res) => {
  try {
    const client = await Client.findOne({
      _id: req.params.id,
      trainer: req.trainer._id,
    });

    if (!client) {
      return res.status(404).json({
        message: "Client not found",
      });
    }

    res.json(client);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Update Client
exports.updateClient = async (req, res) => {
  try {
    const client = await Client.findOneAndUpdate(
      {
        _id: req.params.id,
        trainer: req.trainer._id,
      },
      req.body,
      {
        new: true,
      }
    );

    if (!client) {
      return res.status(404).json({
        message: "Client not found",
      });
    }

    res.json({
      message: "Client updated successfully",
      client,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Delete Client
exports.deleteClient = async (req, res) => {
  try {
    const client = await Client.findOneAndDelete({
      _id: req.params.id,
      trainer: req.trainer._id,
    });

    if (!client) {
      return res.status(404).json({
        message: "Client not found",
      });
    }

    res.json({
      message: "Client deleted successfully",
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
const Workout = require("../models/Workout");
const Diet = require("../models/Diet");

// Get Logged-in Client Workouts
exports.getMyWorkouts = async (req, res) => {
  try {
    const workouts = await Workout.find({
      client: req.client._id,
    }).sort({
      createdAt: -1,
    });

    res.json(workouts);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// Get Logged-in Client Diets
exports.getMyDiets = async (req, res) => {
  try {
    const diets = await Diet.find({
      client: req.client._id,
    }).sort({
      createdAt: -1,
    });

    res.json(diets);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};