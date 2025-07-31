const fs = require('fs');
const path = require('path');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// REMOVED: Database URL question is gone
const questions = [
  'Enter your custom Webhook Verify Token:',
  'Enter your Facebook Page Access Token (Long-lived):',
  'Enter the Port for the backend server (default: 5000):'
];

const keys = ['VERIFY_TOKEN', 'PAGE_ACCESS_TOKEN', 'PORT'];
const answers = {};
let i = 0;

console.log('--- Simplified Interactive Setup ---');

const askQuestion = () => {
  if (i < questions.length) {
    rl.question(questions[i] + ' ', (answer) => {
      answers[keys[i]] = answer || (keys[i] === 'PORT' ? '5000' : '');
      i++;
      askQuestion();
    });
  } else {
    const envPath = path.join(__dirname, 'backend', '.env');
    
    // Create content from user answers
    let envContent = Object.entries(answers)
        .map(([key, value]) => `${key}=${value}`)
        .join('\n');
    
    // ADDED: Automatically add the local MongoDB URI
    envContent += '\nMONGO_URI=mongodb://localhost:27017/instagram_bot';
    envContent += '\nNODE_ENV=production';
    
    fs.writeFileSync(envPath, envContent);
    console.log(`\n✅ Configuration saved to ${envPath}`);
    console.log('Database URI was set automatically!');
    rl.close();
  }
};

askQuestion();