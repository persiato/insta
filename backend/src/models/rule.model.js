const mongoose = require('mongoose');

const RuleSchema = new mongoose.Schema({
    keyword: {
        type: String,
        required: true,
        trim: true,
        lowercase: true
    },
    replyText: {
        type: String,
        required: true
    },
    isActive: {
        type: Boolean,
        default: true
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Rule', RuleSchema);