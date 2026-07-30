const Payment = require("../models/Payment");
const Client = require("../models/Client");

exports.getPaymentHistory = async (req, res) => {
  try {
    // Fetch payment summary from Client
    const client = await Client.findById(req.client._id).select(
      "totalFees amountPaid balanceDue"
    );

    if (!client) {
      return res.status(404).json({
        success: false,
        message: "Client not found",
      });
    }

    // Fetch payment history
    const payments = await Payment.find({
      client: req.client._id,
    })
      .sort({ createdAt: -1 })
      .select(
        "receiptNo amount paymentMethod paymentType status remarks createdAt"
      );

    res.status(200).json({
      success: true,
      summary: {
        totalFees: client.totalFees,
        amountPaid: client.amountPaid,
        balanceDue: client.balanceDue,
      },
      payments,
    });
  } catch (error) {
    console.error("Payment History Error:", error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch payment history.",
    });
  }
};