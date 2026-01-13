/**
 * Symbol-based injection token for Weather Provider.
 * Enables swappable provider implementation (OpenWeatherMap, AWS, etc.)
 */
export const WEATHER_PROVIDER = Symbol('WEATHER_PROVIDER');

/**
 * Weather data returned from weather provider.
 * All fields are required for consistent display in Flutter widget.
 */
export interface WeatherData {
  /** Temperature in Celsius, rounded integer */
  temperature: number;
  /** Weather condition description in Bahasa Indonesia from API */
  condition: string;
  /** Weather icon code for display (e.g., "02d") */
  icon: string;
  /** Humidity percentage 0-100 */
  humidity: number;
  /** Location name from API response */
  location: string;
  /** ISO 8601 timestamp of weather data */
  timestamp: string;
}

/**
 * Interface for weather provider implementations.
 * Follows Adapter Pattern for swappable weather data sources.
 */
export interface WeatherProviderInterface {
  /**
   * Get current weather for given coordinates.
   * @param lat Latitude coordinate
   * @param lon Longitude coordinate
   * @returns Promise resolving to WeatherData
   */
  getCurrentWeather(lat: number, lon: number): Promise<WeatherData>;
}
