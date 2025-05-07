from flask import Flask, request, jsonify
import logging
import os
from openai import OpenAI
from dotenv import load_dotenv

# Load environment variables from .env file (especially for local development)
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)

app = Flask(__name__)

# --- OpenAI Client Initialization ---
api_key = os.getenv("OPENAI_API_KEY")
if not api_key:
    app.logger.warning("OPENAI_API_KEY environment variable not set. Devotional generation will fail.")
    openai_client = None
else:
    try:
        openai_client = OpenAI(api_key=api_key)
        app.logger.info("OpenAI client initialized successfully.")
    except Exception as e:
        app.logger.error(f"Failed to initialize OpenAI client: {e}")
        openai_client = None

@app.route('/generateDevotional', methods=['POST'])
def generate_devotional():
    app.logger.info("Received request for /generateDevotional")

    if not openai_client:
        app.logger.error("OpenAI client is not initialized. Cannot generate devotional.")
        return jsonify({"error": "Server configuration error: OpenAI client not available"}), 500

    if not request.is_json:
        app.logger.error("Request content type was not JSON")
        return jsonify({"error": "Request must be JSON"}), 415

    data = request.get_json()
    journal_entry = data.get('journalEntry')

    if not journal_entry:
        app.logger.error("Missing 'journalEntry' in request body")
        return jsonify({"error": "Missing 'journalEntry' in request body"}), 400

    app.logger.info(f"Received journal entry (first 50 chars): {journal_entry[:50]}...")

    # --- Call OpenAI API (with refined prompt) ---
    try:
        app.logger.info("Sending request to OpenAI...")
        # Refined system prompt focusing on verse and question
        system_prompt = """
You are a compassionate and insightful spiritual guide rooted in Christian wisdom.
Your task is to create a personalized, brief devotional message (around 120-180 words) based on the user's journal entry.

Here's the structure and style to follow:
1.  Start with a comforting and encouraging reflection that connects gently to the themes or emotions in the user's entry (without explicitly mentioning the entry).
2.  Seamlessly integrate a relevant Bible verse that offers hope, strength, or perspective on the user's situation. Clearly state the verse and its reference (e.g., John 14:27).
3.  Briefly elaborate on the verse's connection to the reflection.
4.  Conclude the devotional with a single, open-ended reflective question that encourages the user to consider the theme or the verse's application in their life.

Maintain a tone of empathy, hope, and peace. Use language consistent with biblical wisdom but avoid overly complex theology.
Focus on offering a moment of connection with God and personal reflection.

IMPORTANT: Ensure the output is ONLY the devotional text itself (reflection, verse, elaboration, question). Do not include any introductory or concluding remarks like 'Here is your devotional:' or 'I hope this helps.'.
"""

        response = openai_client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": journal_entry} # Pass only the journal entry
            ],
            temperature=0.7,
            max_tokens=300 # Increased max_tokens to allow for structure and potential longer verses
        )

        devotional_text = response.choices[0].message.content.strip()
        app.logger.info("Successfully received devotional from OpenAI.")

        return devotional_text, 200, {'Content-Type': 'text/plain; charset=utf-8'}

    except Exception as e:
        app.logger.error(f"Error calling OpenAI API: {e}")
        return jsonify({"error": "Failed to generate devotional due to an internal error"}), 500

# Health check endpoint
@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "ok"}), 200

if __name__ == '__main__':
    is_debug_mode = os.environ.get('FLASK_ENV', 'production') == 'development'
    app.run(debug=is_debug_mode, host='0.0.0.0', port=8080) 