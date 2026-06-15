const router = require('express').Router();
const authMiddleware = require('../middleware/auth');
const { get, save, remove } = require('../controllers/myCardController');

// All routes require authentication
router.use(authMiddleware);

router.get('/', get);
router.post('/', save);
router.delete('/', remove);

module.exports = router;
