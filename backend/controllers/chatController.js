const Conversation = require("../models/Conversation");

//
// Upload a chat media file (image/audio/video) and return its URL.
// Used by both the trainer and client apps before the message is
// sent over the socket connection.
//
exports.uploadChatMedia = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        message: "No file uploaded",
      });
    }

    const url = `/uploads/chat/${req.file.filename}`;

    res.json({
      url,
      mimeType: req.file.mimetype,
    });
  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

//
// Trainer loads conversation
//
exports.getConversation = async (req, res) => {
  try {

    let conversation = await Conversation.findOne({
      trainer: req.trainer._id,
      client: req.params.clientId,
    });

    if (!conversation) {
      conversation = {
        messages: [],
      };
    }

    res.json(conversation);

  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

//
// Client loads own conversation
//
exports.getMyConversation = async (req, res) => {
  try {

    let conversation = await Conversation.findOne({
      trainer: req.client.trainer,
      client: req.client._id,
    });

    if (!conversation) {
      conversation = {
        messages: [],
      };
    }

    res.json(conversation);

  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};

//
// Mark trainer messages as read
//
exports.markAsRead = async (req, res) => {
  try {

    await Conversation.updateOne(
      {
        trainer: req.client.trainer,
        client: req.client._id,
      },
      {
        $set: {
          "messages.$[msg].isRead": true,
        },
      },
      {
        arrayFilters: [
          {
            "msg.sender": "trainer",
            "msg.isRead": false,
          },
        ],
      }
    );

    res.json({
      message: "Messages marked as read",
    });

  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};