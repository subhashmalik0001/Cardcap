const router = require('express').Router();
const authMiddleware = require('../middleware/auth');
const { register, login, logout, refresh, getProfile, googleLogin } = require('../controllers/authController');

router.post('/register', register);
router.post('/login', login);
router.post('/google', googleLogin);
router.post('/logout', authMiddleware, logout);
router.post('/refresh', authMiddleware, refresh);
router.get('/profile', authMiddleware, getProfile);

module.exports = router;
