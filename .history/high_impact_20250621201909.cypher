// =============================================================================
// HIGH-IMPACT CPRD MULTIMORBIDITY ANALYSIS QUERIES
// Based on 211 validated conditions from Lancet Healthy Longevity publication
// =============================================================================


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

// 🎯 1. DISEASE BURDEN HOTSPOTS - Find the most connected disease clusters
// Shows which conditions are most likely to co-occur (Multimorbidity Hubs)
MATCH (d:Disease)
OPTIONAL MATCH (d)-[r:COMMONLY_OCCURS_WITH|LEADS_TO|INCREASES_RISK_OF]-(other:Disease)
WITH d, count(r) as total_connections, collect(DISTINCT other.name) as connected_diseases
WHERE total_connections >= 3
RETURN d.name as disease_name,
       d.complexity as severity_level,
       total_connections as connection_count,
       connected_diseases[0..5] as top_connected_conditions,
       CASE 
           WHEN total_connections >= 6 THEN "MAJOR_HUB" 
           WHEN total_connections >= 4 THEN "MODERATE_HUB"
           ELSE "MINOR_HUB"
       END as hub_status
ORDER BY total_connections DESC
LIMIT 20;

// 🔥 2. CROSS-SYSTEM CASCADE ANALYSIS - Disease progression across body systems
// Reveals how conditions in one system trigger problems in other systems
MATCH (d1:Disease)-[:AFFECTS_SYSTEM]->(s1:BodySystem)
MATCH (d2:Disease)-[:AFFECTS_SYSTEM]->(s2:BodySystem)
MATCH (d1)-[r:LEADS_TO|COMMONLY_OCCURS_WITH]->(d2)
WHERE s1.name <> s2.name AND r.strength >= 0.6
WITH s1, s2, count(r) as cascade_strength, 
     collect({primary: d1.name, secondary: d2.name, strength: r.strength}) as disease_cascades
WHERE cascade_strength >= 2
RETURN s1.name as origin_system,
       s2.name as target_system, 
       cascade_strength as total_cascades,
       disease_cascades[0..3] as top_disease_progressions,
       round(avg([cascade IN disease_cascades | cascade.strength]) * 100) as avg_correlation_percentage
ORDER BY cascade_strength DESC;

// 💊 3. COMPLEX MULTIMORBIDITY PATTERNS - Patients with 3+ conditions across 3+ systems
// Identifies the most challenging clinical cases requiring coordinated care
MATCH (p:Patient)-[:HAS_CONDITION]->(d:Disease)-[:AFFECTS_SYSTEM]->(s:BodySystem)
WITH p, count(DISTINCT d) as condition_count, count(DISTINCT s) as system_count, 
     collect(DISTINCT d.name) as all_conditions, collect(DISTINCT s.name) as affected_systems
WHERE condition_count >= 3 AND system_count >= 3
// Find potential future risks for these complex patients
OPTIONAL MATCH (p)-[:HAS_CONDITION]->(current:Disease)-[r:LEADS_TO|COMMONLY_OCCURS_WITH]->(future:Disease)
WHERE NOT future.name IN all_conditions AND r.strength >= 0.6
WITH p, condition_count, system_count, all_conditions, affected_systems,
     collect(DISTINCT {condition: future.name, risk_level: r.strength}) as predicted_risks
RETURN p.id as patient_id,
       p.age_group as age_range,
       condition_count as total_conditions,
       system_count as systems_affected,
       all_conditions as current_diagnoses,
       affected_systems as body_systems_involved,
       predicted_risks[0..3] as top_future_risks,
       CASE 
           WHEN condition_count >= 5 THEN "EXTREMELY_COMPLEX"
           WHEN condition_count = 4 THEN "HIGHLY_COMPLEX" 
           ELSE "MODERATELY_COMPLEX"
       END as complexity_classification
ORDER BY condition_count DESC, system_count DESC;

// 🚨 4. HIGH-RISK PROGRESSION PATHWAYS - Critical disease trajectories  
// Identifies dangerous progression paths with high clinical impact
MATCH path = (start:Disease)-[r1:LEADS_TO]->(middle:Disease)-[r2:LEADS_TO]->(end:Disease)
WHERE r1.strength >= 0.65 AND r2.strength >= 0.65
MATCH (start)-[:AFFECTS_SYSTEM]->(s1:BodySystem)
MATCH (middle)-[:AFFECTS_SYSTEM]->(s2:BodySystem) 
MATCH (end)-[:AFFECTS_SYSTEM]->(s3:BodySystem)
RETURN start.name as initial_condition,
       middle.name as intermediate_stage,
       end.name as final_outcome,
       s1.name + " → " + s2.name + " → " + s3.name as system_progression,
       round((r1.strength + r2.strength) / 2 * 100) as overall_progression_risk,
       length(path) as pathway_length,
       "HIGH_RISK_TRAJECTORY" as pathway_type
ORDER BY (r1.strength + r2.strength) DESC
LIMIT 15;

// 📊 5. SYSTEM VULNERABILITY ANALYSIS - Which body systems are most at risk
// Shows system-level burden and interconnectedness for healthcare planning
MATCH (s:BodySystem)
OPTIONAL MATCH (s)<-[:AFFECTS_SYSTEM]-(d:Disease)
WITH s, count(d) as disease_burden, collect(d.name) as system_diseases

// Count incoming risk relationships (diseases that can affect this system)
OPTIONAL MATCH (external:Disease)-[:AFFECTS_SYSTEM]->(other_system:BodySystem)
OPTIONAL MATCH (external)-[r:LEADS_TO|COMMONLY_OCCURS_WITH]->(internal:Disease)-[:AFFECTS_SYSTEM]->(s)
WHERE other_system <> s AND r.strength >= 0.5
WITH s, disease_burden, system_diseases, count(DISTINCT r) as external_risk_factors

// Count outgoing risk relationships (how this system affects others)
OPTIONAL MATCH (s)<-[:AFFECTS_SYSTEM]-(internal2:Disease)-[r2:LEADS_TO|COMMONLY_OCCURS_WITH]->(external2:Disease)
OPTIONAL MATCH (external2)-[:AFFECTS_SYSTEM]->(target_system:BodySystem)
WHERE target_system <> s AND r2.strength >= 0.5
WITH s, disease_burden, system_diseases, external_risk_factors, count(DISTINCT r2) as external_impact_factors

RETURN s.name as body_system,
       disease_burden as total_conditions,
       external_risk_factors as incoming_risks,
       external_impact_factors as outgoing_risks,
       external_risk_factors + external_impact_factors as total_system_interactions,
       system_diseases[0..8] as sample_conditions,
       CASE 
           WHEN disease_burden >= 25 THEN "CRITICAL_BURDEN"
           WHEN disease_burden >= 15 THEN "HIGH_BURDEN"
           WHEN disease_burden >= 8 THEN "MODERATE_BURDEN"
           ELSE "LOW_BURDEN"
       END as burden_classification,
       CASE 
           WHEN external_risk_factors + external_impact_factors >= 8 THEN "HIGHLY_INTERCONNECTED"
           WHEN external_risk_factors + external_impact_factors >= 4 THEN "MODERATELY_INTERCONNECTED"
           ELSE "ISOLATED_SYSTEM"
       END as connectivity_status
ORDER BY total_system_interactions DESC, disease_burden DESC;

// 🎯 6. PRECISION MEDICINE INSIGHTS - Personalized risk prediction
// For each patient, predict their highest risk future conditions
MATCH (p:Patient)-[:HAS_CONDITION]->(current:Disease)
WITH p, collect(current.name) as existing_conditions

// Find all potential future conditions with risk scores
MATCH (p)-[:HAS_CONDITION]->(d1:Disease)-[r:LEADS_TO|COMMONLY_OCCURS_WITH|INCREASES_RISK_OF]->(future:Disease)
WHERE NOT future.name IN existing_conditions

// Calculate composite risk scores
WITH p, existing_conditions, future,
     collect({relationship_type: type(r), strength: r.strength, source: d1.name}) as risk_sources,
     avg(r.strength) as avg_risk_score,
     count(r) as risk_pathway_count

// Only show significant risks
WHERE avg_risk_score >= 0.4 AND risk_pathway_count >= 1

RETURN p.id as patient_id,
       p.age_group as age_range,
       existing_conditions as current_conditions,
       future.name as predicted_condition,
       round(avg_risk_score * 100) as risk_percentage,
       risk_pathway_count as supporting_pathways,
       risk_sources[0..3] as risk_evidence,
       CASE 
           WHEN avg_risk_score >= 0.7 THEN "HIGH_RISK"
           WHEN avg_risk_score >= 0.5 THEN "MODERATE_RISK"
           ELSE "LOW_RISK"
       END as risk_category
ORDER BY p.id, avg_risk_score DESC;

// 🔬 7. MULTIMORBIDITY CLUSTER DISCOVERY - Find hidden disease patterns
// Discovers groups of conditions that frequently occur together
MATCH (d1:Disease)-[r1:COMMONLY_OCCURS_WITH]->(d2:Disease)-[r2:COMMONLY_OCCURS_WITH]->(d3:Disease)
WHERE r1.strength >= 0.6 AND r2.strength >= 0.6 AND d1 <> d3

// Optional: check if d1 and d3 are also directly connected
OPTIONAL MATCH (d1)-[r3:COMMONLY_OCCURS_WITH]->(d3)

// Get body systems for cluster analysis
MATCH (d1)-[:AFFECTS_SYSTEM]->(s1:BodySystem)
MATCH (d2)-[:AFFECTS_SYSTEM]->(s2:BodySystem)  
MATCH (d3)-[:AFFECTS_SYSTEM]->(s3:BodySystem)

WITH [d1.name, d2.name, d3.name] as disease_cluster,
     [s1.name, s2.name, s3.name] as system_cluster,
     round((r1.strength + r2.strength + coalesce(r3.strength, 0)) / 
           CASE WHEN r3 IS NOT NULL THEN 3 ELSE 2 END * 100) as cluster_strength,
     CASE WHEN r3 IS NOT NULL THEN "TRIANGULAR" ELSE "LINEAR" END as cluster_type,
     size(apoc.coll.toSet([s1.name, s2.name, s3.name])) as unique_systems

WHERE cluster_strength >= 65

RETURN disease_cluster,
       system_cluster,
       cluster_strength as correlation_strength_percent,
       cluster_type,
       unique_systems as systems_involved,
       CASE 
           WHEN unique_systems = 1 THEN "SINGLE_SYSTEM_CLUSTER"
           WHEN unique_systems = 2 THEN "DUAL_SYSTEM_CLUSTER"  
           ELSE "MULTI_SYSTEM_CLUSTER"
       END as cluster_complexity
ORDER BY cluster_strength DESC, unique_systems DESC
LIMIT 25;

// 🏥 8. HEALTHCARE RESOURCE IMPACT ANALYSIS - Clinical workload prediction
// Estimates the healthcare burden based on multimorbidity patterns
MATCH (p:Patient)-[:HAS_CONDITION]->(d:Disease)
WITH p, 
     count(d) as condition_count,
     collect(d.complexity) as complexity_levels,
     collect(d.name) as patient_conditions

// Calculate complexity score based on conditions
WITH p, condition_count, patient_conditions,
     size([c IN complexity_levels WHERE c = "HIGH"]) as high_complexity_count,
     size([c IN complexity_levels WHERE c = "MODERATE"]) as moderate_complexity_count,
     size([c IN complexity_levels WHERE c = "LOW"]) as low_complexity_count

// Estimate healthcare resource needs
WITH p, condition_count, patient_conditions, 
     (high_complexity_count * 3 + moderate_complexity_count * 2 + low_complexity_count * 1) as complexity_score,
     CASE 
         WHEN condition_count = 1 THEN 1.0
         WHEN condition_count = 2 THEN 1.8  
         WHEN condition_count = 3 THEN 2.9
         WHEN condition_count = 4 THEN 4.2
         ELSE condition_count * 1.3
     END as multimorbidity_multiplier

RETURN p.id as patient_id,
       p.age_group as age_range,
       condition_count as total_conditions,
       patient_conditions as diagnoses,
       complexity_score as condition_complexity_score,
       round(complexity_score * multimorbidity_multiplier, 1) as estimated_care_burden_score,
       CASE 
           WHEN complexity_score * multimorbidity_multiplier >= 12 THEN "VERY_HIGH_RESOURCE"
           WHEN complexity_score * multimorbidity_multiplier >= 8 THEN "HIGH_RESOURCE"
           WHEN complexity_score * multimorbidity_multiplier >= 4 THEN "MODERATE_RESOURCE"
           ELSE "LOW_RESOURCE"
       END as resource_category,
       round(complexity_score * multimorbidity_multiplier * 150) as estimated_annual_cost_pounds
ORDER BY complexity_score * multimorbidity_multiplier DESC;

// 🌟 9. BREAKTHROUGH DISCOVERY SUMMARY - GraphRAG insights overview
// Summarizes the key discoveries made by the GraphRAG system
MATCH (d1:Disease)-[r]->(d2:Disease)
WHERE r.discovery_method = "GraphRAG"
WITH type(r) as relationship_type, 
     count(r) as discovery_count,
     avg(r.strength) as avg_strength,
     collect({from: d1.name, to: d2.name, strength: r.strength}) as discoveries

RETURN relationship_type as discovery_type,
       discovery_count as total_discoveries,
       round(avg_strength * 100) as average_correlation_percent,
       discoveries[0..5] as sample_discoveries,
       round(discovery_count * 100.0 / 13) as percentage_of_total_relationships
ORDER BY discovery_count DESC;