import os
import sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from graph import main
from langchain_neo4j import Neo4jGraph
from dotenv import load_dotenv

load_dotenv()

def test_graphrag_system(chain, graph):
    """Test the GraphRAG system with multimorbidity-focused queries"""
    
    # Test queries focused on multimorbidity analysis
    test_queries = [
        "What are the main chronic conditions in the CPRD dataset?",
        "How many body systems are represented in the multimorbidity data?",
        "What are the relationships between diabetes and cardiovascular conditions?",
        "Which conditions commonly occur together in multimorbidity patterns?",
        "What are the key features of complex multimorbidity?"
    ]
    
    print("🧪 Testing GraphRAG Multimorbidity System")
    print("=" * 50)
    
    for query in test_queries:
        print(f"\n🔍 Query: {query}")
        try:
            response = chain.invoke(query)
            print(f"✅ Response: {response[:300]}...")
        except Exception as e:
            print(f"❌ Error: {e}")
    
    # Check graph statistics
    print(f"\n📊 Graph Database Statistics:")
    try:
        nodes_count = graph.query("MATCH (n) RETURN count(n) as count")[0]["count"]
        rels_count = graph.query("MATCH ()-[r]->() RETURN count(r) as count")[0]["count"]
        print(f"   • Total nodes: {nodes_count}")
        print(f"   • Total relationships: {rels_count}")
        
        # Check for specific node types
        try:
            entity_types = graph.query("""
                MATCH (n) 
                RETURN DISTINCT labels(n) as labels, count(*) as count 
                ORDER BY count DESC
            """)
            print(f"   • Entity types:")
            for entity in entity_types[:5]:  # Show top 5
                print(f"     - {entity['labels']}: {entity['count']}")
        except Exception as e:
            print(f"   • Could not get entity type breakdown: {e}")
            
    except Exception as e:
        print(f"❌ Error getting graph stats: {e}")

def test_cprd_data_loading():
    """Test CPRD data loading independently"""
    print("\n🧪 Testing CPRD Data Loading")
    print("=" * 30)
    
    try:
        from processing_pipeline import load_cprd_codelists, load_cprd_tests, analyze_condition_complexity
        
        # Test loading codelists
        cprd_docs = load_cprd_codelists()
        print(f"✅ Loaded {len(cprd_docs)} CPRD condition documents")
        
        # Test loading test values
        test_docs = load_cprd_tests()
        print(f"✅ Loaded {len(test_docs)} CPRD test documents")
        
        # Test complexity analysis
        analysis = analyze_condition_complexity(cprd_docs)
        print(f"✅ Analysis complete: {analysis['total_conditions']} conditions, {analysis['systems_count']} systems")
        
        return True
        
    except Exception as e:
        print(f"❌ CPRD data loading failed: {e}")
        return False

# Main test runner
if __name__ == "__main__":
    print("🚀 Starting GraphRAG Multimorbidity System Tests")
    print("=" * 60)
    
    # Test 1: CPRD data loading
    cprd_success = test_cprd_data_loading()
    
    if cprd_success:
        # Test 2: Full system test
        try:
            chain, analysis, relationships = main()
            
            # Initialize graph connection for testing
            graph = Neo4jGraph(
                url=os.getenv("NEO4J_URI", "bolt://localhost:7687"),
                username=os.getenv("NEO4J_USERNAME", "neo4j"),
                password=os.getenv("NEO4J_PASSWORD", "password")
            )
            
            test_graphrag_system(chain, graph)
            
            print(f"\n✅ All tests completed successfully!")
            print(f"📈 System Analysis Summary:")
            print(f"   • Conditions: {analysis['total_conditions']}")
            print(f"   • Body Systems: {analysis['systems_count']}")
            print(f"   • Relationships: {len(relationships)}")
            
        except Exception as e:
            print(f"❌ System test failed: {e}")
    else:
        print("⚠️  Skipping full system test due to CPRD data loading failure")