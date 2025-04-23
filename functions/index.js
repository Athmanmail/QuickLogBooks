const functions = require("firebase-functions");
const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "your-email@gmail.com", // Replace with your email
    pass: "your-app-password", // Replace with your app-specific password
  },
});

exports.sendVerificationCode = functions.https.onCall(async (data, context) => {
  const { email, code, displayName, appName } = data;

  const emailTemplate = `
    <p>Hello ${displayName},</p>
    <p>Please use the following code to verify your email address:</p>
    <p><strong>${code}</strong></p>
    <p>If you didn’t ask to verify this address, you can ignore this email.</p>
    <p>Thanks,</p>
    <p>Your ${appName} team</p>
  `;

  try {
    await transporter.sendMail({
      from: '"Your App Name" <your-email@gmail.com>',
      to: email,
      subject: "Verify Your Email Address",
      html: emailTemplate,
    });
    return { success: true };
  } catch (error) {
    console.error("Error sending email:", error);
    throw new functions.https.HttpsError("internal", "Failed to send email");
  }
});