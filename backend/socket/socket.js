const Conversation = require("../models/Conversation");

module.exports = (io) => {

  console.log("✅ Socket Module Loaded");

  io.on("connection", (socket) => {

    console.log("🟢 New Socket Connected:", socket.id);

    socket.onAny((event, ...args) => {
      console.log("📡 Event:", event);
      console.log(args);
    });

    socket.on("joinConversation", ({ trainerId, clientId }) => {

      console.log("JOIN EVENT RECEIVED");

      console.log("Trainer:", trainerId);
      console.log("Client :", clientId);

      const room = `${trainerId}_${clientId}`;

      socket.join(room);

      console.log(`📥 Joined ${room}`);
    });

    socket.on("sendMessage", async (data) => {
      console.log("SEND MESSAGE EVENT");
      console.log(data);

      try {
        const {
          trainerId,
          clientId,
          sender,
          text,
          type,
          mediaUrl,
        } = data;

        let conversation = await Conversation.findOne({
          trainer: trainerId,
          client: clientId,
        });

        if (!conversation) {
          conversation = await Conversation.create({
            trainer: trainerId,
            client: clientId,
            messages: [],
          });
        }

        const message = {
          sender,
          type: type || "text",
          text: text || "",
          mediaUrl: mediaUrl || null,
          isRead: false,
          createdAt: new Date(),
        };

        conversation.messages.push(message);

        await conversation.save();

        io.to(`${trainerId}_${clientId}`).emit(
          "newMessage",
          message,
        );

        console.log("✅ Message Broadcasted");

      } catch (err) {
        console.log(err);
      }
    });

    socket.on("disconnect", () => {
      console.log("🔴 Socket Disconnected:", socket.id);
    });

  });

};