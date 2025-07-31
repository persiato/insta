require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');

// Connect to Database
connectDB();

const app = express();

// Middlewares
app.use(cors()); // برای اجازه دسترسی از فرانت‌اند
app.use(express.json());

// API Routes
app.use('/webhook', require('./api/webhook'));
app.use('/api/rules', require('./api/rules'));

// Serve frontend build in production
if (process.env.NODE_ENV === 'production') {
    app.use(express.static('../../frontend/build'));
    const path = require('path');
    app.get('*', (req, res) => {
        res.sendFile(path.resolve(__dirname, '..', '..', 'frontend', 'build', 'index.html'));
    });
}


const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Backend server running on port ${PORT}`));