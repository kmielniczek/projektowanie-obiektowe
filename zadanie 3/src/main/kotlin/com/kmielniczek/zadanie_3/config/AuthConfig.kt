package com.kmielniczek.zadanie_3.config

import com.kmielniczek.zadanie_3.service.AuthService
import com.kmielniczek.zadanie_3.service.MockAuthService
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Lazy
import org.springframework.context.annotation.Primary

@Configuration
class AuthConfig {
    @Bean
    @Primary
    fun mockAuthService(): AuthService {
        return MockAuthService()
    }

    @Bean
    @Lazy
    fun lazyMockAuthService(): AuthService {
        return MockAuthService()
    }
}
