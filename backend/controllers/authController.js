const Trainer = require("../models/Trainer");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const Client = require("../models/Client");

// Register
exports.register = async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;

    const exists = await Trainer.findOne({ email });

    if (exists) {
      return res.status(400).json({
        message: "Email already exists",
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const trainer = await Trainer.create({
      name,
      email,
      phone,
      password: hashedPassword,
    });

    res.status(201).json({
      message: "Registration Successful",
      trainer,
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// Login
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const trainer = await Trainer.findOne({ email });

    if (!trainer) {
      return res.status(400).json({
        message: "Invalid Email",
      });
    }

    const match = await bcrypt.compare(password, trainer.password);

    if (!match) {
      return res.status(400).json({
        message: "Invalid Password",
      });
    }

    const token = jwt.sign(
      {
        id: trainer._id,
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "7d",
      }
    );

    res.json({
      message: "Login Successful",
      token,
      trainer,
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};
// Client Login
exports.clientLogin = async (req, res) => {
  try {
    const { email, password } = req.body;

    const client = await Client.findOne({
      email,
      isActive: true,
    });

    if (!client) {
      return res.status(400).json({
        message: "Invalid Email",
      });
    }

    const match = await bcrypt.compare(
      password,
      client.password,
    );

    if (!match) {
      return res.status(400).json({
        message: "Invalid Password",
      });
    }

    client.lastLogin = new Date();

    if (client.isFirstLogin) {
      client.isFirstLogin = false;
    }

    await client.save();

    const token = jwt.sign(
      {
        id: client._id,
        role: "client",
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "7d",
      },
    );

    res.json({
      message: "Login Successful",
      token,
      firstLogin: client.isFirstLogin,
      client,
    });

  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};
exports.clientChangePassword = async (req, res) => {
  try {
    const {
      currentPassword,
      newPassword,
    } = req.body;

    const client = await Client.findById(
      req.client._id
    );

    const match = await bcrypt.compare(
      currentPassword,
      client.password
    );

    if (!match) {
      return res.status(400).json({
        message: "Current password is incorrect",
      });
    }

    client.password = await bcrypt.hash(
      newPassword,
      10
    );

    client.isFirstLogin = false;

    await client.save();

    res.json({
      message: "Password changed successfully",
    });

  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};