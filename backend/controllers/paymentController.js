const Payment = require("../models/Payment");
const Client = require("../models/Client");

// Receive Payment
exports.addPayment = async (req, res) => {
  try {
    const trainerId = req.trainer._id;
    const { clientId, amount, paymentMethod, paymentType, remarks } = req.body;

    if (!clientId || !amount || amount <= 0) {
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

    // Save payment transaction
    const receiptNo = await generateReceiptNo();

await Payment.create({
  trainer: trainerId,
  client: clientId,
  receiptNo,
  amount,
  paymentMethod,
  paymentType,
  remarks,
});

    // Update client balance
    client.amountPaid += amount;
    client.balanceDue -= amount;

    if (client.balanceDue < 0) {
      client.balanceDue = 0;
    }

    await client.save();

    res.status(201).json({
      message: "Payment received successfully",
      payment,
      client,
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// Client Payment History
exports.getClientPayments = async (req, res) => {
  try {
    const payments = await Payment.find({
      client: req.params.clientId,
    }).sort({
      createdAt: -1,
    });

    res.json(payments);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// All Payments
exports.getPayments = async (req, res) => {
  try {
    const payments = await Payment.find({
      trainer: req.trainer._id,
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

// Payment Details
exports.getPayment = async (req, res) => {
  try {
    const payment = await Payment.findById(req.params.id)
      .populate("client", "name phone email");

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

// Delete Payment
exports.deletePayment = async (req, res) => {
  try {
    const payment = await Payment.findById(req.params.id);

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
async function generateReceiptNo() {
    const count = await Payment.countDocuments();
  
    const date = new Date();
  
    const y = date.getFullYear();
  
    const m = String(date.getMonth() + 1).padStart(2, "0");
  
    const d = String(date.getDate()).padStart(2, "0");
  
    return `RCPT-${y}${m}${d}-${String(count + 1).padStart(4, "0")}`;
  }