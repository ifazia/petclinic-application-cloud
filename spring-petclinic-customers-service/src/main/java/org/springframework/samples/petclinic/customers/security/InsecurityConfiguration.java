package org.springframework.samples.petclinic.customers.security;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.builders.WebSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class InsecurityConfiguration {

    private final static Logger log = LoggerFactory.getLogger(InsecurityConfiguration.class);

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        log.warn("configuring insecure HttpSecurity");
        http
            .authorizeHttpRequests(auth -> auth
                .anyRequest().permitAll()
            )
            .httpBasic().disable()
            .csrf().disable();
        return http.build();
    }

    @Bean
    public void configure(WebSecurity web) throws Exception {
        log.warn("configuring insecure WebSecurity");
        web.ignoring().requestMatchers("/**"); // Utilisez requestMatchers au lieu de antMatchers
    }
}