const cloudinary = require('cloudinary').v2;
const fs = require('fs');

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
  secure: true,
});

/**
 * Uploads a local file to Cloudinary and deletes the temp file.
 * @param {string} filePath - Local path of the uploaded file
 * @param {object} options - Cloudinary upload options
 * @returns {Promise<object>} - Cloudinary upload result
 */
async function uploadToCloudinary(filePath, options = {}) {
  try {
    const uploadOptions = {
      folder: 'lumen_studio/profiles',
      resource_type: 'auto',
      transformation: [
        { width: 800, height: 800, crop: 'limit', quality: 'auto' },
      ],
      ...options,
    };

    const result = await cloudinary.uploader.upload(filePath, uploadOptions);

    // Clean up local temp file after successful upload
    if (fs.existsSync(filePath)) {
      try {
        fs.unlinkSync(filePath);
      } catch (err) {
        console.warn('Failed to delete temp file:', err.message);
      }
    }

    return result;
  } catch (error) {
    // Leave local file in uploads folder if Cloudinary upload fails so fallback URL works
    throw error;
  }
}

module.exports = {
  cloudinary,
  uploadToCloudinary,
};
