const mongoose = require("mongoose");

const paymentSchema = new mongoose.Schema(
  {
    trainer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Trainer",
      required: true,
    },

    client: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Client",
      required: true,
    },

    receiptNo: {
      type: String,
      unique: true,
    },

    amount: {
      type: Number,
      required: true,
    },

    paymentMethod: {
      type: String,
      enum: ["Cash", "UPI", "Card", "Bank"],
      default: "Cash",
    },

    paymentType: {
      type: String,
      enum: ["Membership", "Renewal", "Balance", "Refund"],
      default: "Membership",
    },

    status: {
      type: String,
      enum: ["Success", "Cancelled", "Refunded"],
      default: "Success",
    },

    remarks: {
      type: String,
      default: "",
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Payment", paymentSchema);
