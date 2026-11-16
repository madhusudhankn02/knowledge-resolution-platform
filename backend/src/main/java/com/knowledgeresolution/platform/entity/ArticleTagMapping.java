package com.knowledgeresolution.platform.entity;

import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.Table;

/**
 * Link row between an article and a tag. Mapped as an entity (instead of @ManyToMany) because it is one of the
 * 11 tables and keeps tagging explicit, with no hidden cascades. No cascade is configured anywhere.
 */
@Entity
@Table(name = "article_tag_mappings")
public class ArticleTagMapping {

    @EmbeddedId
    private ArticleTagMappingId id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("articleId")
    @JoinColumn(name = "article_id", nullable = false)
    private KnowledgeArticle article;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("tagId")
    @JoinColumn(name = "tag_id", nullable = false)
    private ArticleTag tag;

    protected ArticleTagMapping() {
        // required by JPA
    }

    public ArticleTagMapping(KnowledgeArticle article, ArticleTag tag) {
        this.article = article;
        this.tag = tag;
        this.id = new ArticleTagMappingId(article.getId(), tag.getId());
    }

    public ArticleTagMappingId getId() { return id; }
    public KnowledgeArticle getArticle() { return article; }
    public ArticleTag getTag() { return tag; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ArticleTagMapping other)) return false;
        return id != null && id.equals(other.getId());
    }

    @Override
    public int hashCode() { return getClass().hashCode(); }

    @Override
    public String toString() { return "ArticleTagMapping{id=" + id + "}"; }
}
