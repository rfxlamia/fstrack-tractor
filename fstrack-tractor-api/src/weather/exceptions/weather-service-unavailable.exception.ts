import { HttpException, HttpStatus } from '@nestjs/common';

/**
 * Exception thrown when weather service is unavailable.
 * Returns HTTP 503 SERVICE_UNAVAILABLE with Bahasa Indonesia message.
 */
export class WeatherServiceUnavailableException extends HttpException {
  constructor(message = 'Layanan cuaca tidak tersedia') {
    super(message, HttpStatus.SERVICE_UNAVAILABLE);
  }
}
