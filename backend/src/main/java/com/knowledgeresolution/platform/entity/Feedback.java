package com.knowledgeresolution.platform.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.SourceType;

/**
 * Customer feedback, one record per ticket.
 *
 * <p>Mapping note: in SQL, (ticket_id, customer_id) is a COMPOSITE foreign key to support_tickets
 * (id, customer_id), which guarantees the author owns the ticket. JPA cannot express that constraint
 * safely without a shared-column mapping, so the two columns are mapped as separate associations.
 * The database still enforces ownership; the service layer must set customer = ticket.getCustomer().
 */
@Entity
@Table(name = "feedback")
public class Feedback {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "ticket_id", nullable = false, updatable = false, unique = true)
    private SupportTicket ticket;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "customer_id", nullable = false, updatable = false)
    private Customer customer;

    @Column(name = "rating", nullable = false)
    private short rating;

    @Column(name = "comment", length = 2000)
    private String comment;

    @CreationTimestamp(source = SourceType.DB)
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    protected Feedback() {
        // required by JPA
    }

    public Feedback(SupportTicket ticket, Customer customer, short rating, String comment) {
        this.ticket = ticket;
        this.customer = customer;
        this.rating = rating;
        this.comment = comment;
    }

    public Long getId() { return id; }
    public SupportTicket getTicket() { return ticket; }
    public Customer getCustomer() { return customer; }
    public short getRating() { return rating; }
    public String getComment() { return comment; }
    public Instant getCreatedAt() { return createdAt; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Feedback other)) return false;
        return id != null && id.equals(other.getId());
    }

    @Override
    public int hashCode() { return getClass().hashCode(); }

    @Override
    public String toString() { return "Feedback{id=" + id + ", rating=" + rating + "}"; }
}
