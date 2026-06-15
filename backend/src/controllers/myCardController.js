const Joi = require('joi');
const myCardService = require('../services/myCardService');

const myCardSchema = Joi.object({
  details: Joi.object({
    name: Joi.string().required(),
    title: Joi.string().allow(null, ''),
    company: Joi.string().allow(null, ''),
    phone: Joi.string().allow(null, ''),
    email: Joi.string().allow(null, ''),
    website: Joi.string().allow(null, ''),
    address: Joi.string().allow(null, '')
  }).required(),
  templateId: Joi.string().required(),
  fieldPositions: Joi.object().pattern(
    Joi.string(),
    Joi.object({
      dx: Joi.number().required(),
      dy: Joi.number().required()
    })
  ).required(),
  photoShape: Joi.string().required(),
  photoBase64: Joi.string().allow(null, ''),
  photoUrl: Joi.string().allow(null, ''),
  textColor: Joi.string().required(),
  visibleFields: Joi.object().pattern(Joi.string(), Joi.boolean()).required(),
  cardImageBase64: Joi.string().allow(null, ''),
  cardImageUrl: Joi.string().allow(null, '')
}).unknown(true);

const get = async (req, res, next) => {
  try {
    const card = await myCardService.getMyCard(req.user.id);
    return res.status(200).json({ card });
  } catch (err) {
    next(err);
  }
};

const save = async (req, res, next) => {
  try {
    const { error, value } = myCardSchema.validate(req.body, { abortEarly: false });
    if (error) {
      const details = error.details.map(d => d.message);
      return res.status(400).json({ error: 'Validation failed', details });
    }

    const card = await myCardService.saveMyCard(req.user.id, value);
    return res.status(200).json({
      message: 'Personal card saved successfully',
      card
    });
  } catch (err) {
    next(err);
  }
};

const remove = async (req, res, next) => {
  try {
    const result = await myCardService.deleteMyCard(req.user.id);
    return res.status(200).json(result);
  } catch (err) {
    next(err);
  }
};

module.exports = {
  get,
  save,
  remove
};
