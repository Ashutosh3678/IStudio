const LEVELS = { error: 0, warn: 1, info: 2, debug: 3 };

const SENSITIVE_KEY = /password|secret|token|authorization|otp|mongodb_uri|api[_-]?key|api[_-]?secret|cookie|encryption_key/i;

function levelFromEnv(env = process.env) {
  const raw = String(env.LOG_LEVEL || '').trim().toLowerCase();
  if (raw && Object.prototype.hasOwnProperty.call(LEVELS, raw)) return raw;
  if (env.NODE_ENV === 'test') return 'error';
  if (env.NODE_ENV === 'production') return 'info';
  return 'debug';
}

function serializeError(error) {
  if (!error) return undefined;
  if (!(error instanceof Error) && typeof error === 'object') {
    return redact(error);
  }
  const serialized = {
    name: error.name,
    message: error.message,
  };
  if (error.stack) serialized.stack = error.stack;
  if (error.code) serialized.code = error.code;
  if (error.statusCode) serialized.statusCode = error.statusCode;
  return serialized;
}

function redact(value, key = '') {
  if (key && SENSITIVE_KEY.test(key)) return '[redacted]';
  if (value == null) return value;
  if (typeof value === 'string') {
    if (SENSITIVE_KEY.test(key)) return '[redacted]';
    return value;
  }
  if (value instanceof Error) return serializeError(value);
  if (Array.isArray(value)) return value.map((item) => redact(item, key));
  if (typeof value === 'object') {
    const copy = {};
    for (const [childKey, childValue] of Object.entries(value)) {
      copy[childKey] = redact(childValue, childKey);
    }
    return copy;
  }
  return value;
}

function formatPretty(entry) {
  const { time, level, msg, ...rest } = entry;
  const extras = Object.keys(rest).length ? ` ${JSON.stringify(rest)}` : '';
  return `${time} ${level.toUpperCase()} ${msg}${extras}`;
}

function maskPhone(phone) {
  const digits = String(phone || '').replace(/\D/g, '');
  if (digits.length < 4) return '[redacted]';
  return `${digits.slice(0, 2)}****${digits.slice(-2)}`;
}

function maskEmail(email) {
  if (!email) return '';
  const plain = String(email).trim();
  const atIdx = plain.indexOf('@');
  if (atIdx <= 1) return '***@' + (plain.split('@')[1] || '');
  const userPart = plain.slice(0, atIdx);
  const domainPart = plain.slice(atIdx);
  if (userPart.length <= 2) {
    return `${userPart[0]}***${domainPart}`;
  }
  return `${userPart[0]}***${userPart[userPart.length - 1]}${domainPart}`;
}

function maskReference(ref) {
  if (!ref) return '';
  const plain = String(ref).trim();
  if (plain.length < 8) return '****';
  const prefix = plain.slice(0, Math.min(3, Math.floor(plain.length / 3)));
  const suffix = plain.slice(-Math.min(4, Math.floor(plain.length / 3)));
  return `${prefix}****${suffix}`;
}

function fromRequest(req, extra) {
  const meta = extra instanceof Error ? { error: extra } : { ...(extra || {}) };
  if (req && req.requestId) meta.requestId = req.requestId;
  if (req && req.userId) meta.userId = req.userId;
  return meta;
}

function createLogger({ env = process.env, stream = process.stdout } = {}) {
  function write(level, msg, meta) {
    const minLevel = levelFromEnv(env);
    if (LEVELS[level] > LEVELS[minLevel]) return;
    const jsonLogs =
      String(env.LOG_FORMAT || '').toLowerCase() === 'json' ||
      env.NODE_ENV === 'production';
    let fields = {};
    if (meta instanceof Error) {
      fields = { error: serializeError(meta) };
    } else if (meta && typeof meta === 'object') {
      fields = redact(meta);
      if (fields.error instanceof Error || (meta.error instanceof Error)) {
        fields.error = serializeError(meta.error);
      }
    }
    const entry = {
      time: new Date().toISOString(),
      level,
      msg: String(msg),
      ...fields,
    };
    const line = jsonLogs ? JSON.stringify(entry) : formatPretty(entry);
    stream.write(`${line}\n`);
  }

  return {
    get level() {
      return levelFromEnv(env);
    },
    error(msg, meta) {
      write('error', msg, meta);
    },
    warn(msg, meta) {
      write('warn', msg, meta);
    },
    info(msg, meta) {
      write('info', msg, meta);
    },
    debug(msg, meta) {
      write('debug', msg, meta);
    },
    child(bindings = {}) {
      const parent = this;
      const safeBindings = redact(bindings);
      return {
        error(msg, meta) {
          parent.error(msg, { ...safeBindings, ...(meta instanceof Error ? { error: meta } : meta) });
        },
        warn(msg, meta) {
          parent.warn(msg, { ...safeBindings, ...(meta instanceof Error ? { error: meta } : meta) });
        },
        info(msg, meta) {
          parent.info(msg, { ...safeBindings, ...(meta instanceof Error ? { error: meta } : meta) });
        },
        debug(msg, meta) {
          parent.debug(msg, { ...safeBindings, ...(meta instanceof Error ? { error: meta } : meta) });
        },
      };
    },
  };
}

const logger = createLogger();

module.exports = logger;
module.exports.createLogger = createLogger;
module.exports.redact = redact;
module.exports.serializeError = serializeError;
module.exports.levelFromEnv = levelFromEnv;
module.exports.maskPhone = maskPhone;
module.exports.maskEmail = maskEmail;
module.exports.maskReference = maskReference;
module.exports.fromRequest = fromRequest;
