const express = require('express');
const router = express.Router();
const axios = require('axios');
const Rule = require('../models/rule.model');

// تایید وب‌هوک
router.get('/', (req, res) => {
    const mode = req.query['hub.mode'];
    const token = req.query['hub.verify_token'];
    const challenge = req.query['hub.challenge'];

    if (mode === 'subscribe' && token === process.env.VERIFY_TOKEN) {
        res.status(200).send(challenge);
    } else {
        res.sendStatus(403);
    }
});

// دریافت رویدادها (کامنت جدید)
router.post('/', async (req, res) => {
    const body = req.body;
    if (body.object !== 'instagram') {
        return res.sendStatus(404);
    }

    // خواندن قوانین فعال از دیتابیس
    const activeRules = await Rule.find({ isActive: true });

    body.entry.forEach(entry => {
        entry.changes?.forEach(change => {
            if (change.field === 'comments') {
                const commentData = change.value;
                const commentText = commentData.text.toLowerCase();

                // پیدا کردن اولین قانون منطبق
                const matchedRule = activeRules.find(rule => commentText.includes(rule.keyword));

                if (matchedRule) {
                    replyToComment(commentData.id, matchedRule.replyText);
                } else {
                    console.log('No matching rule found for comment:', commentText);
                }
            }
        });
    });

    res.status(200).send('EVENT_RECEIVED');
});

async function replyToComment(commentId, message) {
    const url = `https://graph.facebook.com/v19.0/${commentId}/replies`;
    const accessToken = process.env.PAGE_ACCESS_TOKEN;

    try {
        await axios.post(url, {
            message: message,
            access_token: accessToken
        });
        console.log(`Successfully replied to comment ${commentId}`);
    } catch (error) {
        console.error('Error replying to comment:', error.response?.data || error.message);
    }
}

module.exports = router;