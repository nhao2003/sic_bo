import express from "express";
import GameController from "./src/game_controller.js";
import cors from "cors";
import http from "http";
import { Server } from "socket.io";

const app = express();
const port = 3000;
app.use(
  cors({
    origin: "*",
  })
);
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
  },
});
const controller = new GameController();

app.get("/", (req, res) => {
  res.send("Hello World!");
});

// Start game
app.get("/start", async (req, res) => {
  try {
    await controller.start();
    const state = await controller.getGameState();
    const response = {
      message: "Game started",
      state,
    };
    io.emit("state", response);
    res.status(200).json(response);
  } catch (error) {
    console.log(error);
    res.status(500).send({
      message: error.message,
    });
  }
});

app.get("/state", async (req, res) => {
  try {
    const state = await controller.getGameState();
    const response = {
      message: state ? "Game state" : "Game has not started yet",
      state,
    };
    res.status(200).json(response);
    io.emit("state", response);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
});

app.get("/settle", async (req, res) => {
  if (controller.isFinished) {
    return res.status(400).json({
      message: "Game has already been settled",
    });
  }
  try {
    const state = await controller.getGameState();
    io.emit("state", {
      message: "Game is settling",
      state: {
        ...state,
        isSettling: !state.isFinished,
      },
    });
    await controller.settle();
    const newState = await controller.getGameState();
    const response = {
      message: "Game settled",
      state: {
        ...newState,
        isSettling: false,
      }
    };
    io.emit("state", response);
    res.status(200).json(response);
  } catch (error) {
    console.log(error);
    res.status(500).json({
      message: error.message,
    });
  }
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send("Something broke!");
});

// When user connects, send the game state
io.on("connection", async (socket) => {
  console.log("a user connected");
  const state = await controller.getGameState();
  io.emit("state", {
    message: state ? "Game state" : "Game has not started yet",
    state,
  });
  socket.on("disconnect", () => {
    console.log("user disconnected");
  });
});

server.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
