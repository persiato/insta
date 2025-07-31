const express = require('express');
const router = express.Router();
const Rule = require('../models/rule.model');

// Get all rules
router.get('/', async (req, res) => {
    try {
        const rules = await Rule.find().sort({ createdAt: -1 });
        res.json(rules);
    } catch (err) {
        res.status(500).send('Server Error');
    }
});

// Create a new rule
router.post('/', async (req, res) => {
    try {
        const newRule = new Rule({
            keyword: req.body.keyword,
            replyText: req.body.replyText
        });
        const rule = await newRule.save();
        res.json(rule);
    } catch (err) {
        res.status(500).send('Server Error');
    }
});

// Delete a rule
router.delete('/:id', async (req, res) => {
    try {
        await Rule.findByIdAndDelete(req.params.id);
        res.json({ msg: 'Rule removed' });
    } catch (err) {
        res.status(500).send('Server Error');
    }
});

module.exports = router;