const Payment = require("../models/Payment");
const Client = require("../models/Client");

// ======================================================
// Generate Receipt Number
// ------------------------------------------------------
// Scoped to today's date, and based on the highest existing
// receipt number for today (not a raw document count), so
// deleting a payment never causes a number to be reused.
// ======================================================
async function generateReceiptNo() {
  const date = new Date();

  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, "0");
  const d = String(date.getDate()).padStart(2, "0");

  const prefix = `RCPT-${y}${m}${d}-`;

  // Find today's highest receipt number, not a count of documents.
  const lastToday = await Payment.findOne({
    receiptNo: { $regex: `^${prefix}` },
  }).sort({ receiptNo: -1 });

  let nextSeq = 1;

  if (lastToday) {
    const lastSeq = parseInt(lastToday.receiptNo.split("-").pop(), 10);
    nextSeq = (isNaN(lastSeq) ? 0 : lastSeq) + 1;
  }

  return `${prefix}${String(nextSeq).padStart(4, "0")}`;
}

// ======================================================
// Add Payment
// ======================================================

exports.addPayment = async (req, res) => {
  try {
    const trainerId = req.trainer._id;

    const { clientId, amount, paymentMethod, paymentType, remarks } =
      req.body;

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

    // Retry a few times in case of a rare race condition where two
    // requests generate the same receipt number at the same instant.
    let payment;
    let lastErr;

    for (let attempt = 0; attempt < 3; attempt++) {
      try {
        const receiptNo = await generateReceiptNo();

        payment = await Payment.create({
          trainer: trainerId,
          client: clientId,
          receiptNo,
          amount,
          paymentMethod,
          paymentType,
          remarks,
        });

        lastErr = null;
        break;
      } catch (err) {
        // Duplicate key error on receiptNo -> retry with a fresh number.
        if (err.code === 11000 && err.keyPattern?.receiptNo) {
          lastErr = err;
          continue;
        }
        throw err;
      }
    }

    if (lastErr) {
      throw lastErr;
    }

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