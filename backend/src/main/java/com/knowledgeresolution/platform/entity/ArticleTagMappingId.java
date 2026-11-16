package com.knowledgeresolution.platform.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.io.Serializable;
import java.util.Objects;

/** Composite primary key (article_id, tag_id). Must be Serializable with value-based equals/hashCode. */
@Embeddable
public class ArticleTagMappingId implements Serializable {

    private static final long serialVersionUID = 1L;

    @Column(name = "article_id", nullable = false)
    private Long articleId;

    @Column(name = "tag_id", nullable = false)
    private Long tagId;

    protected ArticleTagMappingId() {
        // required by JPA
    }

    public ArticleTagMappingId(Long articleId, Long tagId) {
        this.articleId = articleId;
        this.tagId = tagId;
    }

    public Long getArticleId() { return articleId; }
    public Long getTagId() { return tagId; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ArticleTagMappingId other)) return false;
        return Objects.equals(articleId, other.articleId) && Objects.equals(tagId, other.tagId);
    }

    @Override
    public int hashCode() { return Objects.hash(articleId, tagId); }
}
