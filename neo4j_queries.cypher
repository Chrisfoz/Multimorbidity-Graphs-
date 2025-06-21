// CPRD Multimorbidity Knowledge Graph - Neo4j Cypher Queries
// Demonstrates GraphRAG capabilities for medical relationship discovery

// =============================================================================
// STEP 1: Clean and prepare database
// =============================================================================

// Clear existing data
MATCH (n) DETACH DELETE n;

// Create constraints and indexes
CREATE CONSTRAINT disease_id IF NOT EXISTS FOR (d:Disease) REQUIRE d.id IS UNIQUE;
CREATE CONSTRAINT system_name IF NOT EXISTS FOR (s:BodySystem) REQUIRE s.name IS UNIQUE;
CREATE INDEX disease_name IF NOT EXISTS FOR (d:Disease) ON (d.name);

// =============================================================================
// STEP 2: Create Body Systems (from CPRD data)
// =============================================================================

CREATE (s1:BodySystem {name: "Cancers", system_num: 1, condition_count: 40})
CREATE (s2:BodySystem {name: "Diseases of the Circulatory System", system_num: 2, condition_count: 36})
CREATE (s3:BodySystem {name: "Diseases of the Digestive System", system_num: 3, condition_count: 22})
CREATE (s4:BodySystem {name: "Congenital abnormalities", system_num: 4, condition_count: 3})
CREATE (s5:BodySystem {name: "Endocrine Diseases", system_num: 5, condition_count: 15})
CREATE (s6:BodySystem {name: "Diseases of the Eye", system_num: 6, condition_count: 6})
CREATE (s7:BodySystem {name: "Diseases of the Ear", system_num: 7, condition_count: 2})
CREATE (s8:BodySystem {name: "Diseases of the Respiratory System", system_num: 8, condition_count: 8})
CREATE (s9:BodySystem {name: "Haematological/Immunological conditions", system_num: 9, condition_count: 12})
CREATE (s10:BodySystem {name: "Infectious diseases", system_num: 10, condition_count: 1})
CREATE (s11:BodySystem {name: "Mental Health Disorders", system_num: 11, condition_count: 12})
CREATE (s12:BodySystem {name: "Musculoskeletal conditions", system_num: 12, condition_count: 18})
CREATE (s13:BodySystem {name: "Diseases of the Nervous System", system_num: 13, condition_count: 14})
CREATE (s14:BodySystem {name: "Diseases of the Genitourinary System", system_num: 14, condition_count: 16})
CREATE (s15:BodySystem {name: "Skin conditions", system_num: 15, condition_count: 8});

// =============================================================================
// STEP 3: Create Key Diseases (Sample from CPRD 211 conditions)
// =============================================================================

// Cardiovascular diseases
CREATE (d1:Disease {id: 1, name: "Type 2 Diabetes Mellitus", diagnosis_type: "multi", complexity: "HIGH"})
CREATE (d2:Disease {id: 2, name: "Hypertension", diagnosis_type: "multi", complexity: "HIGH"})
CREATE (d3:Disease {id: 3, name: "Heart failure", diagnosis_type: "multi", complexity: "HIGH"})
CREATE (d4:Disease {id: 4, name: "Atrial Fibrillation", diagnosis_type: "single", complexity: "MODERATE"})
CREATE (d5:Disease {id: 5, name: "Myocardial Infarction", diagnosis_type: "single", complexity: "HIGH"})
CREATE (d6:Disease {id: 6, name: "Coronary Heart Disease", diagnosis_type: "multi", complexity: "HIGH"})

// Respiratory diseases
CREATE (d7:Disease {id: 7, name: "COPD", diagnosis_type: "multi", complexity: "MODERATE"})
CREATE (d8:Disease {id: 8, name: "Asthma", diagnosis_type: "multi", complexity: "LOW"})

// Mental health
CREATE (d9:Disease {id: 9, name: "Depression", diagnosis_type: "multi", complexity: "MODERATE"})
CREATE (d10:Disease {id: 10, name: "Anxiety disorders", diagnosis_type: "multi", complexity: "MODERATE"})

// Endocrine
CREATE (d11:Disease {id: 11, name: "Type 1 Diabetes Mellitus", diagnosis_type: "single", complexity: "HIGH"})
CREATE (d12:Disease {id: 12, name: "Obesity", diagnosis_type: "multi", complexity: "MODERATE"})

// Kidney
CREATE (d13:Disease {id: 13, name: "Chronic Kidney Disease", diagnosis_type: "multi", complexity: "HIGH"})

// Complications
CREATE (d14:Disease {id: 14, name: "Diabetic Neuropathy", diagnosis_type: "multi", complexity: "MODERATE"})

// Cancer (sample)
CREATE (d15:Disease {id: 15, name: "Primary Malignancy_Lung", diagnosis_type: "single", complexity: "HIGH"})

// Liver
CREATE (d16:Disease {id: 16, name: "Alcoholic liver disease", diagnosis_type: "single", complexity: "MODERATE"});

// =============================================================================
// STEP 4: Connect Diseases to Body Systems
// =============================================================================

MATCH (d1:Disease {name: "Type 2 Diabetes Mellitus"}), (s:BodySystem {name: "Endocrine Diseases"})
CREATE (d1)-[:AFFECTS_SYSTEM]->(s);

MATCH (d2:Disease {name: "Hypertension"}), (s:BodySystem {name: "Diseases of the Circulatory System"})
CREATE (d2)-[:AFFECTS_SYSTEM]->(s);

MATCH (d3:Disease {name: "Heart failure"}), (s:BodySystem {name: "Diseases of the Circulatory System"})
CREATE (d3)-[:AFFECTS_SYSTEM]->(s);

MATCH (d4:Disease {name: "Atrial Fibrillation"}), (s:BodySystem {name: "Diseases of the Circulatory System"})
CREATE (d4)-[:AFFECTS_SYSTEM]->(s);

MATCH (d5:Disease {name: "Myocardial Infarction"}), (s:BodySystem {name: "Diseases of the Circulatory System"})
CREATE (d5)-[:AFFECTS_SYSTEM]->(s);

MATCH (d6:Disease {name: "Coronary Heart Disease"}), (s:BodySystem {name: "Diseases of the Circulatory System"})
CREATE (d6)-[:AFFECTS_SYSTEM]->(s);

MATCH (d7:Disease {name: "COPD"}), (s:BodySystem {name: "Diseases of the Respiratory System"})
CREATE (d7)-[:AFFECTS_SYSTEM]->(s);

MATCH (d8:Disease {name: "Asthma"}), (s:BodySystem {name: "Diseases of the Respiratory System"})
CREATE (d8)-[:AFFECTS_SYSTEM]->(s);

MATCH (d9:Disease {name: "Depression"}), (s:BodySystem {name: "Mental Health Disorders"})
CREATE (d9)-[:AFFECTS_SYSTEM]->(s);

MATCH (d10:Disease {name: "Anxiety disorders"}), (s:BodySystem {name: "Mental Health Disorders"})
CREATE (d10)-[:AFFECTS_SYSTEM]->(s);

MATCH (d11:Disease {name: "Type 1 Diabetes Mellitus"}), (s:BodySystem {name: "Endocrine Diseases"})
CREATE (d11)-[:AFFECTS_SYSTEM]->(s);

MATCH (d12:Disease {name: "Obesity"}), (s:BodySystem {name: "Endocrine Diseases"})
CREATE (d12)-[:AFFECTS_SYSTEM]->(s);

MATCH (d13:Disease {name: "Chronic Kidney Disease"}), (s:BodySystem {name: "Diseases of the Genitourinary System"})
CREATE (d13)-[:AFFECTS_SYSTEM]->(s);

MATCH (d14:Disease {name: "Diabetic Neuropathy"}), (s:BodySystem {name: "Diseases of the Nervous System"})
CREATE (d14)-[:AFFECTS_SYSTEM]->(s);

MATCH (d15:Disease {name: "Primary Malignancy_Lung"}), (s:BodySystem {name: "Cancers"})
CREATE (d15)-[:AFFECTS_SYSTEM]->(s);

MATCH (d16:Disease {name: "Alcoholic liver disease"}), (s:BodySystem {name: "Diseases of the Digestive System"})
CREATE (d16)-[:AFFECTS_SYSTEM]->(s);

// =============================================================================
// STEP 5: Create Multimorbidity Relationships (GraphRAG Discoveries)
// =============================================================================

// HIGH-STRENGTH RELATIONSHIPS (>80% correlation)
MATCH (d1:Disease {name: "Type 2 Diabetes Mellitus"}), (d2:Disease {name: "Hypertension"})
CREATE (d1)-[:COMMONLY_OCCURS_WITH {strength: 0.85, evidence: "CPRD_study", discovery_method: "GraphRAG"}]->(d2);

MATCH (d1:Disease {name: "Type 2 Diabetes Mellitus"}), (d14:Disease {name: "Diabetic Neuropathy"})
CREATE (d1)-[:LEADS_TO {strength: 0.90, evidence: "Clinical_progression", discovery_method: "GraphRAG"}]->(d14);

MATCH (d2:Disease {name: "Hypertension"}), (d3:Disease {name: "Heart failure"})
CREATE (d2)-[:COMMONLY_OCCURS_WITH {strength: 0.80, evidence: "CPRD_study", discovery_method: "GraphRAG"}]->(d3);

// MODERATE-STRENGTH RELATIONSHIPS (60-80% correlation)
MATCH (d1:Disease {name: "Type 2 Diabetes Mellitus"}), (d3:Disease {name: "Heart failure"})
CREATE (d1)-[:COMMONLY_OCCURS_WITH {strength: 0.65, evidence: "CPRD_study", discovery_method: "GraphRAG"}]->(d3);

MATCH (d1:Disease {name: "Type 2 Diabetes Mellitus"}), (d13:Disease {name: "Chronic Kidney Disease"})
CREATE (d1)-[:COMMONLY_OCCURS_WITH {strength: 0.75, evidence: "CPRD_study", discovery_method: "GraphRAG"}]->(d13);

MATCH (d1:Disease {name: "Type 2 Diabetes Mellitus"}), (d12:Disease {name: "Obesity"})
CREATE (d1)-[:COMMONLY_OCCURS_WITH {strength: 0.70, evidence: "CPRD_study", discovery_method: "GraphRAG"}]->(d12);

MATCH (d2:Disease {name: "Hypertension"}), (d4:Disease {name: "Atrial Fibrillation"})
CREATE (d2)-[:COMMONLY_OCCURS_WITH {strength: 0.60, evidence: "CPRD_study", discovery_method: "GraphRAG"}]->(d4);

MATCH (d5:Disease {name: "Myocardial Infarction"}), (d3:Disease {name: "Heart failure"})
CREATE (d5)-[:LEADS_TO {strength: 0.70, evidence: "Clinical_progression", discovery_method: "GraphRAG"}]->(d3);

MATCH (d6:Disease {name: "Coronary Heart Disease"}), (d5:Disease {name: "Myocardial Infarction"})
CREATE (d6)-[:LEADS_TO {strength: 0.65, evidence: "Clinical_progression", discovery_method: "GraphRAG"}]->(d5);

// CROSS-SYSTEM RELATIONSHIPS
MATCH (d7:Disease {name: "COPD"}), (d3:Disease {name: "Heart failure"})
CREATE (d7)-[:COMMONLY_OCCURS_WITH {strength: 0.45, evidence: "CPRD_study", discovery_method: "GraphRAG"}]->(d3);

MATCH (d7:Disease {name: "COPD"}), (d9:Disease {name: "Depression"})
CREATE (d7)-[:COMMONLY_OCCURS_WITH {strength: 0.55, evidence: "CPRD_study", discovery_method: "GraphRAG"}]->(d9);

MATCH (d9:Disease {name: "Depression"}), (d10:Disease {name: "Anxiety disorders"})
CREATE (d9)-[:COMMONLY_OCCURS_WITH {strength: 0.70, evidence: "CPRD_study", discovery_method: "GraphRAG"}]->(d10);

MATCH (d9:Disease {name: "Depression"}), (d12:Disease {name: "Obesity"})
CREATE (d9)-[:COMMONLY_OCCURS_WITH {strength: 0.40, evidence: "CPRD_study", discovery_method: "GraphRAG"}]->(d12);

// RISK FACTORS
MATCH (d12:Disease {name: "Obesity"}), (d1:Disease {name: "Type 2 Diabetes Mellitus"})
CREATE (d12)-[:INCREASES_RISK_OF {strength: 0.75, evidence: "CPRD_study", discovery_method: "GraphRAG"}]->(d1);

MATCH (d12:Disease {name: "Obesity"}), (d2:Disease {name: "Hypertension"})
CREATE (d12)-[:INCREASES_RISK_OF {strength: 0.65, evidence: "CPRD_study", discovery_method: "GraphRAG"}]->(d2);

// =============================================================================
// STEP 6: Create Cross-System Interaction Patterns
// =============================================================================

MATCH (s1:BodySystem {name: "Diseases of the Circulatory System"}), (s2:BodySystem {name: "Endocrine Diseases"})
CREATE (s1)-[:SYSTEM_INTERACTION {strength: 8.5, type: "HIGH_INTERACTION", discovery_method: "GraphRAG"}]->(s2);

MATCH (s1:BodySystem {name: "Diseases of the Circulatory System"}), (s3:BodySystem {name: "Diseases of the Respiratory System"})
CREATE (s1)-[:SYSTEM_INTERACTION {strength: 6.8, type: "MODERATE_INTERACTION", discovery_method: "GraphRAG"}]->(s3);

MATCH (s2:BodySystem {name: "Endocrine Diseases"}), (s4:BodySystem {name: "Diseases of the Genitourinary System"})
CREATE (s2)-[:SYSTEM_INTERACTION {strength: 7.2, type: "HIGH_INTERACTION", discovery_method: "GraphRAG"}]->(s4);

MATCH (s5:BodySystem {name: "Mental Health Disorders"}), (s1:BodySystem {name: "Diseases of the Circulatory System"})
CREATE (s5)-[:SYSTEM_INTERACTION {strength: 5.1, type: "MODERATE_INTERACTION", discovery_method: "GraphRAG"}]->(s1);

MATCH (s5:BodySystem {name: "Mental Health Disorders"}), (s2:BodySystem {name: "Endocrine Diseases"})
CREATE (s5)-[:SYSTEM_INTERACTION {strength: 6.2, type: "MODERATE_INTERACTION", discovery_method: "GraphRAG"}]->(s2);

// =============================================================================
// STEP 7: Create Sample Patients for Demonstration
// =============================================================================

CREATE (p1:Patient {
    id: "PATIENT_001", 
    age_group: "65-75", 
    complexity: "HIGH",
    condition_count: 3,
    created_at: datetime()
});

CREATE (p2:Patient {
    id: "PATIENT_002", 
    age_group: "55-65", 
    complexity: "MODERATE",
    condition_count: 3,
    created_at: datetime()
});

CREATE (p3:Patient {
    id: "PATIENT_003", 
    age_group: "45-55", 
    complexity: "HIGH",
    condition_count: 4,
    created_at: datetime()
});

// Link patients to their conditions
MATCH (p:Patient {id: "PATIENT_001"}), (d1:Disease {name: "Type 2 Diabetes Mellitus"})
CREATE (p)-[:HAS_CONDITION {diagnosed_at: datetime(), severity: "MODERATE"}]->(d1);

MATCH (p:Patient {id: "PATIENT_001"}), (d2:Disease {name: "Hypertension"})
CREATE (p)-[:HAS_CONDITION {diagnosed_at: datetime(), severity: "MILD"}]->(d2);

MATCH (p:Patient {id: "PATIENT_001"}), (d3:Disease {name: "Heart failure"})
CREATE (p)-[:HAS_CONDITION {diagnosed_at: datetime(), severity: "MODERATE"}]->(d3);

MATCH (p:Patient {id: "PATIENT_002"}), (d7:Disease {name: "COPD"})
CREATE (p)-[:HAS_CONDITION {diagnosed_at: datetime(), severity: "MODERATE"}]->(d7);

MATCH (p:Patient {id: "PATIENT_002"}), (d9:Disease {name: "Depression"})
CREATE (p)-[:HAS_CONDITION {diagnosed_at: datetime(), severity: "MILD"}]->(d9);

MATCH (p:Patient {id: "PATIENT_002"}), (d10:Disease {name: "Anxiety disorders"})
CREATE (p)-[:HAS_CONDITION {diagnosed_at: datetime(), severity: "MODERATE"}]->(d10);

MATCH (p:Patient {id: "PATIENT_003"}), (d12:Disease {name: "Obesity"})
CREATE (p)-[:HAS_CONDITION {diagnosed_at: datetime(), severity: "SEVERE"}]->(d12);

MATCH (p:Patient {id: "PATIENT_003"}), (d1:Disease {name: "Type 2 Diabetes Mellitus"})
CREATE (p)-[:HAS_CONDITION {diagnosed_at: datetime(), severity: "MODERATE"}]->(d1);

MATCH (p:Patient {id: "PATIENT_003"}), (d2:Disease {name: "Hypertension"})
CREATE (p)-[:HAS_CONDITION {diagnosed_at: datetime(), severity: "MILD"}]->(d2);

MATCH (p:Patient {id: "PATIENT_003"}), (d9:Disease {name: "Depression"})
CREATE (p)-[:HAS_CONDITION {diagnosed_at: datetime(), severity: "MODERATE"}]->(d9);

// =============================================================================
// STEP 8: Add Hub Disease Labels (GraphRAG Discovery)
// =============================================================================

MATCH (d:Disease)
OPTIONAL MATCH (d)-[r]->()
WITH d, count(r) as outgoing_relationships
OPTIONAL MATCH (d)<-[r2]-()
WITH d, outgoing_relationships, count(r2) as incoming_relationships
WITH d, outgoing_relationships + incoming_relationships as total_relationships
WHERE total_relationships >= 3
SET d:HubDisease
SET d.relationship_count = total_relationships;

// =============================================================================
// DEMONSTRATION QUERIES - GraphRAG Capabilities
// =============================================================================

// 1. 🎯 Find Hub Diseases (Most Connected Conditions)
MATCH (d:HubDisease)
RETURN d.name as disease, d.relationship_count as connections, d.complexity as complexity_level
ORDER BY d.relationship_count DESC;

// 2. 🔗 High-Strength Multimorbidity Patterns
MATCH (d1:Disease)-[r]->(d2:Disease)
WHERE r.strength > 0.7
RETURN d1.name as primary_condition, 
       type(r) as relationship_type,
       d2.name as secondary_condition, 
       r.strength as correlation_strength,
       r.discovery_method as how_discovered
ORDER BY r.strength DESC;

// 3. 🌐 Cross-System Disease Interactions
MATCH (d1:Disease)-[:AFFECTS_SYSTEM]->(s1:BodySystem)
MATCH (d2:Disease)-[:AFFECTS_SYSTEM]->(s2:BodySystem)
MATCH (d1)-[r]->(d2)
WHERE s1 <> s2
RETURN s1.name as system1, 
       s2.name as system2, 
       count(r) as interaction_count,
       collect(d1.name + " → " + d2.name) as disease_pairs
ORDER BY interaction_count DESC;

// 4. 👥 Patient Risk Analysis
MATCH (p:Patient)-[:HAS_CONDITION]->(d:Disease)
WITH p, collect(d.name) as conditions, count(d) as condition_count
OPTIONAL MATCH (p)-[:HAS_CONDITION]->(d1:Disease)-[r:COMMONLY_OCCURS_WITH|LEADS_TO]->(d2:Disease)
WHERE d2 IN [d IN conditions | d] = false
WITH p, conditions, condition_count, collect(DISTINCT d2.name) as potential_future_conditions
RETURN p.id as patient_id,
       p.complexity as complexity_level,
       condition_count,
       conditions[0..3] as current_conditions,
       potential_future_conditions[0..3] as predicted_risk_conditions
ORDER BY condition_count DESC;

// 5. 🔮 Predictive Insights - Disease Progression Pathways
MATCH (d1:Disease)-[r:LEADS_TO]->(d2:Disease)
RETURN d1.name as current_condition, 
       d2.name as likely_progression, 
       r.strength as probability,
       "Clinical progression pathway" as insight_type
ORDER BY r.strength DESC
UNION
MATCH (d1:Disease)-[r:INCREASES_RISK_OF]->(d2:Disease)
RETURN d1.name as risk_factor, 
       d2.name as potential_outcome, 
       r.strength as risk_level,
       "Risk factor relationship" as insight_type
ORDER BY r.strength DESC;

// 6. 📊 System Burden Analysis
MATCH (s:BodySystem)
OPTIONAL MATCH (s)<-[:AFFECTS_SYSTEM]-(d:Disease)
WITH s, count(d) as disease_count
OPTIONAL MATCH (s)-[si:SYSTEM_INTERACTION]->()
WITH s, disease_count, count(si) as system_interactions
RETURN s.name as body_system,
       disease_count,
       system_interactions,
       CASE 
           WHEN disease_count > 30 THEN "HIGH_BURDEN"
           WHEN disease_count > 15 THEN "MODERATE_BURDEN"
           ELSE "LOW_BURDEN"
       END as burden_level
ORDER BY disease_count DESC;

// 7. 🎯 GraphRAG Discovery Summary
MATCH (d1:Disease)-[r]->(d2:Disease)
WHERE r.discovery_method = "GraphRAG"
WITH type(r) as relationship_type, count(r) as discovery_count
RETURN relationship_type, 
       discovery_count,
       discovery_count * 100.0 / 13 as percentage_of_discoveries
ORDER BY discovery_count DESC;

// =============================================================================
// FINAL STATISTICS
// =============================================================================

// Graph Statistics
MATCH (d:Disease) WITH count(d) as disease_count
MATCH (s:BodySystem) WITH disease_count, count(s) as system_count  
MATCH (p:Patient) WITH disease_count, system_count, count(p) as patient_count
MATCH ()-[r:COMMONLY_OCCURS_WITH|LEADS_TO|INCREASES_RISK_OF]->() 
WITH disease_count, system_count, patient_count, count(r) as relationship_count
MATCH ()-[si:SYSTEM_INTERACTION]->()
WITH disease_count, system_count, patient_count, relationship_count, count(si) as system_interactions
RETURN "📈 KNOWLEDGE GRAPH STATISTICS" as summary,
       disease_count as total_diseases,
       system_count as body_systems,
       patient_count as sample_patients,
       relationship_count as multimorbidity_relationships,
       system_interactions as cross_system_interactions;