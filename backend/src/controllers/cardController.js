const Joi = require('joi');
const cardService = require('../services/cardService');

const cardCreateSchema = Joi.object({
  id: Joi.string().guid({ version: ['uuidv4'] }).optional(),
  name: Joi.string().allow(null, ''),
  designation: Joi.string().allow(null, ''),
  company: Joi.string().allow(null, ''),
  email: Joi.string().email().allow(null, ''),
  phones: Joi.array().items(Joi.string()).default([]),
  website: Joi.string().allow(null, ''),
  address: Joi.string().allow(null, ''),
  linkedin: Joi.string().allow(null, ''),
  twitter: Joi.string().allow(null, ''),
  notes: Joi.string().allow(null, '')
}).min(1).unknown(true).messages({
  'object.min': 'At least one field must be populated to save a card'
});

const cardUpdateSchema = Joi.object({
  id: Joi.string().guid({ version: ['uuidv4'] }).optional(),
  name: Joi.string().allow(null, ''),
  designation: Joi.string().allow(null, ''),
  company: Joi.string().allow(null, ''),
  email: Joi.string().email().allow(null, ''),
  phones: Joi.array().items(Joi.string()),
  website: Joi.string().allow(null, ''),
  address: Joi.string().allow(null, ''),
  linkedin: Joi.string().allow(null, ''),
  twitter: Joi.string().allow(null, ''),
  notes: Joi.string().allow(null, '')
}).min(1).unknown(true).messages({
  'object.min': 'At least one field must be populated to update a card'
});

const getAll = async (req, res, next) => {
  try {
    const searchQuery = req.query.search;
    let cards;

    if (searchQuery && searchQuery.trim() !== '') {
      cards = await cardService.searchCards(req.user.id, searchQuery.trim());
    } else {
      cards = await cardService.getAllCards(req.user.id);
    }

    return res.status(200).json({
      cards,
      count: cards.length
    });
  } catch (err) {
    next(err);
  }
};

const getOne = async (req, res, next) => {
  try {
    const card = await cardService.getCardById(req.params.id, req.user.id);
    return res.status(200).json({ card });
  } catch (err) {
    next(err);
  }
};

const create = async (req, res, next) => {
  try {
    const { error, value } = cardCreateSchema.validate(req.body, { abortEarly: false });
    if (error) {
      const details = error.details.map(d => d.message);
      return res.status(400).json({ error: 'Validation failed', details });
    }

    const card = await cardService.createCard(req.user.id, value);
    return res.status(201).json({
      message: 'Card saved successfully',
      card
    });
  } catch (err) {
    next(err);
  }
};

const update = async (req, res, next) => {
  try {
    const { error, value } = cardUpdateSchema.validate(req.body, { abortEarly: false });
    if (error) {
      const details = error.details.map(d => d.message);
      return res.status(400).json({ error: 'Validation failed', details });
    }

    const card = await cardService.updateCard(req.params.id, req.user.id, value);
    return res.status(200).json({
      message: 'Card updated successfully',
      card
    });
  } catch (err) {
    next(err);
  }
};

const remove = async (req, res, next) => {
  try {
    const result = await cardService.deleteCard(req.params.id, req.user.id);
    return res.status(200).json(result);
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getAll,
  getOne,
  create,
  update,
  remove
};
