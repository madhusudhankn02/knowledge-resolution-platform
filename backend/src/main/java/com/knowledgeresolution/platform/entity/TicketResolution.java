package com.knowledgeresolution.platform.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.SourceType;

/**
 * One resolution attempt. A ticket can have several attempts (e.g. after a reopen), but the database
 * allows only one with is_current = true per ticket (partial unique index).
 */
@Entity
@Table(name = "ticket_resolutions")
public class TicketResolution {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "ticket_id", nullable = false)
    private SupportTicket ticket;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "resolved_by", nullable = false)
    private User resolvedBy;

    /** Optional: the knowledge article that helped solve the ticket. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "article_id")
    private KnowledgeArticle article;

    @Column(name = "resolution_summary", nullable = false, columnDefinition = "text")
    private String resolutionSummary;

    @Column(name = "attempt_number", nullable = false)
    private int attemptNumber;

    @Column(name = "is_current", nullable = false)
    private boolean current = true;

    /** Database clock at insert time. */
    @CreationTimestamp(source = SourceType.DB)
    @Column(name = "resolved_at", nullable = false, updatable = false)
    private Instant resolvedAt;

    @CreationTimestamp(source = SourceType.DB)
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    protected TicketResolution() {
        // required by JPA
    }

    public TicketResolution(SupportTicket ticket, User resolvedBy, KnowledgeArticle article,
                            String resolutionSummary, int attemptNumber) {
        this.ticket = ticket;
        this.resolvedBy = resolvedBy;
        this.article = article;
        this.resolutionSummary = resolutionSummary;
        this.attemptNumber = attemptNumber;
    }

    public Long getId() { return id; }
    public SupportTicket getTicket() { return ticket; }
    public User getResolvedBy() { return resolvedBy; }
    public KnowledgeArticle getArticle() { return article; }
    public String getResolutionSummary() { return resolutionSummary; }
    public int getAttemptNumber() { return attemptNumber; }
    public boolean isCurrent() { return current; }
    public void setCurrent(boolean current) { this.current = current; }
    public Instant getResolvedAt() { return resolvedAt; }
    public Instant getCreatedAt() { return createdAt; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof TicketResolution other)) return false;
        return id != null && id.equals(other.getId());
    }

    @Override
    public int hashCode() { return getClass().hashCode(); }

    @Override
    public String toString() { return "TicketResolution{id=" + id + ", attempt=" + attemptNumber + ", current=" + current + "}"; }
}
