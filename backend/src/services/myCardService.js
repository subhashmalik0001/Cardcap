const { adminClient } = require('../config/supabase');

const ensureBucketExists = async () => {
  try {
    const { data: buckets, error } = await adminClient.storage.listBuckets();
    if (error) throw error;

    if (!buckets.some(b => b.name === 'card-images')) {
      const { error: createError } = await adminClient.storage.createBucket('card-images', {
        public: true,
        allowedMimeTypes: ['image/jpeg', 'image/png']
      });
      if (createError) throw createError;
    }
  } catch (err) {
    console.error('ensureBucketExists error:', err);
    // Continue anyway as the bucket might already exist and listBuckets fails due to policy
  }
};

const uploadBase64Image = async (filePath, base64String, contentType) => {
  await ensureBucketExists();
  
  // Clean base64 header if present (e.g. data:image/png;base64,)
  const cleanBase64 = base64String.replace(/^data:image\/\w+;base64,/, '');
  const buffer = Buffer.from(cleanBase64, 'base64');

  const { error } = await adminClient.storage
    .from('card-images')
    .upload(filePath, buffer, {
      contentType,
      upsert: true
    });

  if (error) {
    throw error;
  }

  const { data } = adminClient.storage
    .from('card-images')
    .getPublicUrl(filePath);

  return data.publicUrl;
};

const getMyCard = async (userId) => {
  const { data, error } = await adminClient
    .from('my_cards')
    .select('*')
    .eq('user_id', userId)
    .maybeSingle();

  if (error) {
    throw error;
  }
  return data;
};

const saveMyCard = async (userId, payload) => {
  let photoUrl = payload.photoUrl || null;
  let cardImageUrl = payload.cardImageUrl || null;

  // Upload user photo if provided as base64
  if (payload.photoBase64) {
    photoUrl = await uploadBase64Image(
      `user_${userId}/photo.jpg`,
      payload.photoBase64,
      'image/jpeg'
    );
  }

  // Upload card preview image if provided as base64
  if (payload.cardImageBase64) {
    cardImageUrl = await uploadBase64Image(
      `user_${userId}/card_preview.png`,
      payload.cardImageBase64,
      'image/png'
    );
  }

  const cardRecord = {
    user_id: userId,
    details: payload.details,
    template_id: payload.templateId,
    field_positions: payload.fieldPositions,
    photo_shape: payload.photoShape,
    photo_url: photoUrl,
    text_color: payload.textColor,
    visible_fields: payload.visibleFields,
    card_image_url: cardImageUrl,
    card_ratio: payload.cardRatio || 'standard',
    show_icons: payload.showIcons !== undefined ? payload.showIcons : true,
    photo_size: payload.photoSize || 56.0,
    text_sizes: payload.textSizes || {},
    updated_at: new Date().toISOString()
  };

  const { data, error } = await adminClient
    .from('my_cards')
    .upsert(cardRecord)
    .select()
    .single();

  if (error) {
    throw error;
  }

  // Update profiles.qr_generated_at to track that the user generated their card QR
  try {
    await adminClient
      .from('profiles')
      .update({ qr_generated_at: new Date().toISOString() })
      .eq('id', userId);
  } catch (err) {
    console.error('Failed to update profiles.qr_generated_at:', err);
  }

  return data;
};

const deleteMyCard = async (userId) => {
  const { data, error } = await adminClient
    .from('my_cards')
    .delete()
    .eq('user_id', userId)
    .select();

  if (error) {
    throw error;
  }

  // Attempt to delete files in the background
  try {
    await adminClient.storage
      .from('card-images')
      .remove([`user_${userId}/photo.jpg`, `user_${userId}/card_preview.png`]);
  } catch (err) {
    console.error('Failed to delete personal card files from storage:', err);
  }

  return { message: 'Personal card deleted successfully' };
};

module.exports = {
  getMyCard,
  saveMyCard,
  deleteMyCard
};
