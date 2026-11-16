-- V10: secondary indexes. PostgreSQL does not index foreign-key columns automatically.

-- support_tickets
CREATE INDEX ix_tickets_status            ON support_tickets (status);
CREATE INDEX ix_tickets_agent_status      ON support_tickets (assigned_agent_id, status);
CREATE INDEX ix_tickets_customer_created  ON support_tickets (customer_id, created_at DESC);
CREATE INDEX ix_tickets_category          ON support_tickets (category_id);
CREATE INDEX ix_tickets_priority_status   ON support_tickets (priority, status);

-- knowledge_articles
CREATE INDEX ix_articles_category_status  ON knowledge_articles (category_id, status);
CREATE INDEX ix_articles_author           ON knowledge_articles (author_id);
CREATE INDEX ix_articles_search_vector    ON knowledge_articles USING GIN (search_vector);

-- links and child tables
CREATE INDEX ix_atm_tag                   ON article_tag_mappings (tag_id);
CREATE INDEX ix_recommendations_article   ON ticket_recommendations (article_id);
CREATE INDEX ix_resolutions_resolver      ON ticket_resolutions (resolved_by);
CREATE INDEX ix_resolutions_article       ON ticket_resolutions (article_id);
CREATE INDEX ix_history_ticket_created    ON ticket_history (ticket_id, created_at);
CREATE INDEX ix_history_user              ON ticket_history (performed_by);
