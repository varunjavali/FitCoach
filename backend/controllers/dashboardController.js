const Client = require("../models/Client");

exports.getDashboard = async (req, res) => {
  try {
    const trainerId = req.trainer._id;

    // Total Clients
    const totalClients = await Client.countDocuments({
      trainer: trainerId,
    });

    // Latest 5 Clients
    const recentClients = await Client.find({
      trainer: trainerId,
    })
      .sort({ createdAt: -1 })
      .limit(5);

    // Dummy values for now
    const dashboard = {
      trainerName: req.trainer.name,
      totalClients,
      monthlyRevenue: 0,
      pendingPayments: 0,
      todaySessions: 0,
      recentClients,
    };

    res.json(dashboard);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};