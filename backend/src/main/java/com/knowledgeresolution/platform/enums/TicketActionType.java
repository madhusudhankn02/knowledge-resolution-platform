package com.knowledgeresolution.platform.enums;

/** Stored as text; the values match the CHECK constraint in the database. */
public enum TicketActionType {
    CREATED,
    STATUS_CHANGED,
    ASSIGNED,
    REASSIGNED,
    PRIORITY_CHANGED,
    CATEGORY_CHANGED,
    RECOMMENDATION_ADDED,
    RESOLUTION_ADDED,
    FEEDBACK_SUBMITTED,
    REOPENED
}
