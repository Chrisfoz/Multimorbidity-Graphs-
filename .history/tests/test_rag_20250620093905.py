def test_graphrag_system(chain):
    """Test the GraphRAG system with sample queries"""
    
    test_queries = [
        "What are the main topics discussed in the documents?",
        "How are the entities connected in the knowledge graph?",
        "Can you explain the relationships between key concepts?"
    ]
    
    for query in test_queries:
        print(f"\n🔍 Query: {query}")
        try:
            response = chain.invoke(query)
            print(f"Response: {response[:200]}...")
        except Exception as e:
            print(f"Error: {e}")
    
    # Check graph statistics
    try:
        nodes_count = graph.query("MATCH (n) RETURN count(n) as count")[0]["count"]
        rels_count = graph.query("MATCH ()-[r]->() RETURN count(r) as count")[0]["count"]
        print(f"\nGraph Stats: {nodes_count} nodes, {rels_count} relationships")
    except Exception as e:
        print(f"Error getting graph stats: {e}")
# Test the system
if __name__ == "__main__":
    chain = main()
    test_graphrag_system(chain)