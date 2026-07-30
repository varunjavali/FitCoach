const Membership = require("../models/membership");

exports.getMyMembership = async (req, res) => {
  try {
    const membership = await Membership.findOne({
      client: req.client._id,
      status: "Active",
    });

    if (!membership) {
      return res.status(404).json({
        message: "No active membership found.",
      });
    }

    res.json(membership);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};