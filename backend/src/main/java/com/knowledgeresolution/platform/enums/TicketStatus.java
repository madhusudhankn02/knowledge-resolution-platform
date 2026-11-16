package com.knowledgeresolution.platform.enums;

/** Stored as text; the values match the CHECK constraint in the database. */
public enum TicketStatus {
    OPEN,
    ASSIGNED,
    IN_PROGRESS,
    WAITING_ON_CUSTOMER,
    RESOLVED,
    CLOSED,
    REOPENED
}
