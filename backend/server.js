require("dotenv").config();

const express = require("express");
const cors = require("cors");
const http = require("http");
const path = require("path");
const { Server } = require("socket.io");

const connectDB = require("./config/database");


// Routes

const authRoutes = require("./routes/authRoutes");
const clientRoutes = require("./routes/clientRoutes");
const workoutRoutes = require("./routes/workoutRoutes");
const dietRoutes = require("./routes/dietRoutes");
const progressRoutes = require("./routes/progressRoutes");
const dashboardRoutes = require("./routes/dashboardRoutes");
const clientDashboardRoutes = require("./routes/clientDashboardRoutes");
const clientAuthRoutes = require("./routes/clientAuthRoutes");
const chatRoutes = require("./routes/chatRoutes");
const membershipRoutes = require("./routes/membershipRoutes");
const paymentRoutes = require("./routes/paymentRoutes");
const clientMembershipRoutes = require("./routes/clientMembershipRoutes");
const clientPaymentRoutes = require("./routes/clientPaymentRoutes");

// Socket
const initializeSocket = require("./socket/socket");

// Middleware
const authMiddleware = require("./middleware/authMiddleware");

const app = express();
const server = http.createServer(app);

// ==================================
// Socket.IO
// ==================================
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});


// Make io available everywhere
app.set("io", io);

// Initialize Socket Events
initializeSocket(io);

// ==================================
// Database
// ==================================
connectDB();

// ==================================
// Middleware
// ==================================
app.use(cors());
app.use(express.json());

// ==================================
// Static files (chat media uploads)
// ==================================
app.use("/uploads", express.static(path.join(__dirname, "uploads")));
app.use("/api/payments", paymentRoutes);


app.use(
  "/api/client-membership",
  clientMembershipRoutes
);
app.use(
  "/api/client-payments",
  clientPaymentRoutes
);

// ==================================
// Trainer APIs
// ==================================
app.use("/api/auth", authRoutes);
app.use("/api/dashboard", dashboardRoutes);
app.use("/api/memberships", membershipRoutes);
app.use("/api/clients", clientRoutes);
app.use("/api/workouts", workoutRoutes);
app.use("/api/diets", dietRoutes);
app.use("/api/progress", progressRoutes);

// ==================================
// Client APIs
// ==================================
app.use("/api/client-auth", clientAuthRoutes);
app.use("/api/client-dashboard", clientDashboardRoutes);

// ==================================
// Chat APIs
// ==================================
app.use("/api/chat", chatRoutes);

// ==================================
// Home
// ==================================
app.get("/", (req, res) => {
  res.send("FitCoach API Running");
});


// Trainer Profile

app.get("/api/profile", authMiddleware, (req, res) => {
  res.json(req.trainer);
});


// Start Server

const PORT = process.env.PORT || 5000;

server.listen(PORT, () => {
  console.log(` Server running on port ${PORT}`);
});