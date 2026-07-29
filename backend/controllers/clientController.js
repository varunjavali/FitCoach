const Client = require("../models/Client");
const Workout = require("../models/Workout");
const Diet = require("../models/Diet");
const Membership = require("../models/membership");
const Progress = require("../models/Progress");
const bcrypt = require("bcryptjs");

// ==========================
// Add Client
// ==========================
// ==========================
// Add Client
// ==========================
exports.addClient = async (req, res) => {
  try {
    const {
      name,
      email,
      phone,
      age,
      gender,
      height,
      weight,
      goal,
      medicalHistory,
      notes,

      totalFees,
      amountPaid,

      membershipBadge,
      membershipDuration,
    } = req.body;

    const existingClient = await Client.findOne({
      email: email.toLowerCase(),
    });

    if (existingClient) {
      return res.status(400).json({
        message: "Client with this email already exists",
      });
    }

    const tempPassword = "Fit@1234";
    const hashedPassword = await bcrypt.hash(tempPassword, 10);

    const fees = Number(totalFees) || 0;
    const paid = Number(amountPaid) || 0;
    const balance = Math.max(fees - paid, 0);

    // Membership Dates
    const startDate = new Date();
    const endDate = new Date(startDate);
    endDate.setMonth(
      endDate.getMonth() + (Number(membershipDuration) || 1)
    );

    // Create Client
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

      totalFees: fees,
      amountPaid: paid,
      balanceDue: balance,

      membershipBadge,
      membershipDuration,
      membershipStatus: "Active",
      membershipStartDate: startDate,
      membershipEndDate: endDate,

      isFirstLogin: true,
    });

    // Create First Membership History
    await Membership.create({
      trainer: req.trainer._id,
      client: client._id,

      badge: membershipBadge,
      durationMonths: membershipDuration,

      startDate,
      endDate,

      totalFees: fees,
      amountPaid: paid,
      balanceDue: balance,

      status: "Active",
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

// ==========================
// Get All Clients
// ==========================
exports.getClients = async (req, res) => {
  try {
    const clients = await Client.find({
      trainer: req.trainer._id,
    }).sort({ createdAt: -1 });

    res.json(clients);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// ==========================
// Get Single Client
// ==========================
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
    res.status(500).json({
      message: err.message,
    });
  }
};


exports.updateClient = async (req, res) => {
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

    // Update client details
    client.name = req.body.name ?? client.name;
    client.email = req.body.email
      ? req.body.email.toLowerCase()
      : client.email;
    client.phone = req.body.phone ?? client.phone;
    client.age = req.body.age ?? client.age;
    client.gender = req.body.gender ?? client.gender;
    client.height = req.body.height ?? client.height;
    client.weight = req.body.weight ?? client.weight;
    client.goal = req.body.goal ?? client.goal;
    client.medicalHistory =
      req.body.medicalHistory ?? client.medicalHistory;
    client.notes = req.body.notes ?? client.notes;

    // Update Total Fees
    if (req.body.totalFees !== undefined) {
      client.totalFees = Number(req.body.totalFees);
    }

    // Get amount already paid from database
    const paidAmount = client.amountPaid;

    // Calculate new balance
    client.balanceDue = client.totalFees - paidAmount;

    // Prevent negative balance
    if (client.balanceDue < 0) {
      client.balanceDue = 0;
    }

    await client.save();

    res.json({
      message: "Client updated successfully",
      client,
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};
// ==========================
// Update Balance
// ==========================
exports.updateBalance = async (req, res) => {
  try {
    const { amount } = req.body;

    const client = await Client.findOne({
      _id: req.params.id,
      trainer: req.trainer._id,
    });

    if (!client) {
      return res.status(404).json({
        message: "Client not found",
      });
    }

    const receiveAmount = Number(amount);

    if (isNaN(receiveAmount) || receiveAmount <= 0) {
      return res.status(400).json({
        message: "Please enter a valid amount",
      });
    }

    if (receiveAmount > client.balanceDue) {
      return res.status(400).json({
        message: "Amount exceeds balance due",
      });
    }

    client.amountPaid += receiveAmount;
    client.balanceDue = client.totalFees - client.amountPaid;

    await client.save();

    res.json(client);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// ==========================
// Delete Client
// ==========================
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
    res.status(500).json({
      message: err.message,
    });
  }
};

// ==========================
// Client Workouts
// ==========================
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

// ==========================
// Client Diets
// ==========================
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

// ==========================
// Client Progress
// ==========================
exports.getMyProgress = async (req, res) => {
  try {
    const progress = await Progress.find({
      client: req.client._id,
    }).sort({
      date: -1,
    });

    res.json(progress);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// ==========================
// Add Client Progress
// ==========================
exports.addMyProgress = async (req, res) => {
  try {
    const {
      weight,
      height,
      notes,
      photo,
      date,
    } = req.body;

    if (!weight) {
      return res.status(400).json({
        message: "Weight is required",
      });
    }

    const effectiveHeight =
      height || req.client.height || 0;

    let bmi = 0;

    if (effectiveHeight) {
      const heightInMeters = effectiveHeight / 100;

      bmi = Number(
        (
          weight /
          (heightInMeters * heightInMeters)
        ).toFixed(1)
      );
    }

    const progress = await Progress.create({
      trainer: req.client.trainer,
      client: req.client._id,
      date: date || Date.now(),
      weight,
      height: effectiveHeight,
      bmi,
      notes: notes || "",
      photo: photo || "",
    });

    res.status(201).json({
      message: "Progress logged successfully",
      progress,
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};