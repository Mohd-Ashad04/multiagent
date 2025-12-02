
# Agentic Tutoring System (Flask) - Full Version

This project demonstrates a sophisticated Agentic AI tutoring platform built with Flask.
It features a modern, responsive web UI with support for multiple learning modalities:
- **Lessons**: Structured curriculum with explanations and quiz questions
- **Flashcards**: Spaced repetition system (SRS) for memorization
- **Step-by-Step Mode**: Ordered lesson progression with collapsible steps
- **Examples**: Real-world application examples tied to lessons
- **Hints & Summary**: Contextual hints and session summaries for review

The system uses in-process 'agents' (Planner, Tutor, Quiz, Study, Feedback) to orchestrate learning experiences. It works both with optional LLM backends (OpenAI / Google Gemini) and provides sensible fallbacks when no LLM is configured.

## Features

- **Multi-Modal Learning UI**: Five integrated learning tabs covering different study strategies
- **Spaced Repetition (SRS)**: Flashcard-based learning with rating system (Again/Hard/Good)
- **Responsive Design**: Bootstrap 5-based responsive UI with both desktop and mobile support
- **LLM Integration**: Optional OpenAI or Google Gemini backend with graceful fallback
- **Progress Tracking**: Real-time progress bar and session status updates via polling
- **Local Notes**: Notes are persisted in browser localStorage with export to JSON
- **Token-Based Auth**: Simple Bearer token authentication for API access
- **Comprehensive Agents**:
  - **PlannerAgent**: Breaks topics into lessons
  - **TutorAgent**: Generates explanations with LLM or fallback
  - **QuizAgent**: Creates quiz questions
  - **StudyAgent**: Generates flashcards, hints, and summaries
  - **FeedbackAgent**: Grades answers and provides feedback
  - **Coordinator**: Orchestrates all agents and manages session state
- **In-Memory Storage**: Session data stored in memory (can be replaced with database)
- **Docker Support**: Included docker-compose for containerized deployment
- **Comprehensive Tests**: Unit and integration tests for all major features

## Architecture

```
app/
├── agents.py          # Agent classes: Planner, Tutor, Quiz, Study, Feedback, Coordinator
├── api.py             # RESTful API endpoints for session, flashcards, hints, summaries
├── auth.py            # Token-based authentication decorator
├── storage.py         # Session storage (in-memory default)
├── web.py             # Web routes for HTML templates
├── llm_adapter.py     # LLM provider abstraction (removed, now in agents.py)
├── templates/
│   ├── index.html     # Home page with session creation form
│   └── session.html   # Modern multi-tab learning interface
└── static/            # Static assets (CSS, JavaScript, images)
```

## Quick Start

### Development Setup

```bash
# Clone and navigate
unzip agentic_tutoring_full.zip
cd agentic_tutoring_full

# Create virtual environment
python3 -m venv venv
source venv/bin/activate    # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Create .env file with your configuration
cp .env.example .env
# Edit .env and add your API key and provider choice

# Run the application
export FLASK_APP=app
flask run --port 5000

# Visit http://127.0.0.1:5000
```

### Using with Docker

```bash
# Create .env file with your settings
cp .env.example .env
# Edit .env

# Build and run
docker compose up --build

# Visit http://localhost:8000
```

### Running Tests

```bash
# Run all tests
pytest -v

# Run specific test file
pytest tests/test_agents.py -v

# Run with coverage
pytest --cov=app tests/
```

## Environment Configuration

Create a `.env` file in the project root with the following variables:

```bash
# LLM Configuration
# Use a single AI_API_KEY for both Gemini and OpenAI
AI_API_KEY=your_api_key_here

# Choose provider: "openai" or "gemini"
LLM_PROVIDER=gemini

# Gemini-specific model (used only if LLM_PROVIDER=gemini)
GEMINI_MODEL=gemini-1.5-flash

# Authentication token for API access
TUTOR_TOKEN=demo-token
```

### LLM Provider Setup

#### Using Google Gemini (Recommended)
1. Get free API key: https://aistudio.google.com/apikey
2. Set `LLM_PROVIDER=gemini` in `.env`
3. Set `AI_API_KEY=<your-gemini-key>` in `.env`
4. (Optional) Customize `GEMINI_MODEL` for different models like `gemini-2.0-flash`

#### Using OpenAI
1. Get API key: https://platform.openai.com/account/api-keys
2. Set `LLM_PROVIDER=openai` in `.env`
3. Set `AI_API_KEY=<your-openai-key>` in `.env`
4. Uses `gpt-4o-mini` model by default

#### Running Without LLM
Leave `LLM_PROVIDER` or `AI_API_KEY` empty. The app will use smart fallbacks:
- Lessons: Auto-generated based on topic
- Flashcards: Deterministic Q&A from lesson titles
- Hints: Pattern-based hints (what/how/why detection)
- Summaries: Aggregated lesson titles and content

This is perfect for development, testing, or environments without API keys!

## API Reference

### Session Management

**Create a Session**
```http
POST /api/session
Authorization: Bearer <TUTOR_TOKEN>
Content-Type: application/json

{
  "topic": "Python Functions",
  "level": "beginner"
}

Response:
{
  "session_id": "uuid",
  "status": "started"
}
```

**Get Session Status**
```http
GET /api/session/<session_id>
Authorization: Bearer <TUTOR_TOKEN>

Response:
{
  "id": "session_id",
  "topic": "Python Functions",
  "level": "beginner",
  "status": "ready",
  "progress": 100,
  "lessons": [
    {
      "id": "lesson_id",
      "title": "Introduction to Python Functions",
      "content": "...",
      "questions": [...]
    }
  ]
}
```

### Learning Endpoints

**Get Flashcard**
```http
POST /api/session/<session_id>/flashcard
Authorization: Bearer <TUTOR_TOKEN>

Response:
{
  "id": "flashcard_id",
  "front": "What is a function?",
  "back": "A reusable block of code...",
  "lesson_id": "lesson_id"
}
```

**Submit Flashcard Review (SRS)**
```http
POST /api/session/<session_id>/review
Authorization: Bearer <TUTOR_TOKEN>
Content-Type: application/json

{
  "rating": 0 | 1 | 2
}

// Ratings: 0=Again, 1=Hard, 2=Good
```

**Submit Quiz Answer**
```http
POST /api/session/<session_id>/answer
Authorization: Bearer <TUTOR_TOKEN>
Content-Type: application/json

{
  "question_id": "question_id",
  "answer": "Your answer text"
}

Response:
{
  "score": 0.75,
  "feedback": "Good answer — you captured the main idea..."
}
```

**Get Hint for Question**
```http
GET /api/session/<session_id>/hint?question_id=<question_id>
Authorization: Bearer <TUTOR_TOKEN>

Response:
{
  "hint": "Hint: Look for a definition or key term in the lesson."
}
```

**Get Session Summary**
```http
GET /api/session/<session_id>/summary
Authorization: Bearer <TUTOR_TOKEN>

Response:
{
  "summary": "This session covered Python Functions, Best Practices..."
}
```

**List All Sessions**
```http
GET /api/sessions
Authorization: Bearer <TUTOR_TOKEN>

Response:
[
  { "id": "...", "topic": "...", "status": "...", ... }
]
```

## UI Features & Usage

### 📖 Lessons Tab
- View all lessons with explanations and quiz questions
- Submit answers and get immediate feedback with scores
- Access hints via the "💡 Hint" button for each question

### 🎴 Flashcards Tab
- Interactive flashcards with front/back cards
- Click card to reveal answer
- Rate your response: ❌ Again / 😰 Hard / ✅ Good
- SRS ratings help track learning progress
- Next Card button rotates through lessons

### 📋 Step-by-Step Tab
- Lessons presented as numbered, collapsible steps
- Click to expand/collapse individual steps
- Great for structured, ordered learning

### 💡 Examples Tab
- Contextual examples for each lesson
- Shows real-world applications of concepts
- Helps bridge gap between theory and practice

### 📚 Summary Tab
- "Get Session Summary" button generates overview
- Powered by LLM when available; otherwise aggregated lesson titles
- Export notes as JSON with timestamp

### 📝 Right Side Panel
- **Quick Actions**: Summary, Download Notes, Refresh buttons
- **Notes Box**: Persistent markdown/text notes stored in browser localStorage
- **Save Notes**: Saves locally; survives page refreshes
- **Download Notes**: Exports as JSON with session ID and timestamp

### Progress Tracking
- Real-time progress bar reflecting lesson generation
- Status updates (planning → generating → ready)
- Responsive layout adapts to mobile and desktop

## Code Examples

### Creating a Learning Session Programmatically

```python
from app import app
from app.storage import InMemoryStore
from app.agents import Coordinator

storage = InMemoryStore()
coordinator = Coordinator(storage)

# Start a session
session = coordinator.start_session(
    session_id='my-session',
    topic='Machine Learning Basics',
    level='intermediate'
)

# Get a flashcard
flashcard = coordinator.get_next_flashcard('my-session')
# { 'id': '...', 'front': 'What is...', 'back': '...', 'lesson_id': '...' }

# Record a review
coordinator.record_flashcard_review('my-session', rating=2)  # 0, 1, or 2

# Get a hint
hint = coordinator.get_hint('my-session', question_id='q-123')

# Get summary
summary = coordinator.get_summary('my-session')
```

### Extending with Custom Agents

```python
from app.agents import Coordinator

class MyCustomAgent:
    def analyze(self, content):
        # Custom logic
        return processed_content

coordinator = Coordinator(storage)
coordinator.custom = MyCustomAgent()
```

## Dependencies

- **Flask** 3.0+: Web framework
- **python-dotenv** 1.0+: Environment variable management
- **openai** 1.0+: OpenAI API client (optional)
- **google-generativeai** 0.4+: Google Gemini API client (optional)
- **pytest** 7.4+: Testing framework
- **requests** 2.31+: HTTP library
- **gunicorn** 21.0+: Production WSGI server

See `requirements.txt` for exact versions.

## Troubleshooting

### "No valid LLM provider configured"
- Check `.env` file has both `AI_API_KEY` and `LLM_PROVIDER` set
- Verify key is correct and has remaining quota
- Check API key format (Gemini keys start with `AIza...`)

### "google.generativeai has no attribute 'generate_text'"
- Make sure `google-generativeai` version is recent (0.4+)
- Reinstall: `pip install --upgrade google-generativeai`

### Flashcards not generating
- App works in fallback mode! Check console for LLM errors
- Fallback creates Q&A from lesson titles
- If LLM enabled, ensure valid API key and network access

### Notes not persisting
- Notes use browser localStorage (no server-side storage)
- Clear browser cache/storage will lose notes
- Use "Download Notes" to export as JSON backup

### Tests failing
- Run from project root: `pytest`
- Ensure `.env` exists (can be empty for fallback mode)
- Check Python version is 3.8+

## Production Deployment

### Using Gunicorn

```bash
gunicorn -w 4 -b 0.0.0.0:8000 "app:app"
```

### Using Docker

```bash
docker build -t tutoring-app .
docker run -p 8000:8000 \
  -e AI_API_KEY="your-key" \
  -e LLM_PROVIDER="gemini" \
  tutoring-app
```

### Security Notes
- Always use strong `TUTOR_TOKEN` values in production
- Never commit `.env` with real API keys to version control
- Consider using secrets management (AWS Secrets Manager, etc.)
- In-memory storage is not suitable for multi-process/distributed setups
- Replace `InMemoryStore` with proper database for production

## Contributing

Contributions welcome! Areas for enhancement:
- Database backend instead of in-memory storage
- User accounts and progress persistence
- Additional learning modalities (video, audio)
- More sophisticated SRS algorithm
- Multilingual support
- Analytics and learning insights dashboard

## License

MIT License - see LICENSE file for details.

## Support

For issues, feature requests, or questions:
1. Check the Troubleshooting section above
2. Review API examples and code comments
3. Run tests: `pytest -v`
4. Check logs for detailed error messages

---

**Happy Learning!** 🎓

