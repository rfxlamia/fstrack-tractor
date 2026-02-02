// src/config/configuration.ts
export default () => {
  // Support DATABASE_URL (Supabase/Railway/Render) or individual vars
  const parseDatabaseUrl = (url: string) => {
    const match = url.match(/postgres(?:ql)?:\/\/([^:]+):([^@]+)@([^:]+):(\d+)\/(.+)/);
    if (!match) return null;
    return {
      username: match[1],
      password: match[2],
      host: match[3],
      port: parseInt(match[4], 10),
      name: match[5].split('?')[0], // Remove query params
    };
  };

  const getDatabaseConfig = () => {
    if (process.env.DATABASE_URL) {
      const parsed = parseDatabaseUrl(process.env.DATABASE_URL);
      if (parsed) return parsed;
    }

    // Fallback to individual env vars
    return {
      host: process.env.DATABASE_HOST || 'localhost',
      port: parseInt(process.env.DATABASE_PORT ?? '', 10) || 5432,
      name: process.env.DATABASE_NAME || 'fstrack_tractor',
      username: process.env.DATABASE_USERNAME || 'postgres',
      password: process.env.DATABASE_PASSWORD || '',
    };
  };

  return {
    nodeEnv: process.env.NODE_ENV || 'development',
    port: parseInt(process.env.PORT ?? '', 10) || 3000,
    cors: {
      // In development, allow all origins. In production, restrict to specific domain.
      origin:
        process.env.CORS_ORIGIN ||
        (process.env.NODE_ENV === 'production' ? false : true),
    },
    database: getDatabaseConfig(),
    jwt: {
      secret: (() => {
        const secret = process.env.JWT_SECRET;
        if (!secret && process.env.NODE_ENV === 'production') {
          throw new Error(
            'JWT_SECRET environment variable is required in production',
          );
        }
        return secret || 'dev-only-secret-change-in-production';
      })(),
      expiresIn: process.env.JWT_EXPIRES_IN || '14d',
    },
    throttle: {
      ttl: parseInt(process.env.THROTTLE_TTL ?? '', 10) || 900,
      limit: parseInt(process.env.THROTTLE_LIMIT ?? '', 10) || 5,
    },
    weather: {
      apiKey: (() => {
        const key = process.env.OPENWEATHERMAP_API_KEY;
        if (!key && process.env.NODE_ENV === 'production') {
          console.warn('OPENWEATHERMAP_API_KEY not set - weather API will fail');
        }
        return key || '';
      })(),
      timeout: 5000,
      defaultLocation: {
        latitude: -4.8357,
        longitude: 105.0273,
        name: 'Lampung Tengah',
      },
    },
  };
};
