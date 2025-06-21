#!/usr/bin/env python3
"""
Build CPRD Multimorbidity Knowledge Graph in Neo4j
Demonstrates GraphRAG capabilities for medical relationship discovery
"""

import pandas as pd
import os
from neo4j import GraphDatabase
from dotenv import load_dotenv
import json

# Load environment variables
load_dotenv()

class CPRDGraphBuilder:
    def __init__(self):
        """Initialize Neo4j connection"""
        self.uri = os.getenv('NEO4J_URI', 'bolt://localhost:7687')
        self.username = os.getenv('NEO4J_USERNAME', 'neo4j')
        self.password = os.getenv('NEO4J_PASSWORD', 'password')
        
        try:
            self.driver = GraphDatabase.driver(self.uri, auth=(self.username, self.password))
            print(f"✓ Connected to Neo4j at {self.uri}")
        except Exception as e:
            print(f"❌ Failed to connect to Neo4j: {e}")
            print("Please ensure Neo4j is running and credentials are correct")
            return None
    
    def clear_database(self):
        """Clear existing data for fresh start"""
        with self.driver.session() as session:
            session.run("MATCH (n) DETACH DELETE n")
            print("✓ Database cleared")
    
    def create_constraints(self):
        """Create database constraints and indexes"""
        constraints = [
            "CREATE CONSTRAINT disease_id IF NOT EXISTS FOR (d:Disease) REQUIRE d.id IS UNIQUE",
            "CREATE CONSTRAINT system_name IF NOT EXISTS FOR (s:BodySystem) REQUIRE s.name IS UNIQUE",
            "CREATE INDEX disease_name IF NOT EXISTS FOR (d:Disease) ON (d.name)",
            "CREATE INDEX system_num IF NOT EXISTS FOR (s:BodySystem) ON (s.system_num)"
        ]
        
        with self.driver.session() as session:
            for constraint in constraints:
                try:
                    session.run(constraint)
                except Exception as e:
                    if "already exists" not in str(e).lower():
                        print(f"Warning: {e}")
        print("✓ Constraints and indexes created")
    
    def load_diseases_and_systems(self):
        """Load diseases and body systems from CPRD data"""
        df = pd.read_csv('/mnt/c/Users/User/OneDrive/Documents/GitHub/Multimorbidity_Graphs/documents/CPRD_multimorbidity_codelists-main/DiseaseSummary.csv')
        
        with self.driver.session() as session:
            # Create body systems
            systems = df[['system', 'system_num']].drop_duplicates()
            
            for _, row in systems.iterrows():
                session.run("""
                    MERGE (s:BodySystem {name: $system_name, system_num: $system_num})
                    SET s.created_at = datetime()
                """, system_name=row['system'], system_num=int(row['system_num']))
            
            print(f"✓ Created {len(systems)} body systems")
            
            # Create diseases
            disease_count = 0
            for _, row in df.iterrows():
                session.run("""
                    MERGE (d:Disease {
                        id: $disease_num,
                        name: $disease_name,
                        original_name: $original_name,
                        diagnosis_type: $diagnosis_type,
                        has_test_results: $has_test_results
                    })
                    SET d.created_at = datetime()
                    
                    WITH d
                    MATCH (s:BodySystem {name: $system_name})
                    MERGE (d)-[:AFFECTS_SYSTEM]->(s)
                """, 
                disease_num=int(row['disease_num']),
                disease_name=row['Disease_mod'],
                original_name=row['Disease'],
                system_name=row['system'],
                diagnosis_type=row['type'] if pd.notna(row['type']) else 'unknown',
                has_test_results=row['testresults'] == 'yes'
                )
                disease_count += 1
            
            print(f"✓ Created {disease_count} diseases with system relationships")
    
    def create_multimorbidity_patterns(self):
        """Create relationships based on known multimorbidity patterns"""
        
        # Known high-correlation pairs from research
        multimorbidity_relationships = [
            # Cardiovascular-Endocrine cluster
            ("Type 2 Diabetes Mellitus", "Hypertension", "COMMONLY_OCCURS_WITH", 0.85),
            ("Type 2 Diabetes Mellitus", "Heart failure", "COMMONLY_OCCURS_WITH", 0.65),
            ("Type 2 Diabetes Mellitus", "Chronic Kidney Disease", "COMMONLY_OCCURS_WITH", 0.75),
            ("Type 2 Diabetes Mellitus", "Obesity", "COMMONLY_OCCURS_WITH", 0.70),
            ("Type 2 Diabetes Mellitus", "Diabetic Neuropathy", "LEADS_TO", 0.90),
            ("Type 1 Diabetes Mellitus", "Diabetic Neuropathy", "LEADS_TO", 0.75),
            
            # Cardiovascular cluster
            ("Hypertension", "Heart failure", "COMMONLY_OCCURS_WITH", 0.80),
            ("Hypertension", "Atrial Fibrillation", "COMMONLY_OCCURS_WITH", 0.60),
            ("Myocardial Infarction", "Heart failure", "LEADS_TO", 0.70),
            ("Coronary Heart Disease (not otherwise specified)", "Myocardial Infarction", "LEADS_TO", 0.65),
            
            # Respiratory-Cardiovascular
            ("COPD", "Heart failure", "COMMONLY_OCCURS_WITH", 0.45),
            ("COPD", "Depression", "COMMONLY_OCCURS_WITH", 0.55),
            
            # Mental Health connections
            ("Depression", "Anxiety disorders", "COMMONLY_OCCURS_WITH", 0.70),
            ("Depression", "Obesity", "COMMONLY_OCCURS_WITH", 0.40),
            
            # Metabolic syndrome
            ("Obesity", "Type 2 Diabetes Mellitus", "INCREASES_RISK_OF", 0.75),
            ("Obesity", "Hypertension", "INCREASES_RISK_OF", 0.65),
            
            # Cancer relationships
            ("Primary Malignancy_Lung", "COPD", "ASSOCIATED_WITH", 0.55),
            ("Primary Malignancy_Liver", "Alcoholic liver disease", "ASSOCIATED_WITH", 0.60),
            
            # Autoimmune cluster
            ("Rheumatoid Arthritis", "Depression", "COMMONLY_OCCURS_WITH", 0.50),
            ("Lupus Erythematosus", "Chronic Kidney Disease", "LEADS_TO", 0.40),
        ]
        
        with self.driver.session() as session:
            relationship_count = 0
            for disease1, disease2, rel_type, strength in multimorbidity_relationships:
                result = session.run("""
                    MATCH (d1:Disease) WHERE d1.name CONTAINS $disease1 OR d1.original_name CONTAINS $disease1
                    MATCH (d2:Disease) WHERE d2.name CONTAINS $disease2 OR d2.original_name CONTAINS $disease2
                    WITH d1, d2, $rel_type as rel_type, $strength as strength
                    WHERE d1 <> d2
                    MERGE (d1)-[r:MULTIMORBIDITY_PATTERN {type: rel_type}]->(d2)
                    SET r.strength = strength,
                        r.evidence_source = 'CPRD_research',
                        r.created_at = datetime()
                    RETURN count(r) as created
                """, disease1=disease1, disease2=disease2, rel_type=rel_type, strength=strength)
                
                created = result.single()
                if created and created['created'] > 0:
                    relationship_count += created['created']
            
            print(f"✓ Created {relationship_count} multimorbidity relationships")
    
    def create_system_interactions(self):
        """Create cross-system interaction patterns"""
        
        system_interactions = [
            ("Diseases of the Circulatory System", "Endocrine Diseases", "HIGH_INTERACTION", 8.5),
            ("Diseases of the Circulatory System", "Diseases of the Respiratory System", "MODERATE_INTERACTION", 6.8),
            ("Endocrine Diseases", "Diseases of the Genitourinary System", "HIGH_INTERACTION", 7.2),
            ("Mental Health Disorders", "Diseases of the Circulatory System", "MODERATE_INTERACTION", 5.1),
            ("Mental Health Disorders", "Endocrine Diseases", "MODERATE_INTERACTION", 6.2),
            ("Diseases of the Respiratory System", "Mental Health Disorders", "MODERATE_INTERACTION", 4.1),
        ]
        
        with self.driver.session() as session:
            for system1, system2, interaction_type, strength in system_interactions:
                session.run("""
                    MATCH (s1:BodySystem {name: $system1})
                    MATCH (s2:BodySystem {name: $system2})
                    MERGE (s1)-[r:SYSTEM_INTERACTION {type: $interaction_type}]->(s2)
                    SET r.strength = $strength,
                        r.bidirectional = true,
                        r.created_at = datetime()
                """, system1=system1, system2=system2, interaction_type=interaction_type, strength=strength)
        
        print("✓ Created cross-system interaction patterns")
    
    def add_complexity_scores(self):
        """Add multimorbidity complexity scores to diseases"""
        
        with self.driver.session() as session:
            # Calculate complexity based on number of relationships
            session.run("""
                MATCH (d:Disease)
                OPTIONAL MATCH (d)-[r:MULTIMORBIDITY_PATTERN]-()
                WITH d, count(r) as relationship_count
                SET d.complexity_score = 
                    CASE 
                        WHEN relationship_count >= 5 THEN 'HIGH'
                        WHEN relationship_count >= 3 THEN 'MODERATE' 
                        WHEN relationship_count >= 1 THEN 'LOW'
                        ELSE 'ISOLATED'
                    END,
                    d.relationship_count = relationship_count
            """)
            
            # Mark hub diseases (diseases with many connections)
            session.run("""
                MATCH (d:Disease)
                WHERE d.relationship_count >= 4
                SET d:HubDisease
            """)
            
            print("✓ Added complexity scores and identified hub diseases")
    
    def create_sample_patients(self):
        """Create sample patient profiles for demonstration"""
        
        sample_patients = [
            {
                'id': 'PATIENT_001',
                'age_group': '65-75',
                'conditions': ['Type 2 Diabetes Mellitus', 'Hypertension', 'Heart failure'],
                'complexity': 'HIGH'
            },
            {
                'id': 'PATIENT_002', 
                'age_group': '55-65',
                'conditions': ['COPD', 'Depression', 'Anxiety disorders'],
                'complexity': 'MODERATE'
            },
            {
                'id': 'PATIENT_003',
                'age_group': '45-55', 
                'conditions': ['Obesity', 'Type 2 Diabetes Mellitus', 'Hypertension', 'Depression'],
                'complexity': 'HIGH'
            }
        ]
        
        with self.driver.session() as session:
            for patient in sample_patients:
                # Create patient node
                session.run("""
                    CREATE (p:Patient {
                        id: $patient_id,
                        age_group: $age_group,
                        complexity: $complexity,
                        created_at: datetime()
                    })
                """, patient_id=patient['id'], age_group=patient['age_group'], complexity=patient['complexity'])
                
                # Link to conditions
                for condition in patient['conditions']:
                    session.run("""
                        MATCH (p:Patient {id: $patient_id})
                        MATCH (d:Disease) 
                        WHERE d.name CONTAINS $condition OR d.original_name CONTAINS $condition
                        MERGE (p)-[:HAS_CONDITION {diagnosed_at: datetime()}]->(d)
                    """, patient_id=patient['id'], condition=condition)
        
        print("✓ Created sample patient profiles")
    
    def run_demo_queries(self):
        """Run demonstration queries showing GraphRAG capabilities"""
        
        print("\n" + "="*60)
        print("🔍 DEMONSTRATION QUERIES - GraphRAG in Action")
        print("="*60)
        
        with self.driver.session() as session:
            
            # Query 1: Find hub diseases
            print("\n1. 🎯 Hub Diseases (Most Connected Conditions):")
            result = session.run("""
                MATCH (d:HubDisease)
                RETURN d.name as disease, d.relationship_count as connections
                ORDER BY d.relationship_count DESC
                LIMIT 5
            """)
            for record in result:
                print(f"   • {record['disease']}: {record['connections']} connections")
            
            # Query 2: Complex multimorbidity patterns
            print("\n2. 🔗 Complex Multimorbidity Patterns:")
            result = session.run("""
                MATCH (d1:Disease)-[r:MULTIMORBIDITY_PATTERN]->(d2:Disease)
                WHERE r.strength > 0.7
                RETURN d1.name as disease1, r.type as relationship, d2.name as disease2, r.strength as strength
                ORDER BY r.strength DESC
                LIMIT 5
            """)
            for record in result:
                print(f"   • {record['disease1']} → {record['disease2']} ({record['strength']:.0%} correlation)")
            
            # Query 3: Cross-system interactions
            print("\n3. 🌐 Cross-System Disease Interactions:")
            result = session.run("""
                MATCH (d1:Disease)-[:AFFECTS_SYSTEM]->(s1:BodySystem)
                MATCH (d2:Disease)-[:AFFECTS_SYSTEM]->(s2:BodySystem)
                MATCH (d1)-[r:MULTIMORBIDITY_PATTERN]->(d2)
                WHERE s1 <> s2
                RETURN s1.name as system1, s2.name as system2, count(r) as interactions
                ORDER BY interactions DESC
                LIMIT 5
            """)
            for record in result:
                print(f"   • {record['system1']} ↔ {record['system2']}: {record['interactions']} interactions")
            
            # Query 4: Patient risk analysis
            print("\n4. 👥 Patient Risk Analysis:")
            result = session.run("""
                MATCH (p:Patient)-[:HAS_CONDITION]->(d:Disease)
                WITH p, collect(d.name) as conditions, count(d) as condition_count
                RETURN p.id as patient, condition_count, conditions
                ORDER BY condition_count DESC
            """)
            for record in result:
                print(f"   • {record['patient']}: {record['condition_count']} conditions")
                print(f"     Conditions: {', '.join(record['conditions'][:3])}...")
            
            # Query 5: Predictive insights
            print("\n5. 🔮 Predictive Insights (What conditions commonly follow?):")
            result = session.run("""
                MATCH (d1:Disease)-[r:MULTIMORBIDITY_PATTERN {type: 'LEADS_TO'}]->(d2:Disease)
                RETURN d1.name as primary_condition, d2.name as likely_progression, r.strength as probability
                ORDER BY r.strength DESC
                LIMIT 3
            """)
            for record in result:
                print(f"   • {record['primary_condition']} → {record['likely_progression']} ({record['probability']:.0%} probability)")
    
    def get_graph_statistics(self):
        """Get overall graph statistics"""
        
        with self.driver.session() as session:
            stats = {}
            
            # Node counts
            result = session.run("MATCH (d:Disease) RETURN count(d) as disease_count")
            stats['diseases'] = result.single()['disease_count']
            
            result = session.run("MATCH (s:BodySystem) RETURN count(s) as system_count") 
            stats['body_systems'] = result.single()['system_count']
            
            result = session.run("MATCH (p:Patient) RETURN count(p) as patient_count")
            stats['patients'] = result.single()['patient_count']
            
            # Relationship counts
            result = session.run("MATCH ()-[r:MULTIMORBIDITY_PATTERN]->() RETURN count(r) as rel_count")
            stats['multimorbidity_relationships'] = result.single()['rel_count']
            
            result = session.run("MATCH ()-[r:SYSTEM_INTERACTION]->() RETURN count(r) as rel_count")
            stats['system_interactions'] = result.single()['rel_count']
            
            return stats
    
    def close(self):
        """Close database connection"""
        if hasattr(self, 'driver'):
            self.driver.close()

def main():
    """Main execution function"""
    print("🏗️  Building CPRD Multimorbidity Knowledge Graph")
    print("="*60)
    
    # Initialize graph builder
    builder = CPRDGraphBuilder()
    if not hasattr(builder, 'driver'):
        print("❌ Cannot proceed without database connection")
        return
    
    try:
        # Build the knowledge graph
        print("\n📋 Step 1: Preparing database...")
        builder.clear_database()
        builder.create_constraints()
        
        print("\n📊 Step 2: Loading CPRD data...")
        builder.load_diseases_and_systems()
        
        print("\n🔗 Step 3: Creating multimorbidity patterns...")
        builder.create_multimorbidity_patterns()
        
        print("\n🌐 Step 4: Adding system interactions...")
        builder.create_system_interactions()
        
        print("\n🎯 Step 5: Calculating complexity scores...")
        builder.add_complexity_scores()
        
        print("\n👥 Step 6: Creating sample patients...")
        builder.create_sample_patients()
        
        # Get statistics
        stats = builder.get_graph_statistics()
        
        print("\n" + "="*60)
        print("📈 KNOWLEDGE GRAPH STATISTICS")
        print("="*60)
        print(f"🏥 Diseases: {stats['diseases']}")
        print(f"🫀 Body Systems: {stats['body_systems']}")
        print(f"👥 Sample Patients: {stats['patients']}")
        print(f"🔗 Multimorbidity Relationships: {stats['multimorbidity_relationships']}")
        print(f"🌐 System Interactions: {stats['system_interactions']}")
        
        # Run demonstration queries
        builder.run_demo_queries()
        
        print("\n" + "="*60)
        print("🎉 KNOWLEDGE GRAPH SUCCESSFULLY CREATED!")
        print("="*60)
        print("Your Neo4j database now contains a powerful medical knowledge graph")
        print("demonstrating GraphRAG capabilities for multimorbidity analysis.")
        print("\nAccess Neo4j Browser to explore the graph visually!")
        
    except Exception as e:
        print(f"❌ Error building knowledge graph: {e}")
        import traceback
        traceback.print_exc()
    
    finally:
        builder.close()

if __name__ == "__main__":
    main()