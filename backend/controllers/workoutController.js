const Workout = require("../models/Workout");

// Create Workout
exports.createWorkout = async (req, res) => {
  try {
    const workout = await Workout.create({
      trainer: req.trainer._id,
      client: req.body.client,
      title: req.body.title,
      day: req.body.day,
      exercises: req.body.exercises,
    });

    res.status(201).json({
      message: "Workout created successfully",
      workout,
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// Get All Workouts
exports.getWorkouts = async (req, res) => {
  try {
    const workouts = await Workout.find({
      trainer: req.trainer._id,
    })
      .populate("client", "name")
      .sort({ createdAt: -1 });

    res.json(workouts);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// Get Single Workout
exports.getWorkout = async (req, res) => {
  try {
    const workout = await Workout.findOne({
      _id: req.params.id,
      trainer: req.trainer._id,
    }).populate("client", "name");

    if (!workout) {
      return res.status(404).json({
        message: "Workout not found",
      });
    }

    res.json(workout);
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// Update Workout
exports.updateWorkout = async (req, res) => {
  try {
    const workout = await Workout.findOneAndUpdate(
      {
        _id: req.params.id,
        trainer: req.trainer._id,
      },
      {
        client: req.body.client,
        title: req.body.title,
        day: req.body.day,
        exercises: req.body.exercises,
      },
      { new: true }
    );

    if (!workout) {
      return res.status(404).json({
        message: "Workout not found",
      });
    }

    res.json({
      message: "Workout updated successfully",
      workout,
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

// Delete Workout
exports.deleteWorkout = async (req, res) => {
  try {
    const workout = await Workout.findOneAndDelete({
      _id: req.params.id,
      trainer: req.trainer._id,
    });

    if (!workout) {
      return res.status(404).json({
        message: "Workout not found",
      });
    }

    res.json({
      message: "Workout deleted successfully",
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};
// Get workouts of a specific client
exports.getClientWorkouts = async (req, res) => {
    try {
        const workouts = await Workout.find({
            trainer: req.trainer._id,
            client: req.params.clientId,
          })
          .populate("client", "name")
          .sort({
            createdAt: -1,
          });
  
      res.json(workouts);
    } catch (err) {
      res.status(500).json({
        message: err.message,
      });
    }
  };