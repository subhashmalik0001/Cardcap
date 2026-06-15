const Joi = require('joi');
const authService = require('../services/authService');
const { adminClient } = require('../config/supabase');

const registerSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': 'Please provide a valid email address',
    'any.required': 'Email is required'
  }),
  password: Joi.string().min(6).required().messages({
    'string.min': 'Password must be at least 6 characters long',
    'any.required': 'Password is required'
  }),
  fullName: Joi.string().min(2).required().messages({
    'string.min': 'Full name must be at least 2 characters long',
    'any.required': 'Full name is required'
  })
});

const loginSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': 'Please provide a valid email address',
    'any.required': 'Email is required'
  }),
  password: Joi.string().required().messages({
    'any.required': 'Password is required'
  })
});

const register = async (req, res, next) => {
  try {
    const { error, value } = registerSchema.validate(req.body, { abortEarly: false });
    if (error) {
      const details = error.details.map(d => d.message);
      return res.status(400).json({ error: 'Validation failed', details });
    }

    const result = await authService.registerUser(value);
    return res.status(201).json({
      message: 'Account created successfully',
      user: result.user,
      token: result.token
    });
  } catch (err) {
    next(err);
  }
};

const login = async (req, res, next) => {
  try {
    const { error, value } = loginSchema.validate(req.body, { abortEarly: false });
    if (error) {
      const details = error.details.map(d => d.message);
      return res.status(400).json({ error: 'Validation failed', details });
    }

    const result = await authService.loginUser(value);
    return res.status(200).json({
      message: 'Login successful',
      user: result.user,
      token: result.token
    });
  } catch (err) {
    next(err);
  }
};

const logout = async (req, res, next) => {
  try {
    // req.user is populated by auth middleware
    const result = await authService.logoutUser(req.user.id);
    return res.status(200).json(result);
  } catch (err) {
    next(err);
  }
};

const refresh = async (req, res, next) => {
  try {
    const result = await authService.refreshToken(req.user.id, req.user.email);
    return res.status(200).json(result);
  } catch (err) {
    next(err);
  }
};

const googleLoginSchema = Joi.object({
  idToken: Joi.string().required().messages({
    'any.required': 'Google ID Token is required'
  }),
  accessToken: Joi.string().optional()
});

const getProfile = async (req, res, next) => {
  try {
    const { data: profile, error } = await adminClient
      .from('profiles')
      .select('id, email, full_name, created_at')
      .eq('id', req.user.id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return res.status(404).json({ error: 'Profile not found' });
      }
      throw error;
    }

    return res.status(200).json({
      user: {
        id: profile.id,
        email: profile.email,
        fullName: profile.full_name,
        createdAt: profile.created_at
      }
    });
  } catch (err) {
    next(err);
  }
};

const googleLogin = async (req, res, next) => {
  try {
    const { error, value } = googleLoginSchema.validate(req.body, { abortEarly: false });
    if (error) {
      const details = error.details.map(d => d.message);
      return res.status(400).json({ error: 'Validation failed', details });
    }

    const result = await authService.loginWithGoogle(value);
    return res.status(200).json({
      message: 'Google login successful',
      user: result.user,
      token: result.token
    });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  register,
  login,
  logout,
  refresh,
  getProfile,
  googleLogin
};

