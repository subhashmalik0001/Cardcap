module.exports = (err, req, res, next) => {
  console.error('Unhandled Error:', err);

  const isDevelopment = process.env.NODE_ENV === 'development';
  
  const response = {
    error: err.message || 'Internal server error',
    ...(isDevelopment ? { details: err.stack || err.toString() } : {})
  };

  const statusCode = err.status || 500;
  res.status(statusCode).json(response);
};
