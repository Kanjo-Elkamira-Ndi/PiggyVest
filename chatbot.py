import json
import pickle
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import nltk
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize, sent_tokenize
from nltk.stem import PorterStemmer
import re
import os
from datetime import datetime


# Download required NLTK data - Fixed for newer NLTK versions
def download_nltk_data():
    """Download required NLTK data with proper error handling"""
    required_data = ['punkt', 'punkt_tab', 'stopwords']

    for data_name in required_data:
        try:
            nltk.data.find(f'tokenizers/{data_name}' if 'punkt' in data_name else f'corpora/{data_name}')
            print(f"✓ {data_name} already available")
        except LookupError:
            try:
                print(f"Downloading {data_name}...")
                nltk.download(data_name, quiet=True)
                print(f"✓ {data_name} downloaded successfully")
            except Exception as e:
                print(f"⚠ Warning: Could not download {data_name}: {e}")


# Call the download function
download_nltk_data()


class IntelligentChatbot:
    def __init__(self, model_path='chatbot_model.pkl', knowledge_path='knowledge_base.json'):
        self.model_path = model_path
        self.knowledge_path = knowledge_path
        self.stemmer = PorterStemmer()

        # Initialize stop words with fallback
        try:
            self.stop_words = set(stopwords.words('english'))
        except LookupError:
            print("⚠ Stopwords not available, using basic set")
            self.stop_words = {'the', 'is', 'at', 'which', 'on', 'a', 'an', 'and', 'or', 'but', 'in', 'with', 'to',
                               'for', 'of', 'as', 'by'}

        # TF-IDF vectorizer
        self.vectorizer = TfidfVectorizer(
            max_features=5000,
            ngram_range=(1, 2),
            lowercase=True,
            stop_words='english'  # Use sklearn's built-in stopwords as backup
        )

        # Knowledge base structure
        self.knowledge_base = {
            'qa_pairs': [],
            'documents': [],
            'user_interactions': [],
            'categories': {},
            'last_updated': None
        }

        self.similarity_threshold = 0.3

        self.load_knowledge_base()
        self.load_model()

    def preprocess_text(self, text):
        """Clean and preprocess text with improved error handling"""
        if not text or not isinstance(text, str):
            return ""

        # Clean text
        text = re.sub(r'[^a-zA-Z\s]', '', text.lower())

        try:
            # Try NLTK tokenization first
            tokens = word_tokenize(text)
        except LookupError:
            # Fallback to simple tokenization if NLTK data is missing
            print("⚠ Using fallback tokenization")
            tokens = text.split()

        # Stem and filter tokens
        processed_tokens = []
        for token in tokens:
            if len(token) > 2 and token not in self.stop_words:
                try:
                    stemmed = self.stemmer.stem(token)
                    processed_tokens.append(stemmed)
                except Exception:
                    processed_tokens.append(token)

        return ' '.join(processed_tokens)

    def add_qa_pair(self, question, answer, category=None):
        """Add single Q&A pair (without auto-retraining)"""
        if not question or not answer:
            print("⚠ Question and answer cannot be empty")
            return

        qa_pair = {
            'question': question,
            'answer': answer,
            'category': category,
            'processed_question': self.preprocess_text(question),
            'timestamp': datetime.now().isoformat()
        }
        self.knowledge_base['qa_pairs'].append(qa_pair)

        if category:
            if category not in self.knowledge_base['categories']:
                self.knowledge_base['categories'][category] = []
            self.knowledge_base['categories'][category].append(len(self.knowledge_base['qa_pairs']) - 1)

        print(f"✓ Added Q&A: {question[:40]}...")

    def load_qa_from_json(self, json_file_path):
        """Load Q&A pairs from your specific JSON format"""
        try:
            with open(json_file_path, 'r', encoding='utf-8') as f:
                qa_data = json.load(f)

            pairs_added = 0
            for item in qa_data:
                questions = item.get('question', [])
                answers = item.get('answer', [])
                category = item.get('category', 'general')

                # Handle single strings or arrays
                if isinstance(questions, str):
                    questions = [questions]
                if isinstance(answers, str):
                    answers = [answers]

                # Create pairs for each question-answer combination
                for question in questions:
                    for answer in answers:
                        if question.strip() and answer.strip():
                            qa_pair = {
                                'question': question.strip(),
                                'answer': answer.strip(),
                                'category': category,
                                'processed_question': self.preprocess_text(question),
                                'timestamp': datetime.now().isoformat()
                            }
                            self.knowledge_base['qa_pairs'].append(qa_pair)

                            # Update categories
                            if category not in self.knowledge_base['categories']:
                                self.knowledge_base['categories'][category] = []
                            self.knowledge_base['categories'][category].append(len(self.knowledge_base['qa_pairs']) - 1)

                            pairs_added += 1

            print(f"✓ Loaded {pairs_added} Q&A pairs from {json_file_path}")
            return pairs_added

        except FileNotFoundError:
            print(f"❌ File not found: {json_file_path}")
            return 0
        except json.JSONDecodeError as e:
            print(f"❌ JSON decode error in {json_file_path}: {e}")
            return 0
        except Exception as e:
            print(f"❌ Error loading {json_file_path}: {e}")
            return 0

    def add_document(self, text, title=None, category=None):
        """Add document (without auto-retraining)"""
        if not text:
            print("⚠ Document text cannot be empty")
            return

        try:
            sentences = sent_tokenize(text)
        except LookupError:
            # Fallback sentence tokenization
            sentences = [s.strip() for s in re.split(r'[.!?]+', text) if s.strip()]

        document = {
            'title': title or f"Document_{len(self.knowledge_base['documents'])}",
            'content': text,
            'sentences': sentences,
            'category': category,
            'processed_content': self.preprocess_text(text),
            'timestamp': datetime.now().isoformat()
        }
        self.knowledge_base['documents'].append(document)

        print(f"✓ Added document: {title or 'Untitled'}")

    def load_text_file(self, file_path, title=None, category=None):
        """Load content from a text file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read().strip()

            if not content:
                print(f"⚠ File {file_path} is empty")
                return False

            filename = os.path.basename(file_path)
            title = title or filename.replace('.txt', '').replace('_', ' ').title()
            category = category or 'books'

            self.add_document(content, title, category)
            return True

        except FileNotFoundError:
            print(f"❌ File not found: {file_path}")
            return False
        except Exception as e:
            print(f"❌ Error loading {file_path}: {e}")
            return False

    def load_data_directory(self, data_dir='data'):
        """Load all data from your data directory structure"""
        if not os.path.exists(data_dir):
            print(f"❌ Data directory not found: {data_dir}")
            return

        print(f"📁 Loading data from {data_dir}...")

        # Load Q&A JSON file
        qa_file = os.path.join(data_dir, 'Q&A.json')
        if os.path.exists(qa_file):
            self.load_qa_from_json(qa_file)
        else:
            print(f"⚠ Q&A.json not found in {data_dir}")

        # Load books directory
        books_dir = os.path.join(data_dir, 'books')
        if os.path.exists(books_dir):
            print(f"📚 Loading books from {books_dir}...")
            for filename in os.listdir(books_dir):
                if filename.endswith('.txt'):
                    file_path = os.path.join(books_dir, filename)
                    self.load_text_file(file_path)
        else:
            print(f"⚠ Books directory not found: {books_dir}")

        print("✅ Data loading complete!")
        self.train_model()

    def train_model(self):
        """Train the chatbot model with better error handling"""
        questions, answers = [], []

        # Collect Q&A pairs
        for qa in self.knowledge_base['qa_pairs']:
            if qa['processed_question']:  # Only add if preprocessing worked
                questions.append(qa['processed_question'])
                answers.append(qa['answer'])

        # Collect document sentences
        for doc in self.knowledge_base['documents']:
            for sentence in doc['sentences']:
                if len(sentence.strip()) > 20:
                    processed_sentence = self.preprocess_text(sentence)
                    if processed_sentence:  # Only add if preprocessing worked
                        questions.append(processed_sentence)
                        answers.append(sentence.strip())

        if len(questions) < 2:
            print("⚠ Not enough training data yet (need at least 2 examples).")
            return

        try:
            print(f"🔄 Training model on {len(questions)} examples...")
            self.vectorizer.fit(questions)
            self.question_vectors = self.vectorizer.transform(questions)
            self.answers = answers
            print(f"✓ Model trained successfully on {len(questions)} examples!")
            self.save_model()
        except Exception as e:
            print(f"❌ Error training model: {e}")

    def find_best_answer(self, user_question):
        """Find the best answer with improved error handling"""
        if not hasattr(self, 'question_vectors') or self.question_vectors is None:
            return "I need training first. Please add some knowledge by adding Q&A pairs or documents."

        if not user_question or not user_question.strip():
            return "Please ask a question 🙂"

        try:
            processed_question = self.preprocess_text(user_question)
            if not processed_question:
                return "I couldn't understand your question. Could you rephrase it?"

            question_vector = self.vectorizer.transform([processed_question])
            similarities = cosine_similarity(question_vector, self.question_vectors)[0]

            best_idx = np.argmax(similarities)
            best_score = similarities[best_idx]

            if best_score >= self.similarity_threshold:
                answer = self.answers[best_idx]
                self.log_interaction(user_question, answer, float(best_score))
                return f"{answer}"
            else:
                doc_answer = self.search_documents(user_question)
                if doc_answer:
                    self.log_interaction(user_question, doc_answer, 0.1)
                    return f"{doc_answer}"
                return "I'm not sure about that. Could you rephrase your question or add more information to my knowledge base?"

        except Exception as e:
            print(f"❌ Error finding answer: {e}")
            return "Sorry, I encountered an error processing your question."

    def search_documents(self, question):
        """Search through documents for fallback answers"""
        processed_question = self.preprocess_text(question)
        if not processed_question:
            return None

        question_words = set(processed_question.split())
        best_sentence, best_score = "", 0

        for doc in self.knowledge_base['documents']:
            for sentence in doc['sentences']:
                if len(sentence.strip()) > 20:
                    processed_sentence = self.preprocess_text(sentence)
                    if processed_sentence:
                        sentence_words = set(processed_sentence.split())
                        overlap = len(question_words.intersection(sentence_words))
                        score = overlap / len(question_words) if question_words else 0

                        if score > best_score and score > 0.2:
                            best_score = score
                            best_sentence = sentence.strip()

        return best_sentence if best_sentence else None

    def log_interaction(self, question, answer, confidence):
        """Save user interactions"""
        interaction = {
            'question': question,
            'answer': answer,
            'confidence': confidence,
            'timestamp': datetime.now().isoformat()
        }
        self.knowledge_base['user_interactions'].append(interaction)

    def learn_from_feedback(self, question, correct_answer):
        """Learn from user corrections"""
        self.add_qa_pair(question, correct_answer, category='user_feedback')
        print("✓ Thank you for the feedback! I've learned something new.")
        # Retrain after feedback
        self.train_model()

    def get_statistics(self):
        """Get chatbot statistics"""
        return {
            'qa_pairs': len(self.knowledge_base['qa_pairs']),
            'documents': len(self.knowledge_base['documents']),
            'interactions': len(self.knowledge_base['user_interactions']),
            'categories': len(self.knowledge_base['categories'])
        }

    def save_knowledge_base(self):
        """Save knowledge base with error handling"""
        try:
            self.knowledge_base['last_updated'] = datetime.now().isoformat()
            with open(self.knowledge_path, 'w', encoding='utf-8') as f:
                json.dump(self.knowledge_base, f, indent=2, ensure_ascii=False)
            print(f"✓ Knowledge base saved → {self.knowledge_path}")
        except Exception as e:
            print(f"❌ Error saving knowledge base: {e}")

    def load_knowledge_base(self):
        """Load knowledge base with error handling"""
        if os.path.exists(self.knowledge_path):
            try:
                with open(self.knowledge_path, 'r', encoding='utf-8') as f:
                    self.knowledge_base = json.load(f)
                print(f"✓ Knowledge base loaded from {self.knowledge_path}")
            except Exception as e:
                print(f"❌ Error loading knowledge base: {e}")

    def save_model(self):
        """Save trained model with error handling"""
        try:
            model_data = {
                'vectorizer': self.vectorizer,
                'question_vectors': self.question_vectors,
                'answers': self.answers
            }
            with open(self.model_path, 'wb') as f:
                pickle.dump(model_data, f)
            print(f"✓ Model saved → {self.model_path}")
        except Exception as e:
            print(f"❌ Error saving model: {e}")

    def load_model(self):
        """Load trained model with error handling"""
        if os.path.exists(self.model_path):
            try:
                with open(self.model_path, 'rb') as f:
                    model_data = pickle.load(f)
                self.vectorizer = model_data['vectorizer']
                self.question_vectors = model_data['question_vectors']
                self.answers = model_data['answers']
                print(f"✓ Model loaded from {self.model_path}")
            except Exception as e:
                print(f"❌ Error loading model: {e}")

    def chat(self):
        """Interactive chat mode"""
        print("\n🤖 Chatbot is ready!")
        print("Commands: 'quit' to exit, 'stats' for statistics, 'feedback: <question> | <answer>' to teach me")
        print("-" * 60)

        while True:
            try:
                user_input = input("\n💬 You: ").strip()

                if user_input.lower() == 'quit':
                    print("👋 Goodbye!")
                    break

                elif user_input.lower() == 'stats':
                    stats = self.get_statistics()
                    print(f"📊 Statistics: {stats}")
                    continue

                elif user_input.lower().startswith('feedback:'):
                    try:
                        feedback_parts = user_input[9:].split('|')
                        if len(feedback_parts) == 2:
                            question = feedback_parts[0].strip()
                            answer = feedback_parts[1].strip()
                            self.learn_from_feedback(question, answer)
                        else:
                            print("Format: feedback: <question> | <correct_answer>")
                    except Exception as e:
                        print(f"Error processing feedback: {e}")
                    continue

                if user_input:
                    response = self.find_best_answer(user_input)
                    print(f"🤖 Bot: {response}")

            except KeyboardInterrupt:
                print("\n👋 Goodbye!")
                break
            except Exception as e:
                print(f"❌ Error: {e}")

        # Save knowledge base on exit
        self.save_knowledge_base()


# -------------------------
# Demo / Testing with Your Data
# -------------------------
def demo_chatbot():
    print("🚀 Initializing Intelligent Chatbot...")
    bot = IntelligentChatbot()

    print("\n📚 Loading your data...")

    # Load all your data from the data directory
    bot.load_data_directory('data')

    # Show stats
    print(f"\n📊 Chatbot Statistics: {bot.get_statistics()}")

    # Test some questions based on your data
    test_questions = [
        "hello",
        "hi there",
        "what's up",
        "tell me about betting risks",
        "what is pursa",
        "goodbye"
    ]

    print("\n🧪 Testing chatbot responses:")
    for question in test_questions:
        print(f"\n❓ User: {question}")
        response = bot.find_best_answer(question)
        print(f"🤖 Bot: {response}")

    # Start interactive chat
    print("\n🎯 Starting interactive chat mode...")
    bot.chat()


def load_custom_data_example():
    """Example of how to load your specific data"""
    bot = IntelligentChatbot()

    # Method 1: Load your entire data directory
    bot.load_data_directory('data')

    # Method 2: Load specific files
    # bot.load_qa_from_json('data/Q&A.json')
    # bot.load_text_file('data/books/betting_risks_knowledge_base.txt', 'Betting Risks Guide', 'finance')
    # bot.load_text_file('data/books/pursa_data.txt', 'Pursa Information', 'finance')

    # Train the model after loading all data
    # bot.train_model()

    return bot


if __name__ == "__main__":
    demo_chatbot()