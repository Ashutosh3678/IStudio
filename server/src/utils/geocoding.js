const https = require('https');

const PHOTON_BASE_URL = process.env.PHOTON_API_URL || 'https://photon.komoot.io/api';

function fetchPhoton(query) {
  if (!query || !query.trim()) return Promise.resolve(null);
  const encoded = encodeURIComponent(query.trim());
  const url = `${PHOTON_BASE_URL}/?q=${encoded}&limit=1`;
  return new Promise((resolve) => {
    https
      .get(url, { headers: { 'User-Agent': 'IStudioApp/1.0' } }, (res) => {
        let data = '';
        res.on('data', (chunk) => {
          data += chunk;
        });
        res.on('end', () => {
          try {
            const json = JSON.parse(data);
            const feature = json.features && json.features[0];
            if (!feature) return resolve(null);
            const coords = feature.geometry && feature.geometry.coordinates;
            if (!coords || coords.length < 2) return resolve(null);
            resolve({ lat: coords[1], lng: coords[0] });
          } catch {
            resolve(null);
          }
        });
      })
      .on('error', () => resolve(null))
      .setTimeout(4000, function () {
        this.destroy();
        resolve(null);
      });
  });
}

/**
 * Geocode a free-text address/venue/city to {lat, lng} using Photon OSM API.
 * Gracefully handles long addresses with landmarks (e.g. "Pillar Number 102, The Vintage Palace...").
 * Returns null on failure — never throws.
 */
async function geocodeAddress(text) {
  if (!text || !text.trim()) return null;
  const clean = text.trim();

  // 1. Try full text query
  let res = await fetchPhoton(clean);
  if (res) return res;

  // 2. Candidate sub-parts if commas present
  const parts = clean.split(',').map((p) => p.trim()).filter(Boolean);
  if (parts.length > 1) {
    const meaningful = parts.filter((p) => {
      const l = p.toLowerCase();
      return (
        !l.startsWith('pillar') &&
        !l.startsWith('flat') &&
        !l.startsWith('plot') &&
        !l.startsWith('h.no') &&
        !l.startsWith('door') &&
        !l.startsWith('beside') &&
        !l.startsWith('opposite') &&
        !l.startsWith('near') &&
        !l.startsWith('room')
      );
    });

    if (meaningful.length > 0 && meaningful.length !== parts.length) {
      res = await fetchPhoton(meaningful.join(', '));
      if (res) return res;
    }

    if (meaningful.length >= 3) {
      const venueCity = [
        meaningful[0],
        meaningful[meaningful.length - 2],
        meaningful[meaningful.length - 1],
      ].join(', ');
      res = await fetchPhoton(venueCity);
      if (res) return res;
    }

    if (meaningful.length > 0) {
      res = await fetchPhoton(meaningful[0]);
      if (res) return res;
    }
  }

  return null;
}

module.exports = {
  geocodeAddress,
};

