const { onCall } = require('firebase-functions/v2/https');

exports.search_stock_ticker = onCall(
    {
        region: 'asia-southeast1',
        memory: '512MiB',
        timeoutSeconds: 60,
        serviceAccount: 'YOUR SERVICE ACCOUNT',
        enforceAppCheck: false,
    }, async (req) => {
        const { normalizedHttpArg } = require('./utils');
        const getFirebaseAdmin = require("./firebase-admin");

        getFirebaseAdmin();

        const input = normalizedHttpArg(req, 'input')?.toUpperCase();

        if (!input) {
            console.error('Missing parameters');
            return null;
        }

        console.log('Received request with:', { input });

        async function fetchFromAlphaVantage() {
            console.log('Fetching from Alpha Vantage');

            // 25 calls per day
            const url = `https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=${input}&datatype=json&apikey=YOUR_API_KEY`;
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
            const url = `https://financialmodelingprep.com/stable/search-symbol?query=${input}&apikey=YOUR_API_KEY&limit=1`;
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
            const url = `https://api.polygon.io/v3/reference/tickers/${input}?apiKey=YOUR_API_KEY`;
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

exports.enrollment = onCall(
    {
        region: 'asia-southeast1',
        memory: '512MiB',
        timeoutSeconds: 60,
        serviceAccount: 'YOUR SERVICE ACCOUNT',
        enforceAppCheck: false,
    }, async (req) => {
        const { normalizedHttpArg } = require('./utils');
        const getFirebaseAdmin = require("./firebase-admin");
        const { v4: uuidv4 } = require('uuid');
        const nodemailer = require("nodemailer");
        const crypto = require('crypto');

        const admin = getFirebaseAdmin();

        const email = normalizedHttpArg(req, 'email')?.toLowerCase();
        const tickers = normalizedHttpArg(req, 'tickers') || [];

        if (!email || !Array.isArray(tickers) || tickers.length === 0) {
            console.error('Missing parameters');
            return false;
        }

        console.log('Received request with:', {
            email,
            tickers,
        });

        async function sendEmail(to, subject, body) {
            const transporter = nodemailer.createTransport({
                service: "gmail",
                auth: {
                    user: process.env.EMAIL,
                    pass: process.env.PASS
                }
            });

            await transporter.sendMail({
                from: '"Bull Mail" <YOUR EMAIL>',
                to,
                subject,
                html: body,
            });

            console.log('Verification email sent to:', to);
        }

        function encrypt(text, secretKey) {
            const iv = crypto.randomBytes(12);
            const key = crypto.createHash('sha256').update(secretKey).digest();
            const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);

            const encrypted = Buffer.concat([cipher.update(text, 'utf8'), cipher.final()]);
            const tag = cipher.getAuthTag();

            const payload = Buffer.concat([iv, encrypted, tag]);

            return payload.toString('base64url');
        }

        const secretKey = process.env.KEY;
        const verificationToken = uuidv4();
        const params = `email=${email}&token=${verificationToken}`;
        const encryptedParams = encrypt(params, secretKey);
        const verificationURL = `https://your-project.com/verify?${encryptedParams}`;

        const enrollmentData = {
            email,
            tickers,
            verificationToken,
            verificationExpiry: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 24 * 60 * 60 * 1000)), // 24 hours from now
            isVerified: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp()
        };

        try {
            await admin.firestore().runTransaction(async (transaction) => {
                const userRef = admin.firestore().collection('users').doc(email);
                transaction.set(userRef, enrollmentData);

                await sendEmail(
                    email,
                    'Verify your email address',
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
