const Payment = require("../models/Payment");
const Client = require("../models/Client");

// ======================================================
// Generate Receipt Number
// ======================================================
function generateReceiptNo(paymentId) {
  const now = new Date();

  const y = now.getFullYear();
  const m = String(now.getMonth() + 1).padStart(2, "0");
  const d = String(now.getDate()).padStart(2, "0");

  const unique = paymentId.toString().slice(-8).toUpperCase();

  return `RCPT-${y}${m}${d}-${unique}`;
}

// ======================================================
// Add Payment
// ======================================================

exports.addPayment = async (req, res) => {
  try {
    const trainerId = req.trainer._id;

    const {
      clientId,
      amount,
      paymentMethod,
      paymentType,
      remarks,
    } = req.body;

    if (!clientId || !amount || Number(amount) <= 0) {
      return res.status(400).json({
        message: "Invalid payment details",
      });
    }

    const client = await Client.findOne({
      _id: clientId,
      trainer: trainerId,
    });

    if (!client) {
      return res.status(404).json({
        message: "Client not found",
      });
    }

    // Create payment without receipt number first
    const payment = new Payment({
      trainer: trainerId,
      client: clientId,
      amount,
      paymentMethod,
      paymentType,
      remarks,
    });

    // Generate unique receipt number using Mongo ObjectId
    payment.receiptNo = generateReceiptNo(payment._id);

    await payment.save();

    // Update client balance
    client.amountPaid += Number(amount);
    client.balanceDue -= Number(amount);

    if (client.balanceDue < 0) {
      client.balanceDue = 0;
    }

    await client.save();

    const savedPayment = await Payment.findById(payment._id).populate(
      "client",
      "name phone email"
    );

    res.status(201).json({
      message: "Payment received successfully",
      payment: savedPayment,
      client,
    });
  } catch (err) {
    console.error(err);

    res.status(500).json({
      message: err.message,
    });
  }
};

// ======================================================
// Get All Payments
// ======================================================

exports.getPayments = async (req, res) => {
  try {
    const payments = await Payment.find({
      trainer: req.trainer._id,
    })
      .populate("client", "name phone email")
      .sort({
        createdAt: -1,
      });

    res.json(payments);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// ======================================================
// Get Client Payment History
// ======================================================

exports.getClientPayments = async (req, res) => {
  try {
    const client = await Client.findOne({
      _id: req.params.clientId,
      trainer: req.trainer._id,
    });

    if (!client) {
      return res.status(404).json({
        message: "Client not found",
      });
    }

    const payments = await Payment.find({
      trainer: req.trainer._id,
      client: req.params.clientId,
    })
      .populate("client", "name phone")
      .sort({
        createdAt: -1,
      });

    res.json(payments);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// ======================================================
// Get Single Payment
// ======================================================

exports.getPayment = async (req, res) => {
  try {
    const payment = await Payment.findOne({
      _id: req.params.id,
      trainer: req.trainer._id,
    }).populate("client", "name phone email");

    if (!payment) {
      return res.status(404).json({
        message: "Payment not found",
      });
    }

    res.json(payment);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// ======================================================
// Delete Payment
// ======================================================

exports.deletePayment = async (req, res) => {
  try {
    const payment = await Payment.findOne({
      _id: req.params.id,
      trainer: req.trainer._id,
    });

    if (!payment) {
      return res.status(404).json({
        message: "Payment not found",
      });
    }

    const client = await Client.findById(payment.client);

    if (client) {
      client.amountPaid -= payment.amount;

      if (client.amountPaid < 0) {
        client.amountPaid = 0;
      }

      client.balanceDue += payment.amount;

      await client.save();
    }

    await payment.deleteOne();

    res.json({
      message: "Payment deleted successfully",
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};