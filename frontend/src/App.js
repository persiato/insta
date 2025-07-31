import React, { useState, useEffect } from 'react';
import axios from 'axios';
import 'bootstrap/dist/css/bootstrap.min.css';
import './index.css';

function App() {
    const [rules, setRules] = useState([]);
    const [keyword, setKeyword] = useState('');
    const [replyText, setReplyText] = useState('');

    useEffect(() => {
        fetchRules();
    }, []);

    const fetchRules = async () => {
        const res = await axios.get('/api/rules');
        setRules(res.data);
    };

    const handleAddRule = async (e) => {
        e.preventDefault();
        if (!keyword || !replyText) return;
        const newRule = { keyword, replyText };
        await axios.post('/api/rules', newRule);
        setKeyword('');
        setReplyText('');
        fetchRules();
    };

    const handleDeleteRule = async (id) => {
        await axios.delete(`/api/rules/${id}`);
        fetchRules();
    };

    return (
        <div className="container mt-5">
            <h1 className="text-center mb-4">🤖 مدیریت پاسخ‌های خودکار اینستاگرام</h1>

            <div className="card mb-4">
                <div className="card-header">
                    افزودن قانون جدید
                </div>
                <div className="card-body">
                    <form onSubmit={handleAddRule}>
                        <div className="mb-3">
                            <label className="form-label">کلمه کلیدی (مثلا: قیمت)</label>
                            <input
                                type="text"
                                className="form-control"
                                value={keyword}
                                onChange={(e) => setKeyword(e.target.value)}
                            />
                        </div>
                        <div className="mb-3">
                            <label className="form-label">متن پاسخ</label>
                            <textarea
                                className="form-control"
                                rows="3"
                                value={replyText}
                                onChange={(e) => setReplyText(e.target.value)}
                            ></textarea>
                        </div>
                        <button type="submit" className="btn btn-primary">افزودن</button>
                    </form>
                </div>
            </div>

            <h2>لیست قوانین فعال</h2>
            <ul className="list-group">
                {rules.map(rule => (
                    <li key={rule._id} className="list-group-item d-flex justify-content-between align-items-center">
                        <div>
                            <strong>کلمه کلیدی:</strong> <span className="badge bg-secondary">{rule.keyword}</span>
                            <p className="mb-0 mt-2"><strong>پاسخ:</strong> {rule.replyText}</p>
                        </div>
                        <button onClick={() => handleDeleteRule(rule._id)} className="btn btn-danger btn-sm">حذف</button>
                    </li>
                ))}
            </ul>
        </div>
    );
}

export default App;