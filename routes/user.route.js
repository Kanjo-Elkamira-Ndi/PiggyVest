import express from 'express';
import { createTarget, getUser, depositeToTarget } from '../controllers/user.controllers.js';
import { getUserTarget } from '../controllers/user.controllers.js';

const router = express.Router();

router.get('/user', getUser);
router.get('/user/target', getUserTarget);
router.post('/user/target', createTarget);
router.post('/user/pay', depositeToTarget);

export default router;