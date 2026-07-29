const Client = require("../models/Client");
const Payment = require("../models/Payment");



exports.getDashboard = async (req, res) => {
 
  try {
    const trainerId = req.trainer._id;

    // Clients
    const clients = await Client.find({ trainer: trainerId });

    const totalClients = clients.length;

    const activeMembers = clients.filter(
      (c) => c.membershipStatus === "Active"
    ).length;

    const expiredMembers = clients.filter(
      (c) => c.membershipStatus === "Expired"
    ).length;

    const pendingBalance = clients.reduce(
      (sum, c) => sum + (c.balanceDue || 0),
      0
    );

    // Today's collection
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const todayResult = await Payment.aggregate([
      {
        $match: {
          trainer: trainerId,
          status: "Success",
          createdAt: { $gte: today },
        },
      },
      {
        $group: {
          _id: null,
          total: { $sum: "$amount" },
        },
      },
    ]);

    // Current month's revenue
    const monthStart = new Date(
      today.getFullYear(),
      today.getMonth(),
      1
    );

    const monthResult = await Payment.aggregate([
      {
        $match: {
          trainer: trainerId,
          status: "Success",
          createdAt: { $gte: monthStart },
        },
      },
      {
        $group: {
          _id: null,
          total: { $sum: "$amount" },
        },
      },
    ]);

    // Total revenue
    const totalRevenueResult = await Payment.aggregate([
      {
        $match: {
          trainer: trainerId,
          status: "Success",
        },
      },
      {
        $group: {
          _id: null,
          total: { $sum: "$amount" },
        },
      },
    ]);

    // Payment count
    const totalTransactions = await Payment.countDocuments({
      trainer: trainerId,
      status: "Success",
    });

    // Expiring memberships (next 7 days)
    const nextWeek = new Date();
    nextWeek.setDate(nextWeek.getDate() + 7);

    const expiringSoon = clients.filter((c) => {
      if (!c.membershipEndDate) return false;

      return (
        c.membershipStatus === "Active" &&
        c.membershipEndDate <= nextWeek
      );
    }).length;

    res.json({
      trainerName: req.trainer.name,

      totalClients,
      activeMembers,
      expiredMembers,
      expiringSoon,

      todayCollection: todayResult[0]?.total || 0,

      monthlyRevenue: monthResult[0]?.total || 0,

      totalRevenue: totalRevenueResult[0]?.total || 0,

      pendingBalance,

      totalTransactions,
    });
    
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};