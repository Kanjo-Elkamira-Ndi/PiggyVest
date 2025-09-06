from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import logging
import uvicorn
from typing import Optional, Dict, Any
import sys
import os

# Import your chatbot class
# Make sure your chatbot file is in the same directory or adjust the import path
try:
    from chatbot import IntelligentChatbot  # Replace with your actual file name
except ImportError:
    print("❌ Error: Could not import IntelligentChatbot. Make sure the chatbot file is in the same directory.")
    sys.exit(1)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="Intelligent Chatbot API",
    description="A REST API for the Intelligent Chatbot that can answer questions based on trained knowledge",
    version="1.0.0"
)

# Add CORS middleware to allow cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify actual origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global chatbot instance
chatbot = None


# Pydantic models for request/response
class QuestionRequest(BaseModel):
    question: str


class ChatResponse(BaseModel):
    question: str
    answer: str
    status: str
    confidence: Optional[float] = None


class FeedbackRequest(BaseModel):
    question: str
    correct_answer: str


class StatsResponse(BaseModel):
    qa_pairs: int
    documents: int
    interactions: int
    categories: int
    status: str


class StatusResponse(BaseModel):
    status: str
    message: str


# Initialize chatbot on startup
@app.on_event("startup")
async def startup_event():
    """Initialize the chatbot when the API starts"""
    global chatbot
    try:
        logger.info("🚀 Initializing chatbot...")
        chatbot = IntelligentChatbot()

        # Load data if data directory exists
        if os.path.exists(''):
            logger.info("📚 Loading data...")
            chatbot.load_data_directory('data')
            stats = chatbot.get_statistics()
            logger.info(f"✅ Chatbot initialized with {stats}")
        else:
            logger.warning("⚠️ No 'data' directory found. Chatbot initialized without training data.")

    except Exception as e:
        logger.error(f"❌ Failed to initialize chatbot: {e}")
        chatbot = None


# Health check endpoint
@app.get("/", response_model=StatusResponse)
async def root():
    """Health check endpoint"""
    if chatbot is None:
        raise HTTPException(status_code=503, detail="Chatbot not initialized")

    return StatusResponse(
        status="healthy",
        message="Intelligent Chatbot API is running"
    )


# Main chat endpoint
@app.post("/chat", response_model=ChatResponse)
async def chat(request: QuestionRequest):
    """
    Send a question to the chatbot and get an answer
    """
    if chatbot is None:
        raise HTTPException(status_code=503, detail="Chatbot not initialized")

    if not request.question.strip():
        raise HTTPException(status_code=400, detail="Question cannot be empty")

    try:
        logger.info(f"📥 Received question: {request.question[:50]}...")

        # Get answer from chatbot
        answer = chatbot.find_best_answer(request.question)

        # Try to get confidence score from recent interactions
        confidence = None
        if chatbot.knowledge_base['user_interactions']:
            last_interaction = chatbot.knowledge_base['user_interactions'][-1]
            if last_interaction['question'] == request.question:
                confidence = last_interaction['confidence']

        logger.info(f"📤 Generated answer: {answer[:50]}...")

        return ChatResponse(
            question=request.question,
            answer=answer,
            status="success",
            confidence=confidence
        )

    except Exception as e:
        logger.error(f"❌ Error processing question: {e}")
        raise HTTPException(status_code=500, detail=f"Error processing question: {str(e)}")


# Feedback endpoint for training
@app.post("/feedback", response_model=StatusResponse)
async def provide_feedback(request: FeedbackRequest):
    """
    Provide feedback to improve the chatbot's responses
    """
    if chatbot is None:
        raise HTTPException(status_code=503, detail="Chatbot not initialized")

    if not request.question.strip() or not request.correct_answer.strip():
        raise HTTPException(status_code=400, detail="Question and correct answer cannot be empty")

    try:
        logger.info(f"📚 Learning from feedback: {request.question[:30]}...")
        chatbot.learn_from_feedback(request.question, request.correct_answer)

        return StatusResponse(
            status="success",
            message="Thank you for the feedback! The chatbot has learned something new."
        )

    except Exception as e:
        logger.error(f"❌ Error processing feedback: {e}")
        raise HTTPException(status_code=500, detail=f"Error processing feedback: {str(e)}")


# Statistics endpoint
@app.get("/stats", response_model=StatsResponse)
async def get_stats():
    """
    Get chatbot statistics
    """
    if chatbot is None:
        raise HTTPException(status_code=503, detail="Chatbot not initialized")

    try:
        stats = chatbot.get_statistics()
        return StatsResponse(
            qa_pairs=stats['qa_pairs'],
            documents=stats['documents'],
            interactions=stats['interactions'],
            categories=stats['categories'],
            status="success"
        )

    except Exception as e:
        logger.error(f"❌ Error getting statistics: {e}")
        raise HTTPException(status_code=500, detail=f"Error getting statistics: {str(e)}")


# Add knowledge endpoint
@app.post("/add-knowledge", response_model=StatusResponse)
async def add_knowledge(question: str, answer: str, category: Optional[str] = None):
    """
    Add new Q&A knowledge to the chatbot
    """
    if chatbot is None:
        raise HTTPException(status_code=503, detail="Chatbot not initialized")

    if not question.strip() or not answer.strip():
        raise HTTPException(status_code=400, detail="Question and answer cannot be empty")

    try:
        logger.info(f"➕ Adding knowledge: {question[:30]}...")
        chatbot.add_qa_pair(question, answer, category)
        chatbot.train_model()  # Retrain after adding knowledge

        return StatusResponse(
            status="success",
            message="Knowledge added successfully and model retrained"
        )

    except Exception as e:
        logger.error(f"❌ Error adding knowledge: {e}")
        raise HTTPException(status_code=500, detail=f"Error adding knowledge: {str(e)}")


# Remove the deprecated shutdown event handler - now handled in lifespan

# Run the server
if __name__ == "__main__":
    print("🚀 Starting FastAPI Chatbot Server...")
    print("📖 API Documentation will be available at: http://localhost:8000/docs")
    print("🔄 Alternative docs at: http://localhost:8000/redoc")

    uvicorn.run(
        "api:app",  # Replace "main" with your file name if different
        host="0.0.0.0",
        port=8000,
        reload=True,  # Set to False in production
        log_level="info"
    )