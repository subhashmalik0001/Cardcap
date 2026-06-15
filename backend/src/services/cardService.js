const { v4: uuidv4 } = require('uuid');
const { adminClient } = require('../config/supabase');

const getAllCards = async (userId) => {
  const { data, error } = await adminClient
    .from('business_cards')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false });

  if (error) {
    throw error;
  }
  return data;
};

const getCardById = async (cardId, userId) => {
  const { data, error } = await adminClient
    .from('business_cards')
    .select('*')
    .eq('id', cardId)
    .eq('user_id', userId)
    .single();

  if (error) {
    if (error.code === 'PGRST116') {
      throw new Error('Card not found');
    }
    throw error;
  }
  return data;
};

const createCard = async (userId, cardData) => {
  const card = {
    id: cardData.id || uuidv4(),
    user_id: userId,
    name: cardData.name || null,
    designation: cardData.designation || null,
    company: cardData.company || null,
    email: cardData.email || null,
    phones: cardData.phones || [],      // stored as JSONB array
    website: cardData.website || null,
    address: cardData.address || null,
    linkedin: cardData.linkedin || null,
    twitter: cardData.twitter || null,
    notes: cardData.notes || null,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  };

  const { data, error } = await adminClient
    .from('business_cards')
    .insert([card])
    .select()
    .single();

  if (error) {
    throw error;
  }
  return data;
};

const updateCard = async (cardId, userId, updates) => {
  const allowedFields = [
    'name',
    'designation',
    'company',
    'email',
    'phones',
    'website',
    'address',
    'linkedin',
    'twitter',
    'notes'
  ];

  const updatePayload = {
    updated_at: new Date().toISOString()
  };

  // Only allow specified updates
  for (const field of allowedFields) {
    if (updates[field] !== undefined) {
      updatePayload[field] = updates[field];
    }
  }

  const { data, error } = await adminClient
    .from('business_cards')
    .update(updatePayload)
    .eq('id', cardId)
    .eq('user_id', userId)
    .select();

  if (error) {
    throw error;
  }

  if (!data || data.length === 0) {
    throw new Error('Card not found or unauthorized');
  }

  return data[0];
};

const deleteCard = async (cardId, userId) => {
  const { data, error, count } = await adminClient
    .from('business_cards')
    .delete()
    .eq('id', cardId)
    .eq('user_id', userId)
    .select();

  if (error) {
    throw error;
  }

  if (!data || data.length === 0) {
    throw new Error('Card not found or unauthorized');
  }

  return { message: 'Card deleted successfully' };
};

const searchCards = async (userId, query) => {
  const { data, error } = await adminClient
    .from('business_cards')
    .select('*')
    .eq('user_id', userId)
    .or(
      `name.ilike.%${query}%,` +
      `company.ilike.%${query}%,` +
      `designation.ilike.%${query}%,` +
      `email.ilike.%${query}%,` +
      `address.ilike.%${query}%`
    )
    .order('created_at', { ascending: false });

  if (error) {
    throw error;
  }
  return data;
};

module.exports = {
  getAllCards,
  getCardById,
  createCard,
  updateCard,
  deleteCard,
  searchCards
};
