const jwt = require('jsonwebtoken');

function requireAuth(req, res, next) {
  const header = req.headers.authorization || '';
  const [, token] = header.split(' ');

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Please sign in to continue.',
    });
  }

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = payload.id;
    return next();
  } catch (_) {
    return res.status(401).json({
      success: false,
      message: 'Your session has expired. Please sign in again.',
    });
  }
}

module.exports = { requireAuth };
