const Membership = require("../models/Membership");

exports.getMyMembership = async (req, res) => {
  try {
    console.log("========== CLIENT MEMBERSHIP ==========");
    console.log("Logged-in Client ID:", req.client._id.toString());

    const membership = await Membership.findOne({
      client: req.client._id,
      status: "Active",
    });

    console.log("Membership Found:", membership);

    if (!membership) {
      return res.status(404).json({
        message: "No active membership found.",
      });
    }

    return res.json(membership);

  } catch (err) {
    console.error("Membership Error:", err);

    return res.status(500).json({
      message: err.message,
    });
  }
};