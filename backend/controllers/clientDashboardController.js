const Client = require("../models/Client");
const Workout = require("../models/Workout");
const Diet = require("../models/Diet");

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

    // Latest workout/diet assigned for today's weekday
    const [todayWorkoutDoc, todayDietDoc] = await Promise.all([
      Workout.findOne({
        client: client._id,
        day: today,
      }).sort({ createdAt: -1 }),

      Diet.findOne({
        client: client._id,
        day: today,
      }).sort({ createdAt: -1 }),
    ]);

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
      },

      today,

      todayWorkout,

      todayDiet,

      membership: null,

      notifications: [],

      upcomingSession: null,
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};