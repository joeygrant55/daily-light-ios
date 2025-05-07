# Daily Light Development Plan

This document outlines the planned phases for enhancing the Daily Light application.

## Goal
Build a system that not only provides daily inspiration but also learns and grows with the user over time by tracking their journal entries and devotionals, and building context around their spiritual journey.

## Phase 1: Tracking Devotionals Systematically

**Objective:** Save every generated devotional to the database, linked to the user.

1.  **Database Setup (Supabase):**
    *   Create a new table: `devotionals`
    *   Columns:
        *   `id` (UUID, Primary Key, Default: `gen_random_uuid()`)
        *   `user_id` (UUID, Foreign Key to `auth.users.id`)
        *   `content` (TEXT, Not Nullable)
        *   `generated_at` (TIMESTAMPTZ, Default: `now()`, Not Nullable)
        *   `source_journal_entry_id` (UUID, Foreign Key to `journal_entries.id`, Nullable) - *Assumption: `journal_entries` table exists with a UUID primary key named `id`.*
    *   Enable Row Level Security (RLS) for the `devotionals` table. Define policies to ensure users can only access their own devotionals.

2.  **Backend Enhancement (Python/Flask in `daily-light-backend/app.py`):**
    *   Create a new API endpoint: `POST /api/devotionals`
    *   Functionality:
        *   Authenticate user (extract `user_id` from JWT).
        *   Parse `content` (and optional `source_journal_entry_id`) from the request body.
        *   Insert a new record into the `devotionals` table using the Supabase Python client.

3.  **App Integration (SwiftUI - `ContentView.swift` / `JournalInputView.swift`):**
    *   After a devotional is successfully generated, make a network request (HTTP POST) to `/api/devotionals` on the backend.
    *   Send `devotionalContent` (and `source_journal_entry_id` if applicable) in the request body.
    *   Handle success and error responses.

## Phase 2: Enhancing Journal Entry Context & Retrieval

**Objective:** Allow users to view their past journal entries and devotionals.

1.  **Review & Refine Journal Schema:**
    *   Ensure `journal_entries` table includes: `id` (PK), `user_id` (FK), `entry_text` (TEXT), `created_at` (TIMESTAMPTZ), `updated_at` (TIMESTAMPTZ).
    *   Confirm RLS policies are correctly set up for `journal_entries`.

2.  **Backend Retrieval Endpoints (`daily-light-backend/app.py`):**
    *   `GET /api/journal_entries`: Fetch all journal entries for the authenticated user.
    *   `GET /api/devotionals`: Fetch all saved devotionals for the authenticated user.
    *   Implement pagination if expecting large numbers of entries/devotionals.

3.  **App UI for History (SwiftUI):**
    *   Create new views to display:
        *   A list/timeline of the user's past journal entries.
        *   A list/timeline of the user's past devotionals.
    *   Allow tapping an item to view its full content.

## Phase 3: Building User Context & "Spiritual Journey" Insights (Longer Term)

**Objective:** Leverage stored data to provide deeper personalization and insights.

1.  **Data Analysis:**
    *   Explore techniques for basic text analysis (e.g., keyword extraction, sentiment trends) on journal entries and devotional content.
    *   This could be done periodically on the backend or on-demand.

2.  **Enhanced Personalization:**
    *   Use insights from analysis to:
        *   Further tailor future devotional generation prompts.
        *   Suggest relevant past entries or devotionals.
        *   Identify recurring themes or topics in the user's journey.

3.  **Visualization:**
    *   Consider creating visual representations of the user's spiritual journey (e.g., mood trends, frequently discussed topics over time).

## General Considerations
*   **Error Handling:** Robust error handling on both client and server.
*   **Security:** Ensure all endpoints are properly secured and user data is protected (RLS is key in Supabase).
*   **Testing:** Write tests for backend API endpoints and key SwiftUI view logic.
*   **Environment Configuration:** Maintain separate configurations for dev, test, and prod environments (especially for API keys and database connections). 