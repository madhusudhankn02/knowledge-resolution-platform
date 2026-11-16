package com.knowledgeresolution.platform.entity;

import com.knowledgeresolution.platform.enums.RecommendationSource;
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
import java.math.BigDecimal;
import java.time.Instant;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.SourceType;

@Entity
@Table(name = "ticket_recommendations")
public class TicketRecommendation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "ticket_id", nullable = false)
    private SupportTicket ticket;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "article_id", nullable = false)
    private KnowledgeArticle article;

    /** Between 0 and 1 (database CHECK). BigDecimal matches NUMERIC(5,4) exactly, with no floating-point error. */
    @Column(name = "relevance_score", nullable = false, precision = 5, scale = 4)
    private BigDecimal relevanceScore;

    @Column(name = "rank_position", nullable = false)
    private short rankPosition;

    @Enumerated(EnumType.STRING)
    @Column(name = "source", nullable = false, length = 10)
    private RecommendationSource source = RecommendationSource.SYSTEM;

    /** null = not yet reviewed by an agent. */
    @Column(name = "is_helpful")
    private Boolean helpful;

    @CreationTimestamp(source = SourceType.DB)
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    protected TicketRecommendation() {
        // required by JPA
    }

    public TicketRecommendation(SupportTicket ticket, KnowledgeArticle article, BigDecimal relevanceScore,
                                short rankPosition, RecommendationSource source) {
        this.ticket = ticket;
        this.article = article;
        this.relevanceScore = relevanceScore;
        this.rankPosition = rankPosition;
        this.source = source;
    }

    public Long getId() { return id; }
    public SupportTicket getTicket() { return ticket; }
    public KnowledgeArticle getArticle() { return article; }
    public BigDecimal getRelevanceScore() { return relevanceScore; }
    public short getRankPosition() { return rankPosition; }
    public RecommendationSource getSource() { return source; }
    public Boolean getHelpful() { return helpful; }
    public void setHelpful(Boolean helpful) { this.helpful = helpful; }
    public Instant getCreatedAt() { return createdAt; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof TicketRecommendation other)) return false;
        return id != null && id.equals(other.getId());
    }

    @Override
    public int hashCode() { return getClass().hashCode(); }

    @Override
    public String toString() { return "TicketRecommendation{id=" + id + ", rank=" + rankPosition + "}"; }
}
