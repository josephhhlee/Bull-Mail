const { onCall } = require('firebase-functions/v2/https');

exports.enrollment = onCall(
    {
        region: '',
        memory: '512MiB',
        timeoutSeconds: 60,
        serviceAccount: '',
        enforceAppCheck: false,
    }, async (req) => {
        const { normalizedHttpArg } = require('./utils');
        const getFirebaseAdmin = require("./firebase-admin");
        const { v4: uuidv4 } = require('uuid');
        const { google } = require('googleapis');

        const admin = getFirebaseAdmin();

        const email = normalizedHttpArg(req, 'email')?.toLowerCase();
        const frequency = normalizedHttpArg(req, 'frequency')?.toUpperCase();
        const tickers = normalizedHttpArg(req, 'tickers') || [];
        const origin = normalizedHttpArg(req, 'origin');

        if (!email || !frequency || !Array.isArray(tickers) || tickers.length === 0 || !origin) {
            console.error('Missing parameters');
            return false;
        }

        console.log('Received request with:', {
            email,
            frequency,
            tickers,
        });

        async function sendEmail(to, subject, body) {
            const auth = new google.auth.OAuth2(
                '',
                '',
                [
                    "http://localhost"
                ]
            );

            auth.setCredentials({
                refresh_token: '',
            });

            const gmail = google.gmail({ version: 'v1', auth });

            const message = [
                `From: "Bull Mail" <bullmailmarket@gmail.com>`,
                `To: ${to}`,
                `Subject: ${subject}`,
                `Content-Type: text/html; charset=UTF-8`,
                '',
                body,
            ].join('\n');

            const encodedMessage = Buffer.from(message)
                .toString('base64')
                .replace(/\+/g, '-')
                .replace(/\//g, '_')
                .replace(/=+$/, '');

            const res = await gmail.users.messages.send({
                userId: 'me',
                requestBody: {
                    raw: encodedMessage,
                },
            });
            console.log('Email sent:', res.data);
        }

        const verificationToken = uuidv4();
        const verificationURL = `${origin}/verify?email=${encodeURIComponent(email)}&token=${verificationToken}`;


        const enrollmentData = {
            email,
            frequency,
            tickers,
            verificationToken,
            verificationExpiry: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 24 * 60 * 60 * 1000)), // 24 hours from now
            isVerified: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp()
        };

        try {
            await admin.firestore().runTransaction(async (transaction) => {
                // First, save the enrollment data in Firestore within the transaction
                const userRef = admin.firestore().collection('users').doc(email);
                transaction.set(userRef, enrollmentData);

                await sendEmail(
                    email,
                    'Please verify your email for Bull Mail',
                    `
                    <p>Welcome to <strong>Bull Mail</strong>!</p>
                    <p>Please confirm your email address by clicking the link below:</p>
                    <p><a href="${verificationURL}">${verificationURL}</a></p>
                    <p>If you didn't sign up for Bull Mail, you can safely ignore this email.</p>
                    `
                );
            });

            console.log('Enrollment data saved for:', email);

            return true;
        } catch (error) {
            console.error('Error occurred during enrollment: ', error);
            return false;
        }
    }
);

exports.search_stock_ticker = onCall(
    {
        region: '',
        memory: '512MiB',
        timeoutSeconds: 60,
        serviceAccount: '',
        enforceAppCheck: false,
    }, async (req) => {
        const { normalizedHttpArg } = require('./utils');
        const getFirebaseAdmin = require("./firebase-admin");

        getFirebaseAdmin();

        const email = normalizedHttpArg(req, 'email')?.toLowerCase();
        const input = normalizedHttpArg(req, 'input')?.toUpperCase();

        if (!email || !input) {
            console.error('Missing parameters');
            return null;
        }

        console.log('Received request with:', {
            email,
            input,
        });

        async function fetchFromAlphaVantage() {
            console.log('Fetching from Alpha Vantage');

            // 25 calls per day
            const url = `https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=${input}&datatype=json&apikey=`;
            const response = await fetch(url);
            const data = await response.json();
            const matches = data.bestMatches || [];

            const exactMatch = matches.find(match =>
                match["1. symbol"].toUpperCase() === input
            );

            if (exactMatch) {
                return exactMatch["2. name"];
            }

            return null;
        }

        async function fetchFromFinancialModelingPrep() {
            console.log('Fetching from Financial Modeling Prep');

            // 250 calls per day
            const url = `https://financialmodelingprep.com/stable/search-symbol?query=${input}&apikey=&limit=1`;
            const response = await fetch(url);
            const data = await response.json();

            if (data.length > 0 && data[0].symbol.toUpperCase() === input) {
                return data[0].name;
            }

            return null;
        }

        async function fetchFromPolygon() {
            console.log('Fetching from Polygon');

            // 5 calls per minute
            const url = `https://api.polygon.io/v3/reference/tickers/${input}?apiKey=`;
            const response = await fetch(url);
            const data = await response.json();

            if (data && data.results && data.results.ticker.toUpperCase() === input) {
                return data.results.name;
            }

            return null;
        }

        const CacheService = require("./cacheService");
        const cacheService = CacheService.getInstance('stock_tickers');
        const cached = await cacheService.get(input);

        if (cached) {
            return { symbol: input, name: cached };
        }

        console.log('Cache miss, fetching from APIs');

        const name = await fetchFromPolygon() ?? await fetchFromFinancialModelingPrep() ?? await fetchFromAlphaVantage();
        if (name) {
            console.log('Found stock ticker:', { symbol: input, name });

            await cacheService.set(input, name);
            return { symbol: input, name };
        }

        console.log('Stock ticker not found for input:', input);

        return null;
    }
);