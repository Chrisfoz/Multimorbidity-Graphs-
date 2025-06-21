from langchain_neo4j import Neo4jGraph
# Test connection
try:
    graph = Neo4jGraph(
        url="bolt://localhost:7687",
        username="neo4j",
        password="your-password"
    )
    print("Neo4j connection successful!")
except Exception as e:
    print(f"Neo4j connection failed: {e}")J