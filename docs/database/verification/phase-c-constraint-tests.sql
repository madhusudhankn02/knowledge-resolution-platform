-- Constraint behaviour tests for M2 Phase C. Every statement is expected to FAIL.
-- Everything runs in one transaction that is rolled back, so no data is changed.
-- Requires the dev seed data. Output: one line per test, PASS when the database rejected the statement.
BEGIN;
CREATE TEMP TABLE test_results (test text, result text) ON COMMIT DROP;

DO $$
DECLARE
  t   record;
  uid bigint; cid bigint; catid bigint;
  tk  bigint; other_cust bigint;
BEGIN
  SELECT id INTO catid FROM categories ORDER BY id LIMIT 1;
  SELECT c.id INTO cid FROM customers c ORDER BY c.id LIMIT 1;
  SELECT c.id INTO other_cust FROM customers c WHERE c.id <> cid ORDER BY c.id LIMIT 1;
  SELECT id INTO tk FROM support_tickets WHERE customer_id = cid AND status = 'OPEN' LIMIT 1;
  IF tk IS NULL THEN SELECT id INTO tk FROM support_tickets WHERE customer_id = cid LIMIT 1; END IF;

  -- each test: run the bad statement in a sub-block; a caught error means the rule works
  BEGIN INSERT INTO users(email,full_name,password_hash,role) VALUES ('ADMIN@dev-seed.invalid','Dup','!','ADMIN');
    INSERT INTO test_results VALUES ('duplicate email (case-insensitive)','FAIL: accepted');
  EXCEPTION WHEN unique_violation THEN INSERT INTO test_results VALUES ('duplicate email (case-insensitive)','PASS'); END;

  BEGIN INSERT INTO users(email,full_name,password_hash,role) VALUES ('plain@dev-seed.invalid','P','secret123','ADMIN');
    INSERT INTO test_results VALUES ('plaintext password rejected','FAIL: accepted');
  EXCEPTION WHEN check_violation THEN INSERT INTO test_results VALUES ('plaintext password rejected','PASS'); END;

  BEGIN INSERT INTO users(email,full_name,password_hash,role) VALUES ('x@dev-seed.invalid','X','!','HACKER');
    INSERT INTO test_results VALUES ('invalid role rejected','FAIL: accepted');
  EXCEPTION WHEN check_violation THEN INSERT INTO test_results VALUES ('invalid role rejected','PASS'); END;

  BEGIN INSERT INTO support_tickets(ticket_number,subject,description,customer_id,category_id)
        VALUES ('TKT-000001','dup','dup',cid,catid);
    INSERT INTO test_results VALUES ('duplicate ticket number','FAIL: accepted');
  EXCEPTION WHEN unique_violation THEN INSERT INTO test_results VALUES ('duplicate ticket number','PASS'); END;

  BEGIN INSERT INTO support_tickets(subject,description,customer_id,category_id) VALUES ('bad fk','x',-1,catid);
    INSERT INTO test_results VALUES ('invalid customer foreign key','FAIL: accepted');
  EXCEPTION WHEN foreign_key_violation THEN INSERT INTO test_results VALUES ('invalid customer foreign key','PASS'); END;

  BEGIN INSERT INTO support_tickets(subject,description,customer_id,category_id) VALUES ('bad cat','x',cid,-1);
    INSERT INTO test_results VALUES ('invalid category foreign key','FAIL: accepted');
  EXCEPTION WHEN foreign_key_violation THEN INSERT INTO test_results VALUES ('invalid category foreign key','PASS'); END;

  BEGIN INSERT INTO support_tickets(subject,description,customer_id,category_id,status) VALUES ('no agent','x',cid,catid,'IN_PROGRESS');
    INSERT INTO test_results VALUES ('IN_PROGRESS requires an agent','FAIL: accepted');
  EXCEPTION WHEN check_violation THEN INSERT INTO test_results VALUES ('IN_PROGRESS requires an agent','PASS'); END;

  BEGIN INSERT INTO support_tickets(subject,description,customer_id,category_id,priority) VALUES ('bad prio','x',cid,catid,'CRITICAL');
    INSERT INTO test_results VALUES ('invalid priority rejected','FAIL: accepted');
  EXCEPTION WHEN check_violation THEN INSERT INTO test_results VALUES ('invalid priority rejected','PASS'); END;

  BEGIN INSERT INTO feedback(ticket_id,customer_id,rating) VALUES (tk,cid,6);
    INSERT INTO test_results VALUES ('rating 6 rejected','FAIL: accepted');
  EXCEPTION WHEN check_violation THEN INSERT INTO test_results VALUES ('rating 6 rejected','PASS'); END;

  BEGIN INSERT INTO feedback(ticket_id,customer_id,rating) VALUES (tk,cid,0);
    INSERT INTO test_results VALUES ('rating 0 rejected','FAIL: accepted');
  EXCEPTION WHEN check_violation THEN INSERT INTO test_results VALUES ('rating 0 rejected','PASS'); END;

  BEGIN INSERT INTO feedback(ticket_id,customer_id,rating) VALUES (tk,other_cust,5);
    INSERT INTO test_results VALUES ('feedback by non-owner rejected','FAIL: accepted');
  EXCEPTION WHEN foreign_key_violation THEN INSERT INTO test_results VALUES ('feedback by non-owner rejected','PASS'); END;

  -- duplicate feedback: first valid insert succeeds, second must fail
  INSERT INTO feedback(ticket_id,customer_id,rating) VALUES (tk,cid,5);
  BEGIN INSERT INTO feedback(ticket_id,customer_id,rating) VALUES (tk,cid,4);
    INSERT INTO test_results VALUES ('duplicate feedback for ticket','FAIL: accepted');
  EXCEPTION WHEN unique_violation THEN INSERT INTO test_results VALUES ('duplicate feedback for ticket','PASS'); END;

  BEGIN INSERT INTO ticket_resolutions(ticket_id,resolved_by,resolution_summary,attempt_number,is_current)
        SELECT ticket_id, resolved_by, 'second current', 99, TRUE FROM ticket_resolutions WHERE is_current LIMIT 1;
    INSERT INTO test_results VALUES ('two current resolutions per ticket','FAIL: accepted');
  EXCEPTION WHEN unique_violation THEN INSERT INTO test_results VALUES ('two current resolutions per ticket','PASS'); END;

  BEGIN INSERT INTO ticket_recommendations(ticket_id,article_id,relevance_score,rank_position)
        SELECT ticket_id, article_id, 1.5, 1 FROM ticket_recommendations LIMIT 1;
    INSERT INTO test_results VALUES ('relevance score above 1 rejected','FAIL: accepted');
  EXCEPTION WHEN check_violation OR unique_violation THEN INSERT INTO test_results VALUES ('relevance score above 1 rejected','PASS'); END;

  BEGIN INSERT INTO knowledge_articles(title,content,category_id,author_id,status)
        SELECT 'pub no date','x',catid,(SELECT id FROM users LIMIT 1),'PUBLISHED';
    INSERT INTO test_results VALUES ('PUBLISHED needs published_at','FAIL: accepted');
  EXCEPTION WHEN check_violation THEN INSERT INTO test_results VALUES ('PUBLISHED needs published_at','PASS'); END;

  BEGIN DELETE FROM customers WHERE id = cid;
    INSERT INTO test_results VALUES ('delete customer with tickets blocked','FAIL: deleted');
  EXCEPTION WHEN restrict_violation OR foreign_key_violation THEN INSERT INTO test_results VALUES ('delete customer with tickets blocked','PASS'); END;

  BEGIN DELETE FROM support_tickets WHERE id = tk;
    INSERT INTO test_results VALUES ('delete ticket with history blocked','FAIL: deleted');
  EXCEPTION WHEN restrict_violation OR foreign_key_violation THEN INSERT INTO test_results VALUES ('delete ticket with history blocked','PASS'); END;
END $$;

-- ticket numbers come from the sequence and keep the TKT-000000 format
INSERT INTO support_tickets(subject,description,customer_id,category_id)
  SELECT 'seq test','x',(SELECT min(id) FROM customers),(SELECT min(id) FROM categories);
INSERT INTO test_results
  SELECT 'ticket_number generated from sequence',
         CASE WHEN ticket_number ~ '^TKT-[0-9]{6}$' THEN 'PASS' ELSE 'FAIL: '||ticket_number END
  FROM support_tickets WHERE subject = 'seq test';

SELECT * FROM test_results ORDER BY test;
SELECT count(*) FILTER (WHERE result = 'PASS') AS passed, count(*) FILTER (WHERE result <> 'PASS') AS failed FROM test_results;
ROLLBACK;
