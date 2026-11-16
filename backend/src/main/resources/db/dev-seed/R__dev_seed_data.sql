-- ============================================================================
-- DEVELOPMENT SEED DATA ONLY. Loaded only by the 'dev' Spring profile.
-- All accounts use the reserved domain @dev-seed.invalid and the password hash '!',
-- which can never match a password, so no seeded account can log in.
-- Idempotent: every statement skips rows that already exist.
-- ============================================================================

-- Users: 1 admin, 3 agents, 5 customers ---------------------------------------
INSERT INTO users (email, full_name, password_hash, role) VALUES
 ('admin@dev-seed.invalid',  'Dev Admin',     '!', 'ADMIN'),
 ('agent1@dev-seed.invalid', 'Asha Rao',      '!', 'AGENT'),
 ('agent2@dev-seed.invalid', 'Rahul Mehta',   '!', 'AGENT'),
 ('agent3@dev-seed.invalid', 'Priya Nair',    '!', 'AGENT'),
 ('cust1@dev-seed.invalid',  'Neha Sharma',   '!', 'CUSTOMER'),
 ('cust2@dev-seed.invalid',  'Arjun Verma',   '!', 'CUSTOMER'),
 ('cust3@dev-seed.invalid',  'Kavya Iyer',    '!', 'CUSTOMER'),
 ('cust4@dev-seed.invalid',  'Rohan Das',     '!', 'CUSTOMER'),
 ('cust5@dev-seed.invalid',  'Sneha Kulkarni','!', 'CUSTOMER')
ON CONFLICT (lower(email)) DO NOTHING;

INSERT INTO customers (user_id, phone, company_name)
SELECT u.id, v.phone, v.company
FROM (VALUES
 ('cust1@dev-seed.invalid', '+91-90000-00001', 'Northwind Retail'),
 ('cust2@dev-seed.invalid', '+91-90000-00002', 'Bluepeak Logistics'),
 ('cust3@dev-seed.invalid', '+91-90000-00003', 'Lumen Studio'),
 ('cust4@dev-seed.invalid', '+91-90000-00004', 'Greenfield Foods'),
 ('cust5@dev-seed.invalid', '+91-90000-00005', 'Orbit Systems')
) AS v(email, phone, company)
JOIN users u ON lower(u.email) = v.email
ON CONFLICT (user_id) DO NOTHING;

-- Categories -------------------------------------------------------------------
INSERT INTO categories (name, description) VALUES
 ('Account & Login',     'Sign-in, passwords and account security'),
 ('Billing & Payments',  'Invoices, charges and payment methods'),
 ('Technical Issues',    'Errors, crashes and performance problems'),
 ('Product Information', 'Plans, features and usage questions'),
 ('Shipping & Delivery', 'Tracking, delays and delivery problems'),
 ('Returns & Refunds',   'Returning items and refund requests')
ON CONFLICT (lower(name)) DO NOTHING;

-- Tags -------------------------------------------------------------------------
INSERT INTO article_tags (name) VALUES
 ('password'), ('login'), ('billing'), ('refund'), ('invoice'), ('shipping'),
 ('setup'), ('error'), ('performance'), ('security'), ('mobile-app')
ON CONFLICT (lower(name)) DO NOTHING;

-- Knowledge articles (15) --------------------------------------------------------
INSERT INTO knowledge_articles (title, summary, content, category_id, author_id, status, published_at)
SELECT v.title, v.summary, v.content, c.id, a.id, v.status,
       CASE WHEN v.status = 'PUBLISHED' THEN now() - interval '30 days' END
FROM (VALUES
 ('Resetting your password', 'Steps to reset a forgotten password.',
  'Open the sign-in page and choose Forgot password. Enter the email on your account and follow the link we send. If no email arrives within ten minutes, check your spam folder and request a new link.',
  'Account & Login', 'PUBLISHED'),
 ('Troubleshooting two-factor authentication codes', 'Fixes for missing or invalid verification codes.',
  'Make sure your phone clock is set to automatic time. Codes expire after thirty seconds, so enter the newest one. If you changed phones, use a backup code or ask support to reset two-factor authentication.',
  'Account & Login', 'PUBLISHED'),
 ('Updating your email address and profile', 'How to change account details.',
  'Go to Account settings and select Profile. Change your name or email and confirm the change using the verification message sent to the new address.',
  'Account & Login', 'PUBLISHED'),
 ('Finding and downloading your invoice', 'Where invoices are stored.',
  'Open Billing and select Invoices. Choose the month you need and click Download PDF. Invoices are issued on the first day of each billing cycle.',
  'Billing & Payments', 'PUBLISHED'),
 ('Why you may see a duplicate charge', 'Explains pending authorisations versus real charges.',
  'A pending authorisation can look like a second charge but usually disappears within five business days. If both charges are settled, contact support with the transaction dates so we can review and refund the extra amount.',
  'Billing & Payments', 'PUBLISHED'),
 ('Updating billing address and payment method', 'Change the card or address used for billing.',
  'Open Billing, then Payment methods. Add the new card or edit the billing address and set it as default. The next invoice uses the new details.',
  'Billing & Payments', 'PUBLISHED'),
 ('App crashes on photo upload: common fixes', 'What to try when uploads crash the app.',
  'Update the app to the latest version and confirm the photo is smaller than 20 MB. Grant photo access in your phone settings. If the crash continues, send the error code shown on screen to support.',
  'Technical Issues', 'PUBLISHED'),
 ('Improving dashboard loading speed', 'Tips for slow dashboards.',
  'Reduce the date range on large reports and close unused browser tabs. Clear your browser cache and disable extensions that modify pages. Persistent slowness may indicate a network problem on your side.',
  'Technical Issues', 'PUBLISHED'),
 ('Clearing cache and reinstalling the mobile app', 'Legacy troubleshooting guide.',
  'Clear the app cache from phone settings, then uninstall and reinstall the app. This guide applies to app versions before 4.0.',
  'Technical Issues', 'ARCHIVED'),
 ('Plans and features overview', 'Compare plans at a glance.',
  'The Basic plan covers ticketing for small teams. The Premium plan adds analytics, priority support and higher storage limits. Compare plans on the pricing page.',
  'Product Information', 'PUBLISHED'),
 ('API access and rate limits', 'Draft: how API keys and limits work.',
  'API keys are created in Settings. Each key has a default limit of requests per minute. This article is still being reviewed.',
  'Product Information', 'DRAFT'),
 ('Tracking your package', 'How to track an order.',
  'Open Orders and select the order to see the tracking link. Tracking updates can take up to 24 hours after dispatch.',
  'Shipping & Delivery', 'PUBLISHED'),
 ('What to do if a package is marked delivered but missing', 'Steps for missing deliveries.',
  'Check with neighbours and around your delivery location. Wait one business day because carriers sometimes mark delivery early. If the package is still missing, contact support so we can open a carrier investigation.',
  'Shipping & Delivery', 'PUBLISHED'),
 ('How to return a damaged item', 'Return process for damaged goods.',
  'Photograph the damage and the packaging. Request a return from Orders and print the prepaid label. Pack the item securely and hand it to the carrier.',
  'Returns & Refunds', 'PUBLISHED'),
 ('Refund timelines', 'When refunds reach your account.',
  'Approved refunds are issued to the original payment method. Cards typically take five to ten business days and wallets one to three days.',
  'Returns & Refunds', 'PUBLISHED')
) AS v(title, summary, content, category, status)
JOIN categories c ON lower(c.name) = lower(v.category)
CROSS JOIN (SELECT id FROM users WHERE lower(email) = 'admin@dev-seed.invalid') a
WHERE NOT EXISTS (SELECT 1 FROM knowledge_articles k WHERE k.title = v.title);

-- Article tags -----------------------------------------------------------------
INSERT INTO article_tag_mappings (article_id, tag_id)
SELECT k.id, t.id
FROM (VALUES
 ('Resetting your password', 'password'), ('Resetting your password', 'login'),
 ('Troubleshooting two-factor authentication codes', 'login'),
 ('Troubleshooting two-factor authentication codes', 'security'),
 ('Updating your email address and profile', 'setup'),
 ('Finding and downloading your invoice', 'invoice'), ('Finding and downloading your invoice', 'billing'),
 ('Why you may see a duplicate charge', 'billing'), ('Why you may see a duplicate charge', 'refund'),
 ('Updating billing address and payment method', 'billing'), ('Updating billing address and payment method', 'setup'),
 ('App crashes on photo upload: common fixes', 'error'), ('App crashes on photo upload: common fixes', 'mobile-app'),
 ('Improving dashboard loading speed', 'performance'),
 ('Clearing cache and reinstalling the mobile app', 'mobile-app'),
 ('Plans and features overview', 'setup'),
 ('Tracking your package', 'shipping'),
 ('What to do if a package is marked delivered but missing', 'shipping'),
 ('How to return a damaged item', 'refund'), ('How to return a damaged item', 'shipping'),
 ('Refund timelines', 'refund'), ('Refund timelines', 'billing')
) AS v(title, tag)
JOIN knowledge_articles k ON k.title = v.title
JOIN article_tags t ON lower(t.name) = v.tag
ON CONFLICT (article_id, tag_id) DO NOTHING;

-- Tickets (12). ticket_number is assigned by the sequence default. ---------------
INSERT INTO support_tickets
  (subject, description, customer_id, category_id, assigned_agent_id, priority, status,
   created_at, updated_at, resolved_at, closed_at)
SELECT s.subject, s.description, cu.id, c.id, ag.id, s.priority, s.status,
       s.created, s.created,
       CASE WHEN s.status IN ('RESOLVED', 'CLOSED') THEN s.created + interval '6 hours' END,
       CASE WHEN s.status = 'CLOSED' THEN s.created + interval '30 hours' END
FROM (SELECT v.*, now() - v.days_ago * interval '1 day' AS created
      FROM (VALUES
 ('Cannot reset my password', 'I requested a reset link three times but no email arrives.',
  'cust1@dev-seed.invalid', 'Account & Login', 'agent1@dev-seed.invalid', 'HIGH', 'IN_PROGRESS', 3),
 ('Charged twice for monthly plan', 'My card shows two identical charges this month.',
  'cust2@dev-seed.invalid', 'Billing & Payments', 'agent2@dev-seed.invalid', 'URGENT', 'ASSIGNED', 2),
 ('App crashes when uploading a photo', 'The mobile app closes every time I attach an image.',
  'cust3@dev-seed.invalid', 'Technical Issues', NULL, 'HIGH', 'OPEN', 1),
 ('Where can I find my invoice?', 'I need the invoice for last month for accounting.',
  'cust1@dev-seed.invalid', 'Billing & Payments', 'agent2@dev-seed.invalid', 'LOW', 'RESOLVED', 10),
 ('Package shows delivered but not received', 'Tracking says delivered yesterday but nothing arrived.',
  'cust4@dev-seed.invalid', 'Shipping & Delivery', 'agent3@dev-seed.invalid', 'MEDIUM', 'WAITING_ON_CUSTOMER', 5),
 ('How do I return a damaged item?', 'The item arrived with a cracked screen.',
  'cust5@dev-seed.invalid', 'Returns & Refunds', 'agent3@dev-seed.invalid', 'MEDIUM', 'CLOSED', 20),
 ('Two-factor code never arrives', 'I never receive the verification code on my phone.',
  'cust2@dev-seed.invalid', 'Account & Login', 'agent1@dev-seed.invalid', 'HIGH', 'REOPENED', 15),
 ('Dashboard loads very slowly', 'Reports take over a minute to open.',
  'cust3@dev-seed.invalid', 'Technical Issues', 'agent1@dev-seed.invalid', 'MEDIUM', 'IN_PROGRESS', 4),
 ('Request refund for cancelled order', 'I cancelled my order but have not been refunded.',
  'cust4@dev-seed.invalid', 'Returns & Refunds', 'agent2@dev-seed.invalid', 'HIGH', 'CLOSED', 25),
 ('Does the premium plan include API access?', 'Please confirm what the premium plan includes.',
  'cust5@dev-seed.invalid', 'Product Information', 'agent3@dev-seed.invalid', 'LOW', 'RESOLVED', 8),
 ('Cannot update billing address', 'The save button does nothing on the billing page.',
  'cust1@dev-seed.invalid', 'Billing & Payments', NULL, 'MEDIUM', 'OPEN', 0),
 ('Delivery address change after ordering', 'I entered the wrong flat number at checkout.',
  'cust2@dev-seed.invalid', 'Shipping & Delivery', 'agent2@dev-seed.invalid', 'LOW', 'CLOSED', 30)
      ) AS v(subject, description, cust, category, agent, priority, status, days_ago)) AS s
JOIN users uc ON lower(uc.email) = s.cust
JOIN customers cu ON cu.user_id = uc.id
JOIN categories c ON lower(c.name) = lower(s.category)
LEFT JOIN users ag ON lower(ag.email) = s.agent
WHERE NOT EXISTS (SELECT 1 FROM support_tickets t WHERE t.subject = s.subject AND t.customer_id = cu.id);

-- Recommendations --------------------------------------------------------------
INSERT INTO ticket_recommendations (ticket_id, article_id, relevance_score, rank_position, source, is_helpful)
SELECT t.id, k.id, v.score, v.rank_pos, v.source, v.helpful
FROM (VALUES
 ('Cannot reset my password', 'Resetting your password', 0.9100, 1, 'SYSTEM', TRUE),
 ('Cannot reset my password', 'Updating your email address and profile', 0.4200, 2, 'SYSTEM', FALSE),
 ('Charged twice for monthly plan', 'Why you may see a duplicate charge', 0.8800, 1, 'SYSTEM', NULL::boolean),
 ('App crashes when uploading a photo', 'App crashes on photo upload: common fixes', 0.9300, 1, 'SYSTEM', NULL),
 ('Where can I find my invoice?', 'Finding and downloading your invoice', 0.9500, 1, 'SYSTEM', TRUE),
 ('Package shows delivered but not received', 'What to do if a package is marked delivered but missing', 0.9000, 1, 'SYSTEM', TRUE),
 ('Package shows delivered but not received', 'Tracking your package', 0.5500, 2, 'AGENT', NULL),
 ('How do I return a damaged item?', 'How to return a damaged item', 0.9400, 1, 'SYSTEM', TRUE),
 ('Two-factor code never arrives', 'Troubleshooting two-factor authentication codes', 0.9200, 1, 'SYSTEM', FALSE),
 ('Dashboard loads very slowly', 'Improving dashboard loading speed', 0.8700, 1, 'SYSTEM', NULL),
 ('Request refund for cancelled order', 'Refund timelines', 0.8900, 1, 'SYSTEM', TRUE),
 ('Does the premium plan include API access?', 'Plans and features overview', 0.8100, 1, 'SYSTEM', TRUE),
 ('Cannot update billing address', 'Updating billing address and payment method', 0.9000, 1, 'SYSTEM', NULL)
) AS v(subject, title, score, rank_pos, source, helpful)
JOIN support_tickets t ON t.subject = v.subject
JOIN knowledge_articles k ON k.title = v.title
ON CONFLICT (ticket_id, article_id) DO NOTHING;

-- Resolutions ------------------------------------------------------------------
INSERT INTO ticket_resolutions (ticket_id, resolved_by, article_id, resolution_summary, attempt_number, is_current, resolved_at)
SELECT t.id, u.id, k.id, v.summary, v.attempt, v.is_current, t.created_at + interval '6 hours'
FROM (VALUES
 ('Where can I find my invoice?', 'agent2@dev-seed.invalid', 'Finding and downloading your invoice',
  'Shared the steps to download the invoice from the Billing page.', 1, TRUE),
 ('How do I return a damaged item?', 'agent3@dev-seed.invalid', 'How to return a damaged item',
  'Issued a prepaid return label and explained the return steps.', 1, TRUE),
 ('Two-factor code never arrives', 'agent1@dev-seed.invalid', 'Troubleshooting two-factor authentication codes',
  'Advised enabling automatic time on the phone; the customer reported the problem continued.', 1, FALSE),
 ('Request refund for cancelled order', 'agent2@dev-seed.invalid', 'Refund timelines',
  'Approved the refund and confirmed the expected timeline.', 1, TRUE),
 ('Does the premium plan include API access?', 'agent3@dev-seed.invalid', 'Plans and features overview',
  'Confirmed the premium plan features and linked the plan overview.', 1, TRUE),
 ('Delivery address change after ordering', 'agent2@dev-seed.invalid', NULL,
  'Updated the delivery address before dispatch.', 1, TRUE)
) AS v(subject, agent, title, summary, attempt, is_current)
JOIN support_tickets t ON t.subject = v.subject
JOIN users u ON lower(u.email) = v.agent
LEFT JOIN knowledge_articles k ON k.title = v.title
ON CONFLICT (ticket_id, attempt_number) DO NOTHING;

-- Feedback (only the ticket owner can rate their ticket) -----------------------------
INSERT INTO feedback (ticket_id, customer_id, rating, comment, created_at)
SELECT t.id, t.customer_id, v.rating, v.comment, t.closed_at
FROM (VALUES
 ('How do I return a damaged item?', 5, 'Quick help and a clear return label.'),
 ('Request refund for cancelled order', 4, 'Refund took a few days but support kept me informed.'),
 ('Delivery address change after ordering', 3, 'Resolved, but I had to follow up twice.')
) AS v(subject, rating, comment)
JOIN support_tickets t ON t.subject = v.subject
ON CONFLICT (ticket_id) DO NOTHING;

-- Ticket history: a CREATED entry for every seeded ticket ----------------------------
INSERT INTO ticket_history (ticket_id, performed_by, action_type, new_value, note, created_at)
SELECT t.id, cu.user_id, 'CREATED', 'OPEN', 'Ticket created', t.created_at
FROM support_tickets t
JOIN customers cu ON cu.id = t.customer_id
JOIN users u ON u.id = cu.user_id AND u.email LIKE '%@dev-seed.invalid'
WHERE NOT EXISTS (SELECT 1 FROM ticket_history h WHERE h.ticket_id = t.id AND h.action_type = 'CREATED');

-- Ticket history: assignments and status changes -------------------------------------
INSERT INTO ticket_history (ticket_id, performed_by, action_type, old_value, new_value, note, created_at)
SELECT t.id, u.id, v.action, v.old_value, v.new_value, v.note, t.created_at + v.hrs * interval '1 hour'
FROM (VALUES
 ('Cannot reset my password', 'admin@dev-seed.invalid', 'ASSIGNED', NULL::text, 'agent1@dev-seed.invalid', 'Assigned to agent', 1),
 ('Cannot reset my password', 'agent1@dev-seed.invalid', 'STATUS_CHANGED', 'OPEN', 'ASSIGNED', NULL, 1),
 ('Cannot reset my password', 'agent1@dev-seed.invalid', 'STATUS_CHANGED', 'ASSIGNED', 'IN_PROGRESS', NULL, 2),
 ('Charged twice for monthly plan', 'admin@dev-seed.invalid', 'ASSIGNED', NULL, 'agent2@dev-seed.invalid', 'Assigned to agent', 1),
 ('Charged twice for monthly plan', 'agent2@dev-seed.invalid', 'STATUS_CHANGED', 'OPEN', 'ASSIGNED', NULL, 1),
 ('Charged twice for monthly plan', 'admin@dev-seed.invalid', 'PRIORITY_CHANGED', 'HIGH', 'URGENT', 'Duplicate payment escalated', 2),
 ('Where can I find my invoice?', 'agent2@dev-seed.invalid', 'STATUS_CHANGED', 'OPEN', 'ASSIGNED', NULL, 1),
 ('Where can I find my invoice?', 'agent2@dev-seed.invalid', 'STATUS_CHANGED', 'ASSIGNED', 'IN_PROGRESS', NULL, 2),
 ('Where can I find my invoice?', 'agent2@dev-seed.invalid', 'RESOLUTION_ADDED', NULL, '1', NULL, 6),
 ('Where can I find my invoice?', 'agent2@dev-seed.invalid', 'STATUS_CHANGED', 'IN_PROGRESS', 'RESOLVED', NULL, 6),
 ('Package shows delivered but not received', 'agent3@dev-seed.invalid', 'STATUS_CHANGED', 'OPEN', 'ASSIGNED', NULL, 1),
 ('Package shows delivered but not received', 'agent3@dev-seed.invalid', 'STATUS_CHANGED', 'ASSIGNED', 'IN_PROGRESS', NULL, 2),
 ('Package shows delivered but not received', 'agent3@dev-seed.invalid', 'STATUS_CHANGED', 'IN_PROGRESS', 'WAITING_ON_CUSTOMER', 'Waiting for carrier details', 4),
 ('How do I return a damaged item?', 'agent3@dev-seed.invalid', 'STATUS_CHANGED', 'OPEN', 'ASSIGNED', NULL, 1),
 ('How do I return a damaged item?', 'agent3@dev-seed.invalid', 'STATUS_CHANGED', 'ASSIGNED', 'IN_PROGRESS', NULL, 2),
 ('How do I return a damaged item?', 'agent3@dev-seed.invalid', 'RESOLUTION_ADDED', NULL, '1', NULL, 6),
 ('How do I return a damaged item?', 'agent3@dev-seed.invalid', 'STATUS_CHANGED', 'IN_PROGRESS', 'RESOLVED', NULL, 6),
 ('How do I return a damaged item?', 'agent3@dev-seed.invalid', 'STATUS_CHANGED', 'RESOLVED', 'CLOSED', NULL, 30),
 ('How do I return a damaged item?', 'cust5@dev-seed.invalid', 'FEEDBACK_SUBMITTED', NULL, '5', NULL, 30),
 ('Two-factor code never arrives', 'agent1@dev-seed.invalid', 'STATUS_CHANGED', 'IN_PROGRESS', 'RESOLVED', NULL, 6),
 ('Two-factor code never arrives', 'cust2@dev-seed.invalid', 'REOPENED', 'RESOLVED', 'REOPENED', 'Problem continued', 48),
 ('Request refund for cancelled order', 'agent2@dev-seed.invalid', 'STATUS_CHANGED', 'RESOLVED', 'CLOSED', NULL, 30)
) AS v(subject, performer, action, old_value, new_value, note, hrs)
JOIN support_tickets t ON t.subject = v.subject
JOIN users u ON lower(u.email) = v.performer
WHERE NOT EXISTS (
    SELECT 1 FROM ticket_history h
    WHERE h.ticket_id = t.id AND h.action_type = v.action
      AND h.old_value IS NOT DISTINCT FROM v.old_value
      AND h.new_value IS NOT DISTINCT FROM v.new_value);
