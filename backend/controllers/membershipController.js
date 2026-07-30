const Membership = require("../models/membership");
const Client = require("../models/Client");
const Payment = require("../models/Payment");

// ------------------------------------------------------
// Generate Receipt Number
// ------------------------------------------------------
async function generateReceiptNo() {
    const count = await Payment.countDocuments();

    const date = new Date();

    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, "0");
    const d = String(date.getDate()).padStart(2, "0");

    return `RCPT-${y}${m}${d}-${String(count + 1).padStart(4, "0")}`;
}

// ------------------------------------------------------
// Renew Membership
// ------------------------------------------------------
exports.renewMembership = async (req, res) => {
    try {
        const { clientId } = req.params;

        const {
            badge,
            durationMonths,
            totalFees,
            amountPaid,
            paymentMethod,
            remarks,
        } = req.body;

        const client = await Client.findOne({
            _id: clientId,
            trainer: req.trainer._id,
        });

        if (!client) {
            return res.status(404).json({
                message: "Client not found",
            });
        }

        // Expire previous active memberships
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

        // --------------------------------------------------
        // Create payment entry
        // --------------------------------------------------
        if (paid > 0) {

            const receiptNo = await generateReceiptNo();

            await Payment.create({
                trainer: req.trainer._id,
                client: client._id,

                receiptNo,

                amount: paid,

                paymentMethod: paymentMethod || "Cash",

                paymentType: "Renewal",

                status: "Success",

                remarks: remarks || "Membership Renewal",
            });
        }

        // --------------------------------------------------
        // Update Client
        // --------------------------------------------------
        client.membershipBadge = badge;
        client.membershipDuration = durationMonths;
        client.membershipStatus = "Active";
        client.membershipStartDate = startDate;
        client.membershipEndDate = endDate;

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
        console.error(err);

        res.status(500).json({
            message: err.message,
        });
    }
};

// ------------------------------------------------------
// Membership History
// ------------------------------------------------------
exports.getMembershipHistory = async (req, res) => {
    try {
        const memberships = await Membership.find({
            client: req.params.clientId,
        }).sort({
            createdAt: -1,
        });

        res.json(memberships);

    } catch (err) {
        res.status(500).json({
            message: err.message,
        });
    }
};

// ------------------------------------------------------
// Current Membership
// ------------------------------------------------------
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

// ------------------------------------------------------
// Cancel Membership
// ------------------------------------------------------
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