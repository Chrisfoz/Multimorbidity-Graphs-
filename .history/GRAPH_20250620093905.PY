import os
import glob
from typing import List
from langchain_core.documents import Document
from graph_retriever.strategies import Eager
from langchain_core.vectorstores import InMemoryVectorStore
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from langchain_google_genai import GoogleGenerativeAIEmbeddings, ChatGoogleGenerativeAI
from langchain_experimental.graph_transformers import LLMGraphTransformer
from langchain_experimental.text_splitter import SemanticChunker
from langchain_neo4j import Neo4jGraph
from langchain_community.document_loaders import Docx2txtLoader
from langchain_graph_retriever import GraphRetriever# Initialize LLM Graph Transformer
from dotenv import load_dotenv

load_dotenv()

print("Initializing LLM Graph Transformer...")
llm_transformer = LLMGraphTransformer(llm=llm)# Initialize components
embeddings = GoogleGenerativeAIEmbeddings(
    model="models/gemini-embedding-exp-03-07",
    google_api_key=os.getenv("GOOGLE_API_KEY")
)
llm = ChatGoogleGenerativeAI(
    model="models/gemini-2.5-flash-preview-05-20",
    google_api_key=os.getenv("GOOGLE_API_KEY")
)
graph = Neo4jGraph(
    url=os.getenv("NEO4J_URI"),
    username=os.getenv("NEO4J_USERNAME"),
    password=os.getenv("NEO4J_PASSWORD")
)
def main():
    """Complete GraphRAG implementation"""
    print("Starting GraphRAG System")
    
    # 1. Load and chunk documents
    documents = load_and_chunk_documents()
    
    # 2. Create vector store
    vector_store = InMemoryVectorStore.from_documents(documents, embeddings)
    
    # 3. Extract and store graph
    llm_transformer = LLMGraphTransformer(llm=llm)
    graph_documents = llm_transformer.convert_to_graph_documents(documents)
    store_graph_documents(graph_documents)
    
    # 4. Create RAG chain
    chain = create_rag_chain(vector_store)
    
    print("GraphRAG system ready")
    return chain
if __name__ == "__main__":
    chain = main()