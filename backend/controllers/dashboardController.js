const Client = require("../models/Client");

exports.getDashboard = async (req, res) => {
  try {
    const trainerId = req.trainer._id;

    const clients = await Client.find({ trainer: trainerId });

    const totalClients = clients.length;

    const activeMembers = clients.filter(
      (c) => c.membershipStatus === "Active"
    ).length;

    const expiredMembers = clients.filter(
      (c) => c.membershipStatus === "Expired"
    ).length;

    const monthlyRevenue = clients.reduce(
      (sum, c) => sum + (c.amountPaid || 0),
      0
    );

    const pendingPayments = clients.reduce(
      (sum, c) => sum + (c.balanceDue || 0),
      0
    );
    console.log({
      totalClients: clients.length,
      firstClient: clients[0],
    });

    const today = new Date();
    const next7 = new Date();
    next7.setDate(today.getDate() + 7);

    const expiringSoon = clients.filter((c) => {
      if (!c.membershipEndDate) return false;

      const endDate = new Date(c.membershipEndDate);

      return endDate >= today && endDate <= next7;
    }).length;

    const recentClients = clients
      .sort((a, b) => b.createdAt - a.createdAt)
      .slice(0, 5);

    res.json({
      trainerName: req.trainer.name,

      totalClients,
      activeMembers,
      expiredMembers,

      monthlyRevenue,
      pendingPayments,
      expiringSoon,

      recentClients,
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};