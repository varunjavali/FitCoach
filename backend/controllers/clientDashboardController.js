const Client = require("../models/Client");
const Workout = require("../models/Workout");
const Diet = require("../models/Diet");
const Membership = require("../models/Membership");

const WEEKDAYS = [
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
];

exports.getDashboard = async (req, res) => {
  try {
    const client = await Client.findById(req.client._id).select("-password");

    if (!client) {
      return res.status(404).json({
        message: "Client not found",
      });
    }

    const today = WEEKDAYS[new Date().getDay()];

    // Latest workout for today
    const todayWorkoutDoc = await Workout.findOne({
      client: client._id,
      day: today,
    }).sort({ createdAt: -1 });

    // Latest diet for today
    const todayDietDoc = await Diet.findOne({
      client: client._id,
      day: today,
    }).sort({ createdAt: -1 });

    // Current active membership
    const membershipDoc = await Membership.findOne({
      client: client._id,
      status: "Active",
    }).sort({ createdAt: -1 });

    const todayWorkout = todayWorkoutDoc
      ? {
          id: todayWorkoutDoc._id,
          title: todayWorkoutDoc.title,
          exerciseCount: todayWorkoutDoc.exercises.length,
        }
      : null;

    const todayDiet = todayDietDoc
      ? {
          id: todayDietDoc._id,
          title: todayDietDoc.title,
          calories: todayDietDoc.meals.reduce(
            (sum, meal) => sum + (meal.calories || 0),
            0
          ),
        }
      : null;

    const membership = membershipDoc
      ? {
          id: membershipDoc._id,
          badge: membershipDoc.badge,
          durationMonths: membershipDoc.durationMonths,
          startDate: membershipDoc.startDate,
          endDate: membershipDoc.endDate,
          totalFees: membershipDoc.totalFees,
          amountPaid: membershipDoc.amountPaid,
          balanceDue: membershipDoc.balanceDue,
          status: membershipDoc.status,
          remarks: membershipDoc.remarks,
        }
      : null;

    res.json({
      client: {
        id: client._id,
        name: client.name,
        email: client.email,
        phone: client.phone,
        age: client.age,
        gender: client.gender,
        height: client.height,
        weight: client.weight,
        goal: client.goal,
        joiningDate: client.joiningDate,
        totalFees: client.totalFees,
        amountPaid: client.amountPaid,
        balanceDue: client.balanceDue,
      },

      today,

      todayWorkout,

      todayDiet,

      membership,

      notifications: [],

      upcomingSession: null,
    });
  } catch (err) {
    console.error(err);

    res.status(500).json({
      message: err.message,
    });
  }
};