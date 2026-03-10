/**
 * Memory: 1Gi
 * CPU: 1
 * Timeout: 600s
 * Schedule: 30 19 * * *
 */
async function scheduled_email() {
    const { GoogleGenAI } = require("@google/genai");
    const getFirebaseAdmin = require("./firebase-admin");
    const nodemailer = require("nodemailer");
    const crypto = require('crypto');

    async function queryStockNews(tickers) {
        try {
            const prompt =
            `
            You are a professional financial news analyst operating in a structured research workflow.
            Your objective is to identify material market-moving news events affecting the stocks and ETFs in the provided watchlist only, within the last 24 hours, and return only high-impact, non-neutral events in strict JSON format.
            You must follow the analysis process exactly and do not include any news about companies not in the watchlist. Avoid generating speculative or fabricated information.
            
            --------------------------------
            INPUT
            --------------------------------
                Stock list:
                    [${tickers.join(', ')}]
            
                Current date reference YYYY-MM-DD:
                    ${new Date().toISOString().split('T')[0]}

            ....
            `;

            const responseSchema = {
                type: 'ARRAY',
                items: {
                    type: 'OBJECT',
                    properties: {
                        companies: { type: 'ARRAY', items: { type: 'STRING' } },
                        tickers: { type: 'ARRAY', items: { type: 'STRING' } },
                        current_valuation: { type: 'STRING' },
                        impact_sentiment: { type: 'STRING' },
                        headline: { type: 'STRING' },
                        summary: { type: 'STRING' },
                        why_it_matters_for_investors: { type: 'STRING' },
                        source: { type: 'STRING' },
                        link: { type: 'STRING' },
                        date: { type: 'STRING' },
                    },
                    required: ['companies', 'tickers', 'current_valuation', 'impact_sentiment', 'headline', 'summary', 'why_it_matters_for_investors', 'source', 'link', 'date'],
                },
            };

            const ai = new GoogleGenAI({ vertexai: true, project: process.env.PROJECT_ID, location: 'global' });

            const response = await ai.models.generateContent({
                model: 'gemini-3.1-pro-preview',
                contents: prompt,
                config: {
                    responseMimeType: 'application/json',
                    responseSchema: responseSchema,
                    tools: [
                        {
                            googleSearch: {},
                        },
                    ],
                },
            });

            const text = response.text
                .replace(/```json/g, "")
                .replace(/```/g, "")
                .trim();


            const usage = response.usageMetadata;
            if (usage) {
                console.log(usage);
            }

            return JSON.parse(text);
        } catch (e) {
            console.error("Error querying stock news:", e);
            throw (e);
        }
    }

    async function sendEmail(to, subject, body) {
        const transporter = nodemailer.createTransport({
            service: "gmail",
            auth: {
                user: process.env.EMAIL,
                pass: process.env.PASS
            }
        });

        await transporter.sendMail({
            from: '"Bull Mail News" <YOUR EMAIL>',
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

    const admin = getFirebaseAdmin();
    const usersSnapshot = await admin.firestore().collection('users').where('isVerified', '==', true).get();
    const allTickers = usersSnapshot.docs.flatMap(doc => doc.data().tickers || []);
    const uniqueTickers = [...new Set(allTickers)];

    console.log('Fetching news for tickers:', uniqueTickers);
    const jsonNews = await queryStockNews(uniqueTickers);
    console.log(`Retrieved ${jsonNews.length} news events from AI analysis.`);

    const emailPromises = usersSnapshot.docs.map(async doc => {
        const userData = doc.data();
        const userTickers = userData.tickers || [];
        const relevantNews = jsonNews.filter(event => event.tickers.some(ticker => userTickers.includes(ticker)));

        console.log(`User ${userData.email} has ${relevantNews.length} relevant news events.`);

        if (relevantNews.length > 0) {
            const emailBody = relevantNews.map(event => `
                <div style="font-family: Arial, sans-serif; margin-bottom: 24px; padding: 18px; border: 1px solid #e5e7eb; border-radius: 8px; background-color: #fafafa;">
                    <h3 style="color: #1a73e8; margin: 0 0 10px 0;">${event.headline}</h3>

                    <p style="margin: 6px 0;"><strong>${event.companies.length > 1 ? 'Companies' : 'Company'}:</strong> ${event.companies.join(', ')}</p>
                    <p style="margin: 6px 0;"><strong>${event.tickers.length > 1 ? 'Tickers' : 'Ticker'}:</strong> ${event.tickers.join(', ')}</p>
                    <p style="margin: 6px 0;"><strong>Valuation:</strong> ${event.current_valuation}</p>
                    <p style="margin: 6px 0;"><strong>Sentiment:</strong> ${event.impact_sentiment}</p>

                    <p style="margin: 10px 0;"><strong>Summary:</strong> ${event.summary}</p>
                    <p style="margin: 10px 0;"><strong>Why it matters:</strong> ${event.why_it_matters_for_investors}</p>

                    <p style="margin: 10px 0;">
                        <strong>Source:</strong> ${event.source} —
                        <a href="${event.link}" style="color:#1a73e8;text-decoration:none;font-weight:500;">
                            Read more
                        </a>
                    </p>
                </div>
            `).join('');

            const emailHTML = `
            <div style="font-family: Arial, sans-serif; line-height:1.6; color:#333; max-width:640px; margin:auto;">

                <h2 style="color:#111; margin-bottom:8px;">Daily Stock News Update</h2>
                <p style="font-size:15px; color:#555;">
                    Here are the latest high-impact news events for your watchlist.
                </p>

                ${emailBody}

                <hr style="border:none;border-top:1px solid #e5e7eb;margin:30px 0;" />

                <div style="font-size:13px; color:#777; text-align:center; padding-bottom:10px;">
                    <p style="margin:6px 0;">
                        You're receiving this email because you subscribed to stock news alerts.
                    </p>

                    <p style="margin:6px 0;">
                        <a href="https://your-project.com/unsubscribe?${encrypt(`email=${userData.email}`, process.env.KEY)}"
                        style="color:#6b7280; text-decoration:underline;">
                        Unsubscribe
                        </a>
                        &nbsp;•&nbsp;
                        <a href="https://your-project.com/watchlist?${encrypt(`email=${userData.email}`, process.env.KEY)}"
                        style="color:#6b7280; text-decoration:underline;">
                        Manage watchlist
                        </a>
                    </p>

                    <p style="margin-top:10px; color:#9ca3af;">
                        © ${new Date().getFullYear()} Bull Mail
                    </p>
                </div>

            </div>
            `;

            await sendEmail(
                userData.email,
                'Your Daily Stock News Update',
                emailHTML,
            );
        }
    });

    await Promise.all(emailPromises);
}

async function main() {
    try {
        await scheduled_email();
        console.log('✅ Job completed successfully');
        process.exit(0);
    } catch (err) {
        console.error('❌ Job failed:', err);
        process.exit(1);
    }
}

main();
