const router = require('express').Router();
const authMiddleware = require('../middleware/auth');
const { getAll, getOne, create, update, remove } = require('../controllers/cardController');

// All card routes require authentication
router.use(authMiddleware);

router.get('/', getAll);           // GET /api/cards?search=query
router.get('/:id', getOne);        // GET /api/cards/:id
router.post('/', create);          // POST /api/cards
router.put('/:id', update);        // PUT /api/cards/:id
router.delete('/:id', remove);     // DELETE /api/cards/:id

module.exports = router;
