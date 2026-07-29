const Membership = require("../models/membership");
const Client = require("../models/Client");

//
// Renew Membership
//
exports.renewMembership = async (req, res) => {
  try {
    const { clientId } = req.params;

    const {
      badge,
      durationMonths,
      totalFees,
      amountPaid,
      remarks,
    } = req.body;

    const client = await Client.findById(clientId);

    if (!client) {
      return res.status(404).json({
        message: "Client not found",
      });
    }

    // Expire old memberships
    await Membership.updateMany(
      {
        client: clientId,
        status: "Active",
      },
      {
        status: "Expired",
      }
    );

    const fees = Number(totalFees) || 0;
    const paid = Number(amountPaid) || 0;
    const balanceDue = Math.max(fees - paid, 0);

    const startDate = new Date();

    const endDate = new Date(startDate);
    endDate.setMonth(
      endDate.getMonth() + Number(durationMonths)
    );

    const membership = await Membership.create({
      trainer: req.trainer._id,
      client: client._id,

      badge,
      durationMonths,

      startDate,
      endDate,

      totalFees: fees,
      amountPaid: paid,
      balanceDue,

      remarks,

      status: "Active",
    });

    client.membershipBadge = badge;
    client.membershipDuration = durationMonths;
    client.membershipStatus = "Active";
    client.membershipStartDate = startDate;
    client.membershipEndDate = endDate;

    // Temporary
    client.totalFees = fees;
    client.amountPaid = paid;
    client.balanceDue = balanceDue;

    await client.save();

    res.status(200).json({
      message: "Membership renewed successfully",
      membership,
      client,
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

//
// Membership History
//
exports.getMembershipHistory = async (req, res) => {
  try {
    const memberships = await Membership.find({
      client: req.params.clientId,
    })
      .sort({
        createdAt: -1,
      });

    res.json(memberships);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

//
// Current Membership
//
exports.getCurrentMembership = async (req, res) => {
  try {
    const membership = await Membership.findOne({
      client: req.params.clientId,
      status: "Active",
    });

    if (!membership) {
      return res.status(404).json({
        message: "No active membership",
      });
    }

    res.json(membership);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

//
// Cancel Membership
//
exports.cancelMembership = async (req, res) => {
  try {
    const membership = await Membership.findById(
      req.params.membershipId
    );

    if (!membership) {
      return res.status(404).json({
        message: "Membership not found",
      });
    }

    membership.status = "Cancelled";

    await membership.save();

    await Client.findByIdAndUpdate(
      membership.client,
      {
        membershipStatus: "Cancelled",
      }
    );

    res.json({
      message: "Membership cancelled successfully",
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};