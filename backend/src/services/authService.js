const jwt = require('jsonwebtoken');
const { anonClient, adminClient } = require('../config/supabase');

const generateToken = (payload) => {
  return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '7d' });
};

const registerUser = async ({ email, password, fullName }) => {
  // 1. Sign up the user in Supabase Auth using anonClient
  const { data: signUpData, error: signUpError } = await anonClient.auth.signUp({
    email,
    password,
    options: {
      data: {
        full_name: fullName
      }
    }
  });

  if (signUpError) {
    throw signUpError;
  }

  const user = signUpData.user;
  if (!user) {
    throw new Error('Failed to create user. User returned was null.');
  }

  // 2. Insert the user profile into public.profiles using adminClient (bypassing RLS)
  const { error: profileError } = await adminClient
    .from('profiles')
    .insert([
      {
        id: user.id,
        email,
        full_name: fullName,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }
    ]);

  if (profileError) {
    // Note: We might want to handle rollback, but in simple flow we throw the error
    throw profileError;
  }

  // 3. Generate our application JWT
  const token = generateToken({ id: user.id, email });

  return {
    user: {
      id: user.id,
      email,
      fullName
    },
    token
  };
};

const loginUser = async ({ email, password }) => {
  // 1. Sign in via Supabase Auth
  const { data: signInData, error: signInError } = await anonClient.auth.signInWithPassword({
    email,
    password
  });

  if (signInError) {
    // Throw standard message
    throw new Error('Invalid email or password');
  }

  const user = signInData.user;
  if (!user) {
    throw new Error('Failed to sign in. User returned was null.');
  }

  // 2. Fetch profile to get full_name
  const { data: profileData } = await adminClient
    .from('profiles')
    .select('full_name')
    .eq('id', user.id)
    .single();

  const fullName = profileData ? profileData.full_name : null;

  // 3. Generate our JWT
  const token = generateToken({ id: user.id, email: user.email });

  return {
    user: {
      id: user.id,
      email: user.email,
      fullName
    },
    token
  };
};

const logoutUser = async (userId) => {
  // Admin client signs out user server-side
  const { error } = await adminClient.auth.admin.signOut(userId);
  if (error) {
    throw error;
  }
  return { message: 'Logged out successfully' };
};

const refreshToken = async (userId, email) => {
  const token = generateToken({ id: userId, email });
  return { token };
};

const loginWithGoogle = async ({ idToken, accessToken }) => {
  let user;

  if (idToken === 'mock_google_id_token') {
    // 1. Handle mock sign in for local testing / emulator
    const mockEmail = 'google.user@example.com';
    const mockName = 'Google Account User';

    // Check if the profile already exists
    const { data: existingProfile } = await adminClient
      .from('profiles')
      .select('id, email, full_name')
      .eq('email', mockEmail)
      .single();

    if (existingProfile) {
      user = {
        id: existingProfile.id,
        email: existingProfile.email,
        user_metadata: { full_name: existingProfile.full_name }
      };
    } else {
      // Create a new authenticated user in auth.users
      const { data: createdUser, error: createError } = await adminClient.auth.admin.createUser({
        email: mockEmail,
        email_confirm: true,
        user_metadata: { full_name: mockName }
      });

      if (createError && createError.message !== 'User already exists') {
        throw createError;
      }

      if (createdUser && createdUser.user) {
        user = createdUser.user;
      } else {
        // Fallback to query user list if they exist in auth but not in profiles
        const { data: userList } = await adminClient.auth.admin.listUsers();
        const foundUser = userList.users.find(u => u.email === mockEmail);
        if (foundUser) {
          user = foundUser;
        } else {
          throw new Error('Failed to create or retrieve mock Google user.');
        }
      }
    }
  } else {
    // 2. Real Google Sign In verification via Supabase OAuth
    const { data, error } = await anonClient.auth.signInWithIdToken({
      provider: 'google',
      token: idToken,
      access_token: accessToken,
    });

    if (error) {
      throw error;
    }

    user = data.user;
  }

  if (!user) {
    throw new Error('Failed to sign in via Google. User returned was null.');
  }

  // Ensure user has a profile record
  const { data: profileData } = await adminClient
    .from('profiles')
    .select('full_name')
    .eq('id', user.id)
    .single();

  let fullName = user.user_metadata?.full_name || user.user_metadata?.name || 'Google User';


  if (!profileData) {
    await adminClient
      .from('profiles')
      .insert([
        {
          id: user.id,
          email: user.email,
          full_name: fullName,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }
      ]);
  } else {
    fullName = profileData.full_name || fullName;
  }

  const token = generateToken({ id: user.id, email: user.email });

  return {
    user: {
      id: user.id,
      email: user.email,
      fullName
    },
    token
  };
};

module.exports = {
  registerUser,
  loginUser,
  logoutUser,
  refreshToken,
  loginWithGoogle
};

