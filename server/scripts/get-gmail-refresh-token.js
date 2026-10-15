'use strict';

const http = require('node:http');
const dotenv = require('dotenv');
const { google } = require('googleapis');

dotenv.config();

const clientId = process.env.GOOGLE_CLIENT_ID;
const clientSecret = process.env.GOOGLE_CLIENT_SECRET;
const redirectUri = 'http://localhost:3000/oauth2callback';

if (!clientId || !clientSecret) {
  console.error('Set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET before running this script.');
  process.exit(1);
}

const oauth2Client = new google.auth.OAuth2(clientId, clientSecret, redirectUri);
const authUrl = oauth2Client.generateAuthUrl({
  access_type: 'offline',
  prompt: 'consent',
  scope: ['https://www.googleapis.com/auth/gmail.send'],
});

console.log('\nOpen this URL in a browser and authorize the Gmail account used by the app:\n');
console.log(authUrl);
console.log(`\nWaiting for Google to redirect to ${redirectUri} ...\n`);

const readline = require('node:readline');

const server = http.createServer(async (request, response) => {
  try {
    const url = new URL(request.url, redirectUri);
    const code = url.searchParams.get('code');
    const error = url.searchParams.get('error');

    if (error) throw new Error(`Google authorization failed: ${error}`);
    if (!code) {
      response.writeHead(404);
      response.end('Not found');
      return;
    }

    const { tokens } = await oauth2Client.getToken(code);
    response.writeHead(200, { 'Content-Type': 'text/html' });
    response.end('<h2>Authorization complete! You can close this tab and check your terminal.</h2>');
    console.log('\n=============================================');
    console.log('SUCCESS! Copy and save this refresh token:');
    console.log('=============================================');
    console.log(`\nGMAIL_REFRESH_TOKEN=${tokens.refresh_token || '(no refresh token returned)'}\n`);
    console.log('Keep the refresh token secret.\n');
    server.close();
    process.exit(0);
  } catch (err) {
    response.writeHead(500, { 'Content-Type': 'text/plain' });
    response.end('Authorization failed. Check terminal.');
    console.error('\nError exchanging code for token:', err.message);
    server.close();
    process.exit(1);
  }
});

server.listen(3000, () => {
  console.log(`Listening on http://localhost:3000 and http://127.0.0.1:3000 ...`);
  console.log('If browser says "site can\'t be reached", you can also paste the full browser URL here:\n');
});

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

rl.on('line', async (line) => {
  const input = line.trim();
  if (!input) return;
  try {
    let code = input;
    if (input.includes('code=')) {
      const parsed = new URL(input.startsWith('http') ? input : `http://dummy.com/${input}`);
      code = parsed.searchParams.get('code') || input;
    }
    const { tokens } = await oauth2Client.getToken(code);
    console.log('\n=============================================');
    console.log('SUCCESS! Copy and save this refresh token:');
    console.log('=============================================');
    console.log(`\nGMAIL_REFRESH_TOKEN=${tokens.refresh_token || '(no refresh token returned)'}\n`);
    server.close();
    rl.close();
    process.exit(0);
  } catch (err) {
    console.error('\nFailed to exchange code:', err.message);
  }
});
