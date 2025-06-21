import os
from langchain_neo4j import Neo4jGraph
from dotenv import load_dotenv

load_dotenv()

def test_neo4j_connection():
    """Test Neo4j database connection"""
    try:
        graph = Neo4jGraph(
            url=os.getenv("NEO4J_URI", "bolt://localhost:7687"),
            username=os.getenv("NEO4J_USERNAME", "neo4j"),
            password=os.getenv("NEO4J_PASSWORD", "password")
        )
        
        # Test basic query
        result = graph.query("RETURN 1 as test")
        print("✅ Neo4j connection successful!")
        print(f"Test query result: {result}")
        return True
        
    except Exception as e:
        print(f"❌ Neo4j connection failed: {e}")
        return False

if __name__ == "__main__":
    test_neo4j_connection()