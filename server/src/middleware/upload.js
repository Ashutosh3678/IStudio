const fs = require('fs');
const path = require('path');
const multer = require('multer');

const uploadDir = path.join(__dirname, '..', '..', 'uploads');
fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, uploadDir),
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname || '').toLowerCase() || '.jpg';
    cb(null, `${Date.now()}-${Math.round(Math.random() * 1e6)}${ext}`);
  },
});

const allowedExtensions = [
  '.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.tiff', '.tif',
  '.svg', '.heic', '.heif', '.avif', '.ico', '.raw', '.jfif', '.pjpeg', '.pjp'
];

const fileFilter = (_req, file, cb) => {
  const ext = path.extname(file.originalname || '').toLowerCase();
  const isImageMime = file.mimetype && file.mimetype.startsWith('image/');
  const isAllowedExt = allowedExtensions.includes(ext);

  if (isImageMime || isAllowedExt || file.mimetype === 'application/octet-stream' || !file.mimetype) {
    cb(null, true);
  } else {
    cb(new Error('Invalid image format. Please upload an image file (.jpg, .jpeg, .png, .webp, etc.).'));
  }
};

const uploadMiddleware = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
  fileFilter,
});

// Accepts single file under field 'logo', 'image', 'avatar', or 'profileImage'
const uploadLogo = uploadMiddleware.single('logo');
const uploadProfileImage = uploadMiddleware.single('image');

module.exports = {
  uploadMiddleware,
  uploadLogo,
  uploadProfileImage,
};
