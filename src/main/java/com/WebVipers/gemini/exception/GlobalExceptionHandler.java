package com.WebVipers.gemini.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.client.RestClientException;

import java.time.Instant;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(IllegalArgumentException.class)
    ResponseEntity<ApiError> badRequest(IllegalArgumentException ex, WebRequest request) {
        return error(HttpStatus.BAD_REQUEST, ex.getMessage(), request);
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    ResponseEntity<ApiError> tooLarge(MaxUploadSizeExceededException ex, WebRequest request) {
        return error(HttpStatus.PAYLOAD_TOO_LARGE, "L’image dépasse la taille maximale autorisée de 10 Mo.", request);
    }

    @ExceptionHandler(IllegalStateException.class)
    ResponseEntity<ApiError> state(IllegalStateException ex, WebRequest request) {
        return error(HttpStatus.SERVICE_UNAVAILABLE, ex.getMessage(), request);
    }

    @ExceptionHandler(RestClientException.class)
    ResponseEntity<ApiError> upstream(RestClientException ex, WebRequest request) {
        return error(HttpStatus.BAD_GATEWAY, "Gemini est temporairement indisponible ou a refusé la requête.", request);
    }

    @ExceptionHandler(Exception.class)
    ResponseEntity<ApiError> generic(Exception ex, WebRequest request) {
        return error(HttpStatus.INTERNAL_SERVER_ERROR, "Une erreur interne est survenue.", request);
    }

    private ResponseEntity<ApiError> error(HttpStatus status, String message, WebRequest request) {
        String path = request.getDescription(false).replace("uri=", "");
        return ResponseEntity.status(status)
                .body(new ApiError(Instant.now(), status.value(), status.getReasonPhrase(), message, path));
    }
}