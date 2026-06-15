module.exports = (schema, property = 'body') => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req[property], {
      abortEarly: false,
      stripUnknown: true
    });

    if (error) {
      const details = error.details.map(detail => detail.message);
      return res.status(400).json({ error: 'Validation failed', details });
    }

    // Replace request property with validated/sanitized value
    req[property] = value;
    next();
  };
};
