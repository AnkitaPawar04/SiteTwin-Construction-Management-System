<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\Log;

class RequestResponseLogger
{
    /**
     * Handle an incoming request and log request/response details.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $startTime = microtime(true);
        
        // Log incoming request
        $requestLog = [
            'type' => 'REQUEST',
            'timestamp' => now()->toIso8601String(),
            'method' => $request->method(),
            'url' => $request->fullUrl(),
            'path' => $request->path(),
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'headers' => $this->sanitizeHeaders($request->headers->all()),
            'query_params' => $request->query(),
            'body' => $this->sanitizeBody($request->all()),
        ];

        $this->logToConsole($requestLog);

        // Process the request
        $response = $next($request);

        // Calculate duration
        $duration = round((microtime(true) - $startTime) * 1000, 2);

        // Log outgoing response
        $responseLog = [
            'type' => 'RESPONSE',
            'timestamp' => now()->toIso8601String(),
            'method' => $request->method(),
            'url' => $request->fullUrl(),
            'path' => $request->path(),
            'status_code' => $response->getStatusCode(),
            'status_text' => Response::$statusTexts[$response->getStatusCode()] ?? 'Unknown',
            'duration_ms' => $duration,
            'headers' => $response->headers->all(),
            'body' => $this->getResponseBody($response),
        ];

        $this->logToConsole($responseLog);

        return $response;
    }

    /**
     * Sanitize headers to remove sensitive information
     */
    private function sanitizeHeaders(array $headers): array
    {
        $sanitized = $headers;
        
        // Remove or mask sensitive headers
        $sensitiveHeaders = ['authorization', 'cookie', 'x-csrf-token'];
        
        foreach ($sensitiveHeaders as $header) {
            if (isset($sanitized[$header])) {
                $sanitized[$header] = ['***REDACTED***'];
            }
        }
        
        return $sanitized;
    }

    /**
     * Sanitize request body to remove sensitive information
     */
    private function sanitizeBody(array $body): array
    {
        $sanitized = $body;
        
        // Remove or mask sensitive fields
        $sensitiveFields = ['password', 'password_confirmation', 'token', 'secret'];
        
        foreach ($sensitiveFields as $field) {
            if (isset($sanitized[$field])) {
                $sanitized[$field] = '***REDACTED***';
            }
        }
        
        return $sanitized;
    }

    /**
     * Get response body content
     */
    private function getResponseBody(Response $response): mixed
    {
        $content = $response->getContent();
        
        // Try to decode JSON response
        $decoded = json_decode($content, true);
        
        if (json_last_error() === JSON_ERROR_NONE) {
            return $decoded;
        }
        
        // If not JSON, return truncated string
        return strlen($content) > 500 
            ? substr($content, 0, 500) . '... (truncated)' 
            : $content;
    }

    /**
     * Log to console/command line
     */
    private function logToConsole(array $data): void
    {
        $json = json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
        
        // Output to stderr so it appears in console
        error_log($json);
        
        // Also log to Laravel log for persistence
        Log::channel('single')->info($json);
    }
}
