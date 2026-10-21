/**
 * Universal, typo-tolerant fuzzy search for the Discover feature.
 *
 * Design principles:
 *   • Case-insensitive, whitespace-normalised, punctuation-stripped matching
 *   • Short-token guard  — query tokens ≤ 2 chars are excluded from scoring
 *     to prevent trivially short fragments from matching everything.
 *   • Length-aware Levenshtein edit-distance thresholds (not a fixed constant)
 *   • Phonetic normalization for common Indian transliteration variants
 *   • Configurable synonym and alias tables — NOT hardcoded neighbourhood lists
 *   • Multi-token coverage requirements
 *       1 token  → must match (coverage = 100 %)
 *       2 tokens → both must match (coverage = 100 %)
 *       3+ tokens → at least ⌈N × 0.6⌉ tokens must match
 *   • Relevance ordering: exact phrase ≥ normalised exact ≥ squashed ≥ partial ≥ fuzzy
 *   • Private encrypted addresses are only scored by the JS layer after Mongoose
 *     decrypts them in-memory — they are never used in MongoDB regex queries.
 */

const dataSecurity = require('../services/dataSecurity');

// ---------------------------------------------------------------------------
// Levenshtein distance (two-row space-optimised)
// ---------------------------------------------------------------------------

function levenshtein(a, b) {
  if (a === b) return 0;
  if (!a) return (b || '').length;
  if (!b) return a.length;

  const aLen = a.length;
  const bLen = b.length;
  let prev = new Array(bLen + 1);
  let curr = new Array(bLen + 1);

  for (let j = 0; j <= bLen; j++) prev[j] = j;

  for (let i = 1; i <= aLen; i++) {
    curr[0] = i;
    const aC = a.charCodeAt(i - 1);
    for (let j = 1; j <= bLen; j++) {
      const cost = aC === b.charCodeAt(j - 1) ? 0 : 1;
      curr[j] = Math.min(curr[j - 1] + 1, prev[j] + 1, prev[j - 1] + cost);
    }
    [prev, curr] = [curr, prev];
  }
  return prev[bLen];
}

function similarity(a, b) {
  if (!a && !b) return 1.0;
  if (!a || !b) return 0.0;
  if (a === b) return 1.0;
  const maxLen = Math.max(a.length, b.length);
  return (maxLen - levenshtein(a, b)) / maxLen;
}

// ---------------------------------------------------------------------------
// Text normalisation helpers
// ---------------------------------------------------------------------------

/**
 * Lowercase, collapse whitespace, strip non-alphanumeric characters to spaces.
 */
function normalizeText(text) {
  if (!text) return '';
  return String(text)
    .toLowerCase()
    .replace(/[^\w\s]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

/**
 * Squash all whitespace so "thilaknagar" and "thilak nagar" compare equal.
 */
function squashText(text) {
  return normalizeText(text).replace(/\s+/g, '');
}

/**
 * Phonetic reduction for common Indian transliteration variants.
 * Applied only for comparison — does not modify stored data.
 */
function phoneticNormalize(text) {
  let s = normalizeText(text);
  s = s.replace(/th/g, 't');   // thilak / tilak
  s = s.replace(/ph/g, 'f');   // photographer / fotographer
  s = s.replace(/ee/g, 'i');   // preethi / prithi
  s = s.replace(/oo/g, 'u');   // shoonya / shuunya
  s = s.replace(/sh/g, 's');   // sharma / sarma
  s = s.replace(/ck/g, 'k');   // black / blak
  return s;
}

// ---------------------------------------------------------------------------
// Configurable synonym / alias tables
// These are adjustable configuration, not hardcoded specific locations.
// ---------------------------------------------------------------------------

/**
 * Well-known Indian city colloquial aliases.
 * Key and value must both be lowercase.
 */
const CITY_ALIASES = {
  vizag:              'visakhapatnam',
  visakha:            'visakhapatnam',
  visakhapatnam:      'vizag',
  bangalore:          'bengaluru',
  bengaluru:          'bangalore',
  banglore:           'bengaluru',
  bombay:             'mumbai',
  mumbai:             'bombay',
  madras:             'chennai',
  chennai:            'madras',
  calcutta:           'kolkata',
  kolkata:            'calcutta',
  baroda:             'vadodara',
  vadodara:           'baroda',
  cochin:             'kochi',
  kochi:              'cochin',
  trivandrum:         'thiruvananthapuram',
  thiruvananthapuram: 'trivandrum',
  hyd:                'hyderabad',
  secbad:             'secunderabad',
  secunderabad:       'hyderabad',
};

/**
 * Semantic mapping of plain-English search terms to photographer category names.
 * All keys must be lowercase single words.
 * Add new terms here without touching the scoring algorithm.
 */
const CATEGORY_SYNONYMS = {
  wedding:        ['Traditional Photographer', 'Candid Photographer', 'Traditional Videographer', 'Cinematic Videographer'],
  weddings:       ['Traditional Photographer', 'Candid Photographer', 'Traditional Videographer', 'Cinematic Videographer'],
  marriage:       ['Traditional Photographer', 'Candid Photographer', 'Traditional Videographer', 'Cinematic Videographer'],
  shaadi:         ['Traditional Photographer', 'Candid Photographer', 'Traditional Videographer', 'Cinematic Videographer'],
  reception:      ['Traditional Photographer', 'Candid Photographer', 'Traditional Videographer', 'Cinematic Videographer'],
  engagement:     ['Traditional Photographer', 'Candid Photographer', 'Traditional Videographer', 'Cinematic Videographer'],
  pelli:          ['Traditional Photographer', 'Candid Photographer', 'Traditional Videographer', 'Cinematic Videographer'],
  candid:         ['Candid Photographer', 'Candid Videographer'],
  candids:        ['Candid Photographer', 'Candid Videographer'],
  portrait:       ['Candid Photographer'],
  portraits:      ['Candid Photographer'],
  traditional:    ['Traditional Photographer', 'Traditional Videographer'],
  drone:          ['Drones'],
  drones:         ['Drones'],
  aerial:         ['Drones'],
  flycam:         ['Drones'],
  mavic:          ['Drones'],
  cinematic:      ['Cinematic Videographer'],
  cinematography: ['Cinematic Videographer'],
  cinematographer:['Cinematic Videographer'],
  cinema:         ['Cinematic Videographer'],
  film:           ['Cinematic Videographer'],
  reels:          ['Cinematic Videographer', 'Candid Videographer'],
  video:          ['Traditional Videographer', 'Cinematic Videographer', 'Videography', 'Candid Videographer'],
  videographer:   ['Traditional Videographer', 'Cinematic Videographer', 'Videography', 'Candid Videographer'],
  videography:    ['Traditional Videographer', 'Cinematic Videographer', 'Videography', 'Candid Videographer'],
  vidiographer:   ['Traditional Videographer', 'Cinematic Videographer', 'Videography', 'Candid Videographer'],
  photo:          ['Traditional Photographer', 'Candid Photographer', 'Photographer'],
  photographer:   ['Traditional Photographer', 'Candid Photographer', 'Photographer'],
  photography:    ['Traditional Photographer', 'Candid Photographer', 'Photographer'],
  fotographer:    ['Traditional Photographer', 'Candid Photographer', 'Photographer'],
  led:            ['LED Screens'],
  screen:         ['LED Screens'],
  screens:        ['LED Screens'],
  display:        ['LED Screens'],
  live:           ['Internet Live Streaming'],
  stream:         ['Internet Live Streaming'],
  streaming:      ['Internet Live Streaming'],
  webcast:        ['Internet Live Streaming'],
  broadcast:      ['Internet Live Streaming'],
};

// ---------------------------------------------------------------------------
// Category synonym expansion
// ---------------------------------------------------------------------------

/**
 * Expand a query string into a de-duplicated set of matching category names.
 * Works for exact keyword matches and near-matches (similarity ≥ 0.80).
 */
function getRelatedCategoriesForQuery(query) {
  const norm = normalizeText(query);
  const words = norm.split(' ').filter(Boolean);
  const matched = new Set();

  for (const w of words) {
    if (w.length < 3) continue; // Short words cannot reliably map to categories

    // Exact key match
    if (CATEGORY_SYNONYMS[w]) {
      for (const cat of CATEGORY_SYNONYMS[w]) matched.add(cat);
    }

    // Near-match keys (substring containment or high similarity)
    for (const key of Object.keys(CATEGORY_SYNONYMS)) {
      if (key === w) continue;
      if (key.length >= 4 && (key.includes(w) || w.includes(key))) {
        for (const cat of CATEGORY_SYNONYMS[key]) matched.add(cat);
      } else if (key.length >= 5 && w.length >= 5 && similarity(w, key) >= 0.80) {
        for (const cat of CATEGORY_SYNONYMS[key]) matched.add(cat);
      }
    }
  }

  return Array.from(matched);
}

// ---------------------------------------------------------------------------
// Token-level fuzzy match
// ---------------------------------------------------------------------------

/**
 * Returns true if qToken and tToken are considered equivalent under any of:
 *   • Exact match
 *   • Meaningful substring containment (shorter part ≥ 3 chars)
 *   • City alias equivalence
 *   • Phonetic equivalence
 *   • Levenshtein distance within length-aware threshold
 *
 * Both arguments should already be normalised (lowercase, trimmed).
 */
function tokenFuzzyMatch(qToken, tToken) {
  if (!qToken || !tToken) return false;
  if (qToken === tToken) return true;

  // Guard: do not fuzzy-match trivially short tokens
  if (qToken.length <= 2 || tToken.length <= 2) return qToken === tToken;

  const shorter = Math.min(qToken.length, tToken.length);

  // Substring containment — only meaningful if the common part is ≥ 3 chars
  if (shorter >= 3 && (tToken.includes(qToken) || qToken.includes(tToken))) return true;

  // City alias equivalence
  const qAlias = CITY_ALIASES[qToken];
  if (qAlias && (qAlias === tToken || tToken.includes(qAlias))) return true;
  const tAlias = CITY_ALIASES[tToken];
  if (tAlias && (tAlias === qToken || qToken.includes(tAlias))) return true;

  // Phonetic equivalence
  const qP = phoneticNormalize(qToken);
  const tP = phoneticNormalize(tToken);
  if (qP === tP) return true;
  if (qP.length >= 3 && tP.length >= 3 && (tP.includes(qP) || qP.includes(tP))) return true;

  // Length-aware Levenshtein thresholds
  const maxLen = Math.max(qToken.length, tToken.length);
  const dist = levenshtein(qToken, tToken);
  if (maxLen <= 4 && dist <= 1) return true;
  if (maxLen <= 7 && dist <= 1) return true;
  if (maxLen >= 8 && dist <= 2) return true;
  if (maxLen >= 12 && dist <= 3) return true;

  // Phonetic Levenshtein
  if (levenshtein(qP, tP) <= 1) return true;

  return false;
}

// ---------------------------------------------------------------------------
// Per-token score helper
// ---------------------------------------------------------------------------

/**
 * Score a single query token against all target tokens.
 * Returns a score in [0, 1] where 0 means no match.
 * Scores: exact=1.0, partial-substr=0.85-0.9, fuzzy≥0.70.
 */
function scoreToken(qToken, targetTokens, squashedSearchable) {
  if (!qToken || qToken.length <= 2) return 0; // Short-token guard

  let best = 0;

  for (const tToken of targetTokens) {
    if (!tToken || tToken.length === 0) continue;

    if (qToken === tToken) {
      return 1.0; // Perfect match — early exit
    }

    const shorter = Math.min(qToken.length, tToken.length);

    if (shorter >= 3 && (tToken.includes(qToken) || qToken.includes(tToken))) {
      // Partial substring: scale by how much of the longer token is covered
      const longer = Math.max(qToken.length, tToken.length);
      const ratio = shorter / longer;
      best = Math.max(best, 0.80 + 0.10 * ratio); // 0.80–0.90
    } else if (tokenFuzzyMatch(qToken, tToken)) {
      const sim = similarity(qToken, tToken);
      best = Math.max(best, Math.max(sim, 0.70));
    }
  }

  // Squashed fallback: "thilaknagar" matches "thilak nagar"
  if (best < 0.70) {
    const squashedQ = squashText(qToken);
    if (squashedQ.length >= 3 && squashedSearchable.includes(squashedQ)) {
      best = Math.max(best, 0.75);
    }
  }

  return best;
}

// ---------------------------------------------------------------------------
// Profile scorer — the public API used by both MongoDB and memoryUsers paths
// ---------------------------------------------------------------------------

/**
 * Score a photographer user object against a free-text query.
 * Returns a number in [0, 1].  0 = no match, 1 = exact match.
 *
 * Coverage requirements (after filtering out tokens ≤ 2 chars):
 *   • 0 meaningful tokens → 1.0 (empty / trivially short query matches all)
 *   • 1 meaningful token  → must match (coverage 100 %)
 *   • 2 meaningful tokens → both must match (coverage 100 %)
 *   • 3+ meaningful tokens → at least ⌈count × 0.60⌉ tokens must match
 */
function scorePhotographerMatch(user, query) {
  if (!query || !query.trim()) return 1.0; // Empty query → show everything
  if (!user) return 0;

  // Decrypt address (Mongoose post-init already decrypts; this is a safety net).
  const rawAddress = user.address ? dataSecurity.decrypt(user.address) : '';

  // Normalise all searchable plain-text fields.
  const city       = normalizeText(user.city      || '');
  const district   = normalizeText(user.district  || '');
  const state      = normalizeText(user.state     || '');
  const address    = normalizeText(rawAddress);
  const studioName = normalizeText(user.studioName || '');
  const ownerName  = normalizeText(user.ownerName  || '');
  const username   = normalizeText(user.username   || '');
  const specialties= normalizeText(user.specialties || '');
  const about      = normalizeText(user.about      || '');
  const categories = Array.isArray(user.categories)
    ? user.categories.map((c) => normalizeText(c))
    : [];

  const normQuery    = normalizeText(query);
  const squashedQuery = squashText(query);

  // Split query into tokens; keep all for phrase matching, filter short for token scoring.
  const allTokens     = normQuery.split(' ').filter(Boolean);
  const meaningfulTokens = allTokens.filter((t) => t.length > 2);

  // Very short / empty query after normalisation → match everything
  if (meaningfulTokens.length === 0) return normQuery.length === 0 ? 1.0 : 0;

  // Combine all searchable text (address included — already decrypted by here)
  const combinedSearchable = [
    city, district, state, address,
    studioName, ownerName, username,
    specialties, about,
    ...categories,
  ].join(' ');

  const squashedSearchable = squashText(combinedSearchable);

  // ── Tier 1: exact phrase matches ─────────────────────────────────────────
  if (combinedSearchable.includes(normQuery)) return 1.0;
  if (squashedSearchable.includes(squashedQuery)) return 0.95;

  // ── Tier 2: category synonym expansion ───────────────────────────────────
  const relatedCategories = getRelatedCategoriesForQuery(query);
  let categoryScore = 0;
  if (relatedCategories.length > 0) {
    const hasCatMatch = categories.some((userCat) =>
      relatedCategories.some((relCat) => {
        const nr = normalizeText(relCat);
        return userCat.includes(nr) || nr.includes(userCat) || tokenFuzzyMatch(nr, userCat);
      }),
    );
    const hasSpecMatch = relatedCategories.some((relCat) =>
      specialties.includes(normalizeText(relCat)),
    );
    if (hasCatMatch || hasSpecMatch) categoryScore = 0.85;
  }

  // ── Tier 3: token-level scoring ───────────────────────────────────────────
  const targetTokens = combinedSearchable.split(' ').filter(Boolean);

  let matchedCount = 0;
  let totalScore   = 0;

  for (const qToken of meaningfulTokens) {
    const ts = scoreToken(qToken, targetTokens, squashedSearchable);
    if (ts >= 0.70) {
      matchedCount++;
      totalScore += ts;
    }
  }

  // ── Coverage gate ─────────────────────────────────────────────────────────
  const n = meaningfulTokens.length;
  let requiredMatches;
  if (n <= 2) {
    requiredMatches = n; // all tokens must match for 1- or 2-word queries
  } else {
    requiredMatches = Math.ceil(n * 0.60);
  }

  if (matchedCount < requiredMatches) {
    // Category synonym match can rescue a zero-result location query
    return categoryScore > 0 ? categoryScore : 0;
  }

  const avgTokenScore = totalScore / matchedCount;
  const coverage      = matchedCount / n;
  const tokenContrib  = avgTokenScore * (0.70 + 0.30 * coverage); // weight by coverage

  return Math.max(tokenContrib, categoryScore);
}

// ---------------------------------------------------------------------------
// Typo-tolerant regex builder for MongoDB candidate retrieval
// (used in userRepository.js to broaden the initial candidate set)
// ---------------------------------------------------------------------------

/**
 * Build a regex pattern that matches common spelling variants of a word.
 * Only handles digraphs and common vowel alternations; does not produce
 * patterns specific to any particular place name.
 */
function buildTypoRegex(word) {
  if (!word || word.length < 3) return escapeRegexForExport(word || '');
  const lower = word.toLowerCase();
  let pattern = '';

  for (let i = 0; i < lower.length; i++) {
    const ch   = lower[i];
    const next = lower[i + 1] || '';

    if (ch === 't' && next === 'h') {
      pattern += 't[h]?'; i++;
    } else if (ch === 'p' && next === 'h') {
      pattern += '(?:ph|f)'; i++;
    } else if (ch === 'e' && next === 'e') {
      pattern += '(?:ee|i)'; i++;
    } else if (ch === 'o' && next === 'o') {
      pattern += '(?:oo|u)'; i++;
    } else if (ch === 'a' && i === lower.length - 2 && lower[i + 1] === 'r') {
      pattern += '[ae]'; // "nagar" / "nager"
    } else if (ch === 'e' && i === lower.length - 2 && lower[i + 1] === 'r') {
      pattern += '[ae]';
    } else {
      pattern += ch.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    }
  }
  return pattern;
}

function escapeRegexForExport(value) {
  return String(value || '').replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

// ---------------------------------------------------------------------------
// Exports
// ---------------------------------------------------------------------------

module.exports = {
  levenshtein,
  similarity,
  normalizeText,
  squashText,
  phoneticNormalize,
  tokenFuzzyMatch,
  getRelatedCategoriesForQuery,
  scorePhotographerMatch,
  buildTypoRegex,
  CITY_ALIASES,
  CATEGORY_SYNONYMS,
};
