package com.kmielniczek.zadanie_3.config

import com.kmielniczek.zadanie_3.model.ApiErrorResponse
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.MissingRequestHeaderException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice
import org.springframework.web.server.ResponseStatusException
import org.springframework.web.servlet.NoHandlerFoundException
import org.springframework.web.servlet.resource.NoResourceFoundException

@RestControllerAdvice
class GlobalExceptionHandler {
    @ExceptionHandler(NoHandlerFoundException::class, NoResourceFoundException::class)
    fun handleNotFoundException(): ResponseEntity<ApiErrorResponse> {
        val statusCode = HttpStatus.NOT_FOUND
        val body =
                ApiErrorResponse(
                        status = statusCode.value(),
                        message = "Resource not found",
                )

        return ResponseEntity.status(statusCode).body(body)
    }

    @ExceptionHandler(ResponseStatusException::class)
    fun handleResponseStatusException(
            exception: ResponseStatusException
    ): ResponseEntity<ApiErrorResponse> {
        val statusCode = exception.statusCode
        val body =
                ApiErrorResponse(
                        status = statusCode.value(),
                        message = exception.reason ?: "Request failed",
                )

        return ResponseEntity.status(statusCode).body(body)
    }

    @ExceptionHandler(MissingRequestHeaderException::class)
    fun handleMissingHeaderException(
            exception: MissingRequestHeaderException
    ): ResponseEntity<ApiErrorResponse> {
        val statusCode = HttpStatus.BAD_REQUEST
        val body =
                ApiErrorResponse(
                        status = statusCode.value(),
                        message = exception.message ?: "Missing required request header",
                )

        return ResponseEntity.status(statusCode).body(body)
    }

    @ExceptionHandler(Exception::class)
    fun handleGenericException(): ResponseEntity<ApiErrorResponse> {
        val statusCode = HttpStatus.INTERNAL_SERVER_ERROR
        val body =
                ApiErrorResponse(
                        status = statusCode.value(),
                        message = "Internal server error",
                )

        return ResponseEntity.status(statusCode).body(body)
    }
}
