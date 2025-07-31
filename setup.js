const fs = require('fs');
const path = require('path');
// برای این اسکریپت ساده، از readline داخلی خود نود استفاده می‌کنیم
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const questions = [
  'Enter your MongoDB Connection URI:',
  'Enter your custom Webhook Verify Token:',
  'Enter your Facebook Page Access Token (Long-lived):',
  'Enter the Port for the backend server (default: 5000):'
];

const keys = ['MONGO_URI', 'VERIFY_TOKEN', 'PAGE_ACCESS_TOKEN', 'PORT'];
const answers = {};
let i = 0;

console.log('--- Interactive Setup for Instagram Bot ---');

const askQuestion = () => {
  if (i < questions.length) {
    rl.question(questions[i] + ' ', (answer) => {
      answers[keys[i]] = answer || (keys[i] === 'PORT' ? '5000' : '');
      i++;
      askQuestion();
    });
  } else {
    const envPath = path.join(__dirname, 'backend', '.env');
    const envContent = Object.entries(answers).map(([key, value]) => `${key}=${value}`).join('\n');
    envContent += '\nNODE_ENV=production';
    
    fs.writeFileSync(envPath, envContent);
    console.log(`\n✅ Configuration saved to ${envPath}`);
    rl.close();
  }
};

askQuestion();