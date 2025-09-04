import express from 'express';
import dotenv from 'dotenv';
import cors from "cors";
import routes from './routes/auth.route.js';
import userRoutes from './routes/user.route.js';

dotenv.config({ quiet: true });

const app = express();
const PORT = process.env.PORT;

// console.log(process.env.DB_USER, process.env.DB_HOST, process.env.DB_NAME, process.env.DB_PASSWORD, process.env.DB_PORT);

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
    res.send("Welcome to the PigyBank API!");
});

app.use("/api", routes);
app.use("/api/v1/", userRoutes);

const startServer = () => {
    app.listen(PORT, () => {
        console.log(`Server is running on port ${PORT}`);
    });
};

// Don't forget to call the function!
startServer();