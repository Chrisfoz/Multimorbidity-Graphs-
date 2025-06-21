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
from langchain_graph_retriever import GraphRetriever
from dotenv import load_dotenv
from processing_pipeline import load_cprd_codelists, load_cprd_tests, create_multimorbidity_relationships, analyze_condition_complexity

load_dotenv()

# Initialize components
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

def store_graph_documents(graph_documents):
    """Store graph documents in Neo4j"""
    print(f"Storing {len(graph_documents)} graph documents...")
    graph.add_graph_documents(graph_documents)
    print("Graph documents stored successfully")

def create_rag_chain(vector_store):
    """Create RAG chain combining vector search and graph retrieval"""
    
    # Create graph retriever
    graph_retriever = GraphRetriever(
        graph=graph,
        strategy=Eager(),
        vector_store=vector_store
    )
    
    # Create prompt template
    prompt = ChatPromptTemplate.from_template("""
    Answer the question based on the following context from both vector search and graph relationships:
    
    Context: {context}
    
    Question: {question}
    
    Answer:
    """)
    
    # Create RAG chain
    chain = (
        {"context": graph_retriever, "question": RunnablePassthrough()}
        | prompt
        | llm
        | StrOutputParser()
    )
    
    return chain

def load_and_chunk_documents() -> List[Document]:
    """Load and chunk .docx files using semantic chunking"""
    documents = []
    docx_files = glob.glob("./documents/*.docx")  # Adjust path as needed
    
    if not docx_files:
        print("No .docx files found")
        return documents
    
    # Initialize semantic chunker
    text_splitter = SemanticChunker(embeddings)
    
    for docx_file in docx_files:
        print(f"Processing {docx_file}...")
        
        # Load document
        loader = Docx2txtLoader(docx_file)
        raw_docs = loader.load()
        
        # Apply semantic chunking
        chunks = text_splitter.split_documents(raw_docs)
        
        # Add metadata
        for chunk in chunks:
            chunk.metadata["source"] = os.path.basename(docx_file)
        
        documents.extend(chunks)
    
    print(f"Loaded {len(documents)} document chunks")
    return documents

def main():
    """Complete GraphRAG implementation with CPRD multimorbidity data"""
    print("Starting GraphRAG System with CPRD Multimorbidity Analysis")
    
    # 1. Load documents (both DOCX and CSV)
    print("\n=== Loading Documents ===")
    docx_documents = load_and_chunk_documents()
    cprd_documents = load_cprd_codelists()
    test_documents = load_cprd_tests()
    
    # Combine all documents
    all_documents = docx_documents + cprd_documents + test_documents
    print(f"Total documents loaded: {len(all_documents)}")
    
    # 2. Analyze multimorbidity complexity
    print("\n=== Analyzing Multimorbidity Patterns ===")
    complexity_analysis = analyze_condition_complexity(cprd_documents)
    print(f"Found {complexity_analysis['total_conditions']} conditions across {complexity_analysis['systems_count']} body systems")
    
    # 3. Create multimorbidity relationships
    relationships = create_multimorbidity_relationships(cprd_documents)
    print(f"Generated {len(relationships)} multimorbidity relationships")
    
    # 4. Create vector store
    print("\n=== Building Vector Store ===")
    vector_store = InMemoryVectorStore.from_documents(all_documents, embeddings)
    
    # 5. Extract and store graph
    print("\n=== Building Knowledge Graph ===")
    llm_transformer = LLMGraphTransformer(llm=llm)
    graph_documents = llm_transformer.convert_to_graph_documents(all_documents)
    store_graph_documents(graph_documents)
    
    # 6. Create RAG chain
    print("\n=== Creating RAG Chain ===")
    chain = create_rag_chain(vector_store)
    
    print("\n🎉 GraphRAG Multimorbidity System Ready!")
    print(f"📊 System loaded with:")
    print(f"   • {len(docx_documents)} clinical case documents")
    print(f"   • {len(cprd_documents)} CPRD condition codelists") 
    print(f"   • {len(test_documents)} test value definitions")
    print(f"   • {complexity_analysis['total_conditions']} validated chronic conditions")
    print(f"   • {complexity_analysis['systems_count']} body systems")
    print(f"   • {len(relationships)} multimorbidity relationships")
    
    return chain, complexity_analysis, relationships
if __name__ == "__main__":
    chain, analysis, relationships = main()