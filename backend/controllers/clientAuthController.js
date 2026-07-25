const Client = require("../models/Client");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

// Client Login
exports.loginClient = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Check email
    const client = await Client.findOne({
      email: email.toLowerCase(),
    });

    if (!client) {
      return res.status(401).json({
        message: "Invalid email or password",
      });
    }

    // Check password
    const isMatch = await bcrypt.compare(
      password,
      client.password
    );

    if (!isMatch) {
      return res.status(401).json({
        message: "Invalid email or password",
      });
    }

    // Update last login
    client.lastLogin = new Date();
    await client.save();

    // Generate JWT
    const token = jwt.sign(
      {
        id: client._id,
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "7d",
      }
    );

    res.json({
      message: "Login successful",

      token,

      firstLogin: client.isFirstLogin,

      client: {
        id: client._id,
        name: client.name,
        email: client.email,
      },
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};
// Change Password
exports.changePassword = async (req, res) => {
    try {
      const { currentPassword, newPassword } = req.body;
  
      const client = req.client;
  
      // Verify current password
      const isMatch = await bcrypt.compare(
        currentPassword,
        client.password
      );
  
      if (!isMatch) {
        return res.status(400).json({
          message: "Current password is incorrect",
        });
      }
  
      // Hash new password
      const hashedPassword = await bcrypt.hash(newPassword, 10);
  
      client.password = hashedPassword;
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