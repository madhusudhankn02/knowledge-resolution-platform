package com.knowledgeresolution.platform.dto;

import java.time.Instant;

/** Response body for the health endpoint. A record gives an immutable DTO with no boilerplate. */
public record HealthResponse(String status, String service, Instant timestamp) {
}
