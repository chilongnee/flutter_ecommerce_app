require("dotenv").config();
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const crypto = require("crypto");

admin.initializeApp();
const db = admin.firestore(); // Khai báo Firestore

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// Gửi OTP
exports.sendOtpEmail = functions.https.onRequest(async (req, res) => {
  try {
    console.log("Nhận yêu cầu gửi OTP:", req.body);

    const { email } = req.body;
    if (!email) {
      console.error("Lỗi: Không có email trong request.");
      return res.status(400).json({ success: false, message: "Vui lòng nhập email." });
    }

    try {
      await admin.auth().getUserByEmail(email);
    } catch (error) {
      console.error("Email không tồn tại:", error.message);
      return res.status(400).json({ success: false, message: "Email này chưa được đăng ký!" });
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = Date.now() + 60 * 1000;

    // Mã hóa OTP 
    const hashedOtp = crypto.createHash("sha256").update(otp).digest("hex");

    await db.collection("otp_codes").doc(email).set({ otp: hashedOtp, expiresAt });

    console.log("OTP tạo ra:", otp);

    const mailOptions = {
      from: `"Ecommerce App" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: "Xác thực OTP - Ecommerce App",
      html: `
        <h2>Mã OTP của bạn</h2>
        <p><strong>${otp}</strong></p>
        <p>Mã này có hiệu lực trong 1 phút.</p>
      `,
    };

    try {
      const info = await transporter.sendMail(mailOptions);
      console.log("Email đã gửi thành công:", info.response);
      return res.status(200).json({ success: true, message: "OTP đã gửi thành công." });
    } catch (emailError) {
      console.error("Lỗi khi gửi email:", emailError.message);
      return res.status(500).json({ success: false, message: "Không thể gửi OTP.", error: emailError.message });
    }
  } catch (error) {
    console.error("Lỗi không xác định:", error);
    return res.status(500).json({ success: false, message: "Lỗi máy chủ.", error: error.toString() });
  }
});

// Xác minh OTP
exports.verifyOtp = functions.https.onRequest(async (req, res) => {
  try {
    const { email, otp } = req.body;
    if (!email || !otp) return res.status(400).json({ success: false, message: "Thiếu email hoặc OTP." });

    const otpDoc = await db.collection("otp_codes").doc(email).get();
    if (!otpDoc.exists) return res.status(400).json({ success: false, message: "OTP không hợp lệ!" });

    const { otp: storedOtp, expiresAt } = otpDoc.data();

    if (Date.now() > expiresAt) {
      await db.collection("otp_codes").doc(email).delete();
      return res.status(400).json({ success: false, message: "OTP đã hết hạn!" });
    }

    const hashedOtp = crypto.createHash("sha256").update(otp).digest("hex");
    if (hashedOtp !== storedOtp) return res.status(400).json({ success: false, message: "OTP không chính xác!" });

    await db.collection("otp_codes").doc(email).delete();
    return res.status(200).json({ success: true, message: "Xác thực thành công!" });

  } catch (error) {
    return res.status(500).json({ success: false, message: "Lỗi máy chủ.", error: error.toString() });
  }
});

// Đặt lại mật khẩu
exports.resetPassword = functions.https.onRequest(async (req, res) => {
  try {
    const { email, newPassword } = req.body;
    if (!email || !newPassword) return res.status(400).json({ success: false, message: "Thiếu email hoặc mật khẩu mới." });

    if (newPassword.length < 6) {
      return res.status(400).json({ success: false, message: "Mật khẩu mới phải có ít nhất 6 ký tự." });
    }

    const user = await admin.auth().getUserByEmail(email);

    await admin.auth().updateUser(user.uid, { password: newPassword });

    return res.status(200).json({ success: true, message: "Đặt lại mật khẩu thành công!" });

  } catch (error) {
    return res.status(500).json({ success: false, message: "Lỗi máy chủ.", error: error.toString() });
  }
});
