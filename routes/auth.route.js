import {signup, login, verifyAccount,  resendVerificationToken} from '../controllers/auth.controllers.js';
import express from 'express';

const router = express.Router();

router.post('/signup', signup);
router.post('/login', login);
router.post('/verify-account', verifyAccount);
router.post('/resend-verification', resendVerificationToken);

export default router;