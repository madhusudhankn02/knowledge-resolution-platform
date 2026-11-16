package com.knowledgeresolution.platform.entity;

import com.knowledgeresolution.platform.enums.TicketActionType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.Immutable;
import org.hibernate.annotations.SourceType;

/** Append-only audit record. @Immutable makes Hibernate refuse to UPDATE it after it is inserted. */
@Entity
@Immutable
@Table(name = "ticket_history")
public class TicketHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "ticket_id", nullable = false)
    private SupportTicket ticket;

    /** null for actions performed by the system. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "performed_by")
    private User performedBy;

    @Enumerated(EnumType.STRING)
    @Column(name = "action_type", nullable = false, length = 30)
    private TicketActionType actionType;

    @Column(name = "old_value", length = 100)
    private String oldValue;

    @Column(name = "new_value", length = 100)
    private String newValue;

    @Column(name = "note", length = 1000)
    private String note;

    @CreationTimestamp(source = SourceType.DB)
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    protected TicketHistory() {
        // required by JPA
    }

    public TicketHistory(SupportTicket ticket, User performedBy, TicketActionType actionType,
                         String oldValue, String newValue, String note) {
        this.ticket = ticket;
        this.performedBy = performedBy;
        this.actionType = actionType;
        this.oldValue = oldValue;
        this.newValue = newValue;
        this.note = note;
    }

    public Long getId() { return id; }
    public SupportTicket getTicket() { return ticket; }
    public User getPerformedBy() { return performedBy; }
    public TicketActionType getActionType() { return actionType; }
    public String getOldValue() { return oldValue; }
    public String getNewValue() { return newValue; }
    public String getNote() { return note; }
    public Instant getCreatedAt() { return createdAt; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof TicketHistory other)) return false;
        return id != null && id.equals(other.getId());
    }

    @Override
    public int hashCode() { return getClass().hashCode(); }

    @Override
    public String toString() { return "TicketHistory{id=" + id + ", action=" + actionType + "}"; }
}
