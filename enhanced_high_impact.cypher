// =============================================================================
// ENHANCED HIGH-IMPACT CPRD MULTIMORBIDITY ANALYSIS QUERIES
// Optimized for performance, clinical insight, and statistical rigor
// Based on 211 validated conditions from Lancet Healthy Longevity publication
// =============================================================================

// 📋 PERFORMANCE SETUP - Create indexes for faster queries
CREATE INDEX disease_name_index IF NOT EXISTS FOR (d:Disease) ON (d.name);
CREATE INDEX disease_complexity_index IF NOT EXISTS FOR (d:Disease) ON (d.complexity);
CREATE INDEX system_name_index IF NOT EXISTS FOR (s:BodySystem) ON (s.name);
CREATE INDEX patient_age_index IF NOT EXISTS FOR (p:Patient) ON (p.age_group);

// Create separate indexes for each relationship type (Neo4j limitation)
CREATE INDEX commonly_occurs_strength_index IF NOT EXISTS FOR ()-[r:COMMONLY_OCCURS_WITH]-() ON (r.strength);
CREATE INDEX leads_to_strength_index IF NOT EXISTS FOR ()-[r:LEADS_TO]-() ON (r.strength);
CREATE INDEX increases_risk_strength_index IF NOT EXISTS FOR ()-[r:INCREASES_RISK_OF]-() ON (r.strength);

// 🎯 1. ENHANCED DISEASE BURDEN HOTSPOTS - Most connected disease clusters with statistical validation
// Includes confidence intervals and network centrality measures
MATCH (d:Disease)
OPTIONAL MATCH (d)-[r:COMMONLY_OCCURS_WITH|LEADS_TO|INCREASES_RISK_OF]-(other:Disease)
WITH d, 
     count(r) as total_connections, 
     collect(DISTINCT {disease: other.name, strength: r.strength, type: type(r)}) as connections,
     avg(r.strength) as avg_connection_strength,
     stdev(r.strength) as strength_std_dev
WHERE total_connections >= 3

// Calculate network centrality score and prepare CI components
WITH d, total_connections, connections, avg_connection_strength, strength_std_dev,
     total_connections * avg_connection_strength as centrality_score,
     // Pre-calculate CI components to avoid nested aggregation
     1.96 * strength_std_dev as ci_margin_base,
     toFloat(total_connections) as sample_size

// Calculate confidence intervals in separate step
WITH d, total_connections, connections, avg_connection_strength, strength_std_dev, centrality_score,
     avg_connection_strength - (ci_margin_base / sqrt(sample_size)) as ci_lower,
     avg_connection_strength + (ci_margin_base / sqrt(sample_size)) as ci_upper

RETURN d.name as disease_name,
       d.complexity as severity_level,
       total_connections as connection_count,
       round(avg_connection_strength * 100, 1) + "%" as avg_correlation,
       round(centrality_score * 100, 1) as network_centrality_score,
       round(ci_lower * 100, 1) + "% - " + round(ci_upper * 100, 1) + "%" as confidence_interval_95,
       [conn IN connections WHERE conn.strength >= 0.7 | conn.disease][0..5] as strongest_connections,
       CASE 
           WHEN centrality_score >= 5.0 THEN "CRITICAL_HUB" 
           WHEN centrality_score >= 3.0 THEN "MAJOR_HUB" 
           WHEN centrality_score >= 2.0 THEN "MODERATE_HUB"
           ELSE "MINOR_HUB"
       END as hub_status,
       CASE 
           WHEN strength_std_dev < 0.1 THEN "CONSISTENT"
           WHEN strength_std_dev < 0.2 THEN "MODERATE_VARIATION"
           ELSE "HIGH_VARIATION"
       END as connection_consistency
ORDER BY centrality_score DESC
LIMIT 25;

// 🔥 2. ADVANCED CROSS-SYSTEM CASCADE ANALYSIS - Multi-hop disease progression
// Enhanced to detect cascade chains and system vulnerability patterns
MATCH cascade_path = (d1:Disease)-[:AFFECTS_SYSTEM]->(s1:BodySystem),
                     (d1)-[r1:LEADS_TO|COMMONLY_OCCURS_WITH]->(d2:Disease)-[:AFFECTS_SYSTEM]->(s2:BodySystem)
WHERE s1.name <> s2.name AND r1.strength >= 0.5

// Look for extended cascades (3-hop)
OPTIONAL MATCH extended_path = (d2)-[r2:LEADS_TO|COMMONLY_OCCURS_WITH]->(d3:Disease)-[:AFFECTS_SYSTEM]->(s3:BodySystem)
WHERE s2.name <> s3.name AND r2.strength >= 0.5

WITH s1, s2, s3,
     count(DISTINCT d1) as origin_diseases,
     count(DISTINCT d2) as intermediate_diseases,
     count(DISTINCT d3) as terminal_diseases,
     avg(r1.strength) as avg_primary_strength,
     avg(r2.strength) as avg_secondary_strength,
     collect(DISTINCT {
         primary: d1.name, 
         intermediate: d2.name, 
         terminal: d3.name,
         primary_strength: r1.strength,
         secondary_strength: r2.strength,
         total_cascade_strength: r1.strength * coalesce(r2.strength, 1.0)
     }) as cascade_details

WHERE origin_diseases >= 2

RETURN s1.name as origin_system,
       s2.name as primary_target_system,
       coalesce(s3.name, "N/A") as secondary_target_system,
       origin_diseases + intermediate_diseases + coalesce(terminal_diseases, 0) as total_diseases_involved,
       round(avg_primary_strength * 100, 1) + "%" as avg_primary_cascade_strength,
       round(coalesce(avg_secondary_strength, 0) * 100, 1) + "%" as avg_secondary_cascade_strength,
       cascade_details[0..3] as sample_cascade_pathways,
       CASE 
           WHEN avg_primary_strength >= 0.8 THEN "VERY_HIGH_RISK"
           WHEN avg_primary_strength >= 0.6 THEN "HIGH_RISK"
           WHEN avg_primary_strength >= 0.4 THEN "MODERATE_RISK"
           ELSE "LOW_RISK"
       END as cascade_risk_level,
       CASE 
           WHEN s3 IS NOT NULL THEN "MULTI_HOP_CASCADE"
           ELSE "SINGLE_HOP_CASCADE"
       END as cascade_type
ORDER BY avg_primary_strength DESC, origin_diseases DESC;

// 💊 3. PRECISION MULTIMORBIDITY STRATIFICATION - Advanced patient risk profiling
// Enhanced with predictive modeling and personalized risk scores
MATCH (p:Patient)-[:HAS_CONDITION]->(d:Disease)-[:AFFECTS_SYSTEM]->(s:BodySystem)
WITH p, 
     count(DISTINCT d) as condition_count, 
     count(DISTINCT s) as system_count,
     collect(DISTINCT d.name) as current_conditions,
     collect(DISTINCT s.name) as affected_systems,
     avg(CASE d.complexity WHEN "HIGH" THEN 3 WHEN "MODERATE" THEN 2 ELSE 1 END) as avg_complexity

WHERE condition_count >= 2

// Calculate comprehensive risk prediction
MATCH (p)-[:HAS_CONDITION]->(current:Disease)
OPTIONAL MATCH (current)-[r:LEADS_TO|COMMONLY_OCCURS_WITH|INCREASES_RISK_OF]->(future:Disease)
WHERE NOT future.name IN current_conditions AND r.strength >= 0.4

WITH p, condition_count, system_count, current_conditions, affected_systems, avg_complexity,
     collect(DISTINCT {
         condition: future.name, 
         risk_score: r.strength,
         evidence_strength: r.strength * count(r),
         source: current.name
     }) as potential_risks

// Calculate patient complexity index
WITH p, condition_count, system_count, current_conditions, affected_systems, potential_risks,
     condition_count * 2.0 + system_count * 1.5 + avg_complexity * 3.0 as complexity_index,
     size([risk IN potential_risks WHERE risk.risk_score >= 0.7]) as high_risk_predictions,
     size([risk IN potential_risks WHERE risk.risk_score >= 0.5]) as moderate_risk_predictions

RETURN p.id as patient_id,
       p.age_group as age_range,
       condition_count as total_conditions,
       system_count as systems_affected,
       round(complexity_index, 1) as patient_complexity_index,
       current_conditions as current_diagnoses,
       affected_systems as body_systems_involved,
       high_risk_predictions as high_risk_future_conditions,
       moderate_risk_predictions as moderate_risk_future_conditions,
       [risk IN potential_risks WHERE risk.risk_score >= 0.6 | 
        risk.condition + " (" + round(risk.risk_score * 100) + "%)"][0..5] as top_predicted_risks,
       CASE 
           WHEN complexity_index >= 15 THEN "EXTREME_COMPLEXITY"
           WHEN complexity_index >= 10 THEN "HIGH_COMPLEXITY"
           WHEN complexity_index >= 6 THEN "MODERATE_COMPLEXITY"
           ELSE "LOW_COMPLEXITY"
       END as complexity_tier,
       CASE 
           WHEN high_risk_predictions >= 3 THEN "CRITICAL_MONITORING"
           WHEN high_risk_predictions >= 1 THEN "ENHANCED_MONITORING"
           ELSE "STANDARD_MONITORING"
       END as recommended_care_level
ORDER BY complexity_index DESC, high_risk_predictions DESC;

// 🚨 4. CRITICAL PATHWAY RISK ASSESSMENT - Multi-step progression analysis
// Enhanced with pathway probability and intervention windows
MATCH critical_path = (start:Disease)-[r1:LEADS_TO]->(middle:Disease)-[r2:LEADS_TO]->(end:Disease)
WHERE r1.strength >= 0.6 AND r2.strength >= 0.6

// Get system involvement
MATCH (start)-[:AFFECTS_SYSTEM]->(s1:BodySystem)
MATCH (middle)-[:AFFECTS_SYSTEM]->(s2:BodySystem) 
MATCH (end)-[:AFFECTS_SYSTEM]->(s3:BodySystem)

// Calculate time-based progression estimates (if available)
WITH start, middle, end, r1, r2, s1, s2, s3,
     r1.strength * r2.strength as compound_progression_risk,
     CASE 
         WHEN s1 = s2 AND s2 = s3 THEN "SAME_SYSTEM"
         WHEN s1 = s2 OR s2 = s3 THEN "PARTIAL_SYSTEM_SPREAD"
         ELSE "MULTI_SYSTEM_SPREAD"
     END as spread_pattern

// Add intervention urgency scoring
WITH start, middle, end, s1, s2, s3, compound_progression_risk, spread_pattern,
     r1.strength, r2.strength,
     CASE 
         WHEN compound_progression_risk >= 0.64 THEN "IMMEDIATE_INTERVENTION"
         WHEN compound_progression_risk >= 0.36 THEN "URGENT_INTERVENTION"
         WHEN compound_progression_risk >= 0.25 THEN "PLANNED_INTERVENTION"
         ELSE "ROUTINE_MONITORING"
     END as intervention_urgency

RETURN start.name as initial_condition,
       middle.name as intermediate_stage,
       end.name as final_outcome,
       s1.name + " → " + s2.name + " → " + s3.name as system_progression,
       round(r1.strength * 100, 1) + "%" as stage_1_risk,
       round(r2.strength * 100, 1) + "%" as stage_2_risk,
       round(compound_progression_risk * 100, 1) + "%" as overall_progression_probability,
       spread_pattern as disease_spread_pattern,
       intervention_urgency as clinical_priority,
       CASE 
           WHEN r1.strength > r2.strength THEN "EARLY_INTERVENTION_CRITICAL"
           WHEN r2.strength > r1.strength THEN "LATE_INTERVENTION_POSSIBLE"
           ELSE "CONSISTENT_PROGRESSION"
       END as intervention_window,
       round((1 - compound_progression_risk) * 100, 1) + "%" as prevention_opportunity
ORDER BY compound_progression_risk DESC
LIMIT 20;

// 📊 5. ENHANCED SYSTEM VULNERABILITY MATRIX - Comprehensive system analysis
// Includes network analysis and resource allocation insights
MATCH (s:BodySystem)
OPTIONAL MATCH (s)<-[:AFFECTS_SYSTEM]-(d:Disease)

WITH s, 
     count(d) as disease_burden, 
     collect(d.name) as system_diseases,
     collect(d.complexity) as disease_complexities

// Calculate system vulnerability metrics
WITH s, disease_burden, system_diseases,
     size([complexity IN disease_complexities WHERE complexity = "HIGH"]) as high_complexity_diseases,
     size([complexity IN disease_complexities WHERE complexity = "MODERATE"]) as moderate_complexity_diseases,
     disease_burden * 1.0 + high_complexity_diseases * 2.0 + moderate_complexity_diseases * 1.0 as system_burden_score

// Network connectivity analysis
OPTIONAL MATCH (s)<-[:AFFECTS_SYSTEM]-(internal:Disease)-[r_out:LEADS_TO|COMMONLY_OCCURS_WITH]->(external:Disease)-[:AFFECTS_SYSTEM]->(target:BodySystem)
WHERE target <> s AND r_out.strength >= 0.5
WITH s, disease_burden, system_diseases, system_burden_score, high_complexity_diseases,
     count(DISTINCT r_out) as outgoing_connections,
     avg(r_out.strength) as avg_outgoing_strength

OPTIONAL MATCH (source:BodySystem)<-[:AFFECTS_SYSTEM]-(external2:Disease)-[r_in:LEADS_TO|COMMONLY_OCCURS_WITH]->(internal2:Disease)-[:AFFECTS_SYSTEM]->(s)
WHERE source <> s AND r_in.strength >= 0.5
WITH s, disease_burden, system_diseases, system_burden_score, high_complexity_diseases,
     outgoing_connections, avg_outgoing_strength,
     count(DISTINCT r_in) as incoming_connections,
     avg(r_in.strength) as avg_incoming_strength

// Calculate network centrality and vulnerability scores
WITH s, disease_burden, system_diseases, system_burden_score, high_complexity_diseases,
     outgoing_connections, incoming_connections,
     coalesce(avg_outgoing_strength, 0) as avg_out_strength,
     coalesce(avg_incoming_strength, 0) as avg_in_strength,
     outgoing_connections + incoming_connections as total_connections,
     (outgoing_connections * coalesce(avg_outgoing_strength, 0) + 
      incoming_connections * coalesce(avg_incoming_strength, 0)) as network_influence_score

RETURN s.name as body_system,
       disease_burden as total_conditions,
       high_complexity_diseases as critical_conditions,
       round(system_burden_score, 1) as system_burden_score,
       incoming_connections as vulnerability_pathways,
       outgoing_connections as impact_pathways,
       total_connections as total_system_interactions,
       round(avg_in_strength * 100, 1) + "%" as avg_incoming_risk,
       round(avg_out_strength * 100, 1) + "%" as avg_outgoing_risk,
       round(network_influence_score * 100, 1) as network_influence_score,
       system_diseases[0..6] as sample_conditions,
       CASE 
           WHEN system_burden_score >= 40 THEN "CRITICAL_SYSTEM"
           WHEN system_burden_score >= 25 THEN "HIGH_BURDEN_SYSTEM"
           WHEN system_burden_score >= 15 THEN "MODERATE_BURDEN_SYSTEM"
           ELSE "LOW_BURDEN_SYSTEM"
       END as burden_classification,
       CASE 
           WHEN total_connections >= 12 THEN "HIGHLY_CONNECTED_HUB"
           WHEN total_connections >= 6 THEN "MODERATELY_CONNECTED"
           WHEN total_connections >= 2 THEN "MINIMALLY_CONNECTED"
           ELSE "ISOLATED_SYSTEM"
       END as connectivity_status,
       CASE 
           WHEN network_influence_score >= 8.0 THEN "HIGH_INFLUENCE"
           WHEN network_influence_score >= 4.0 THEN "MODERATE_INFLUENCE"
           ELSE "LOW_INFLUENCE"
       END as system_influence_level
ORDER BY network_influence_score DESC, system_burden_score DESC;

// 🎯 6. ADVANCED PRECISION MEDICINE INSIGHTS - ML-ready risk prediction
// Enhanced with feature engineering for machine learning models
MATCH (p:Patient)-[:HAS_CONDITION]->(current:Disease)
WITH p, 
     collect(current.name) as existing_conditions,
     collect(current.complexity) as condition_complexities,
     count(current) as condition_count

// Multi-source risk aggregation
MATCH (p)-[:HAS_CONDITION]->(d1:Disease)-[r:LEADS_TO|COMMONLY_OCCURS_WITH|INCREASES_RISK_OF]->(future:Disease)
WHERE NOT future.name IN existing_conditions

// Feature engineering for ML models
WITH p, existing_conditions, condition_complexities, condition_count, future,
     collect({
         relationship_type: type(r), 
         strength: r.strength, 
         source: d1.name,
         source_complexity: d1.complexity
     }) as risk_sources,
     count(r) as evidence_count,
     avg(r.strength) as mean_risk_score,
     stdev(r.strength) as risk_variance,
     max(r.strength) as max_risk_score,
     min(r.strength) as min_risk_score

// Advanced risk calculations with confidence metrics - Step 1
WITH p, existing_conditions, future, risk_sources, evidence_count,
     mean_risk_score, risk_variance, max_risk_score, min_risk_score,
     // Weighted risk score (more evidence = higher confidence)
     mean_risk_score * (1 + log(evidence_count)) as weighted_risk_score,
     // Risk consistency score
     1 - (coalesce(risk_variance, 0) / (mean_risk_score + 0.01)) as consistency_score,
     // Pre-calculate CI components
     1.96 * coalesce(risk_variance, 0) as ci_margin_base,
     toFloat(evidence_count) as sample_size

// Calculate confidence intervals in separate step
WITH p, existing_conditions, future, risk_sources, evidence_count,
     mean_risk_score, weighted_risk_score, consistency_score,
     mean_risk_score - (ci_margin_base / sqrt(sample_size)) as ci_lower,
     mean_risk_score + (ci_margin_base / sqrt(sample_size)) as ci_upper

WHERE mean_risk_score >= 0.3 AND evidence_count >= 1

RETURN p.id as patient_id,
       p.age_group as age_range,
       existing_conditions as current_conditions,
       future.name as predicted_condition,
       future.complexity as predicted_severity,
       evidence_count as supporting_evidence,
       round(mean_risk_score * 100, 1) as base_risk_percentage,
       round(weighted_risk_score * 100, 1) as weighted_risk_percentage,
       round(consistency_score * 100, 1) as prediction_confidence,
       round(ci_lower * 100, 1) + "% - " + round(ci_upper * 100, 1) + "%" as confidence_interval,
       [source IN risk_sources | source.source + " (" + round(source.strength * 100) + "%)"][0..3] as evidence_sources,
       CASE 
           WHEN weighted_risk_score >= 0.8 THEN "VERY_HIGH_RISK"
           WHEN weighted_risk_score >= 0.6 THEN "HIGH_RISK"
           WHEN weighted_risk_score >= 0.4 THEN "MODERATE_RISK"
           ELSE "LOW_RISK"
       END as risk_category,
       CASE 
           WHEN consistency_score >= 0.8 THEN "HIGH_CONFIDENCE"
           WHEN consistency_score >= 0.6 THEN "MODERATE_CONFIDENCE"
           ELSE "LOW_CONFIDENCE"
       END as prediction_reliability
ORDER BY p.id, weighted_risk_score DESC;

// 🔬 7. SOPHISTICATED MULTIMORBIDITY CLUSTER ANALYSIS - Network-based discovery
// Enhanced with community detection and cluster stability metrics
MATCH cluster_path = (d1:Disease)-[r1:COMMONLY_OCCURS_WITH]->(d2:Disease)-[r2:COMMONLY_OCCURS_WITH]->(d3:Disease)
WHERE r1.strength >= 0.6 AND r2.strength >= 0.6 AND d1 <> d3

// Check for triangular closure (stronger clusters)
OPTIONAL MATCH (d1)-[r3:COMMONLY_OCCURS_WITH]->(d3)

// Extended cluster detection (4-node clusters)
OPTIONAL MATCH (d3)-[r4:COMMONLY_OCCURS_WITH]->(d4:Disease)
WHERE r4.strength >= 0.6 AND d4 <> d1 AND d4 <> d2

// System diversity analysis
MATCH (d1)-[:AFFECTS_SYSTEM]->(s1:BodySystem)
MATCH (d2)-[:AFFECTS_SYSTEM]->(s2:BodySystem)  
MATCH (d3)-[:AFFECTS_SYSTEM]->(s3:BodySystem)
OPTIONAL MATCH (d4)-[:AFFECTS_SYSTEM]->(s4:BodySystem)

WITH d1, d2, d3, d4, r1, r2, r3, r4,
     [d1.name, d2.name, d3.name] + CASE WHEN d4 IS NOT NULL THEN [d4.name] ELSE [] END as disease_cluster,
     [s1.name, s2.name, s3.name] + CASE WHEN s4 IS NOT NULL THEN [s4.name] ELSE [] END as system_cluster,
     // Cluster strength calculation
     (r1.strength + r2.strength + coalesce(r3.strength, 0) + coalesce(r4.strength, 0)) / 
     (2 + CASE WHEN r3 IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN r4 IS NOT NULL THEN 1 ELSE 0 END) as avg_cluster_strength,
     // Cluster completeness (how many possible connections exist)
     (CASE WHEN r3 IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN r4 IS NOT NULL THEN 1 ELSE 0 END) as optional_connections,
     CASE 
         WHEN r3 IS NOT NULL AND r4 IS NOT NULL THEN "EXTENDED_TRIANGULAR"
         WHEN r3 IS NOT NULL THEN "TRIANGULAR" 
         WHEN r4 IS NOT NULL THEN "EXTENDED_LINEAR"
         ELSE "LINEAR" 
     END as cluster_topology

// System diversity metrics
WITH disease_cluster, system_cluster, avg_cluster_strength, cluster_topology, optional_connections,
     size(apoc.coll.toSet(system_cluster)) as unique_systems_count,
     size(disease_cluster) as cluster_size

// Filter for significant clusters
WHERE avg_cluster_strength >= 0.65 AND cluster_size >= 3

// Cluster stability scoring
WITH disease_cluster, system_cluster, avg_cluster_strength, cluster_topology, 
     unique_systems_count, cluster_size,
     // Stability score: higher for triangular clusters and system diversity
     avg_cluster_strength * 
     (1 + CASE cluster_topology WHEN "TRIANGULAR" THEN 0.3 WHEN "EXTENDED_TRIANGULAR" THEN 0.5 ELSE 0 END) *
     (1 + unique_systems_count * 0.2) as stability_score

RETURN disease_cluster,
       system_cluster,
       cluster_size as diseases_in_cluster,
       round(avg_cluster_strength * 100, 1) + "%" as cluster_correlation_strength,
       cluster_topology as cluster_structure,
       unique_systems_count as systems_involved,
       round(stability_score * 100, 1) as cluster_stability_score,
       CASE 
           WHEN unique_systems_count = 1 THEN "SINGLE_SYSTEM_SYNDROME"
           WHEN unique_systems_count = 2 THEN "DUAL_SYSTEM_INTERACTION"  
           WHEN unique_systems_count >= 3 THEN "MULTI_SYSTEM_COMPLEX"
           ELSE "UNCLASSIFIED"
       END as clinical_pattern_type,
       CASE 
           WHEN stability_score >= 0.9 THEN "HIGHLY_STABLE_CLUSTER"
           WHEN stability_score >= 0.7 THEN "MODERATELY_STABLE_CLUSTER"
           ELSE "EMERGING_CLUSTER"
       END as cluster_reliability
ORDER BY stability_score DESC, cluster_size DESC
LIMIT 30;

// 🏥 8. COMPREHENSIVE HEALTHCARE RESOURCE OPTIMIZATION - Advanced burden modeling
// Enhanced with cost-effectiveness and resource allocation insights
MATCH (p:Patient)-[:HAS_CONDITION]->(d:Disease)

// Enhanced complexity scoring with interaction effects
WITH p, 
     count(d) as condition_count,
     collect(d.complexity) as complexity_levels,
     collect(d.name) as patient_conditions,
     collect(DISTINCT d) as patient_diseases

// Calculate disease interaction complexity
OPTIONAL MATCH (d1:Disease)<-[:HAS_CONDITION]-(p)-[:HAS_CONDITION]->(d2:Disease)
OPTIONAL MATCH (d1)-[r:COMMONLY_OCCURS_WITH|LEADS_TO]->(d2)
WHERE d1 <> d2

WITH p, condition_count, complexity_levels, patient_conditions, patient_diseases,
     count(r) as disease_interactions,
     avg(r.strength) as avg_interaction_strength

// Advanced complexity calculations
WITH p, condition_count, patient_conditions, disease_interactions,
     // Base complexity score
     size([c IN complexity_levels WHERE c = "HIGH"]) * 4 +
     size([c IN complexity_levels WHERE c = "MODERATE"]) * 2 +
     size([c IN complexity_levels WHERE c = "LOW"]) * 1 as base_complexity_score,
     
     // Interaction multiplier (diseases that interact are more complex to manage)
     1 + (disease_interactions * coalesce(avg_interaction_strength, 0) * 0.5) as interaction_multiplier,
     
     // Multimorbidity exponential factor
     CASE 
         WHEN condition_count <= 2 THEN 1.0
         WHEN condition_count = 3 THEN 1.4  
         WHEN condition_count = 4 THEN 2.0
         WHEN condition_count = 5 THEN 2.8
         ELSE pow(1.4, condition_count - 2)
     END as multimorbidity_factor

// Resource utilization predictions
WITH p, condition_count, patient_conditions, disease_interactions,
     base_complexity_score, interaction_multiplier, multimorbidity_factor,
     base_complexity_score * interaction_multiplier * multimorbidity_factor as total_complexity_score

RETURN p.id as patient_id,
       p.age_group as age_range,
       condition_count as total_conditions,
       patient_conditions as diagnoses,
       disease_interactions as condition_interactions,
       round(base_complexity_score, 1) as base_complexity,
       round(interaction_multiplier, 2) as interaction_factor,
       round(multimorbidity_factor, 2) as multimorbidity_factor,
       round(total_complexity_score, 1) as comprehensive_complexity_score,
       
       // Resource predictions
       round(total_complexity_score * 2.3) as estimated_annual_gp_visits,
       round(total_complexity_score * 0.8) as estimated_annual_specialist_visits,
       round(total_complexity_score * 0.3) as estimated_annual_hospitalizations,
       round(total_complexity_score * 250) as estimated_annual_cost_pounds,
       
       // Care recommendations
       CASE 
           WHEN total_complexity_score >= 25 THEN "INTENSIVE_CASE_MANAGEMENT"
           WHEN total_complexity_score >= 15 THEN "ENHANCED_CARE_COORDINATION"
           WHEN total_complexity_score >= 8 THEN "STRUCTURED_CARE_PLANNING"
           ELSE "STANDARD_CARE"
       END as recommended_care_model,
       
       CASE 
           WHEN total_complexity_score >= 20 THEN "VERY_HIGH_COST"
           WHEN total_complexity_score >= 12 THEN "HIGH_COST"
           WHEN total_complexity_score >= 6 THEN "MODERATE_COST"
           ELSE "LOW_COST"
       END as cost_category,
       
       // Quality metrics
       round((1 - (total_complexity_score / 50)) * 100, 1) as predicted_quality_of_life_percentage,
       CASE 
           WHEN disease_interactions >= 3 THEN "HIGH_COORDINATION_NEEDS"
           WHEN disease_interactions >= 1 THEN "MODERATE_COORDINATION_NEEDS"
           ELSE "MINIMAL_COORDINATION_NEEDS"
       END as care_coordination_requirements

ORDER BY total_complexity_score DESC;

// 🌟 9. ADVANCED GRAPHRAG DISCOVERY ANALYTICS - Comprehensive insights summary
// Enhanced with discovery validation and clinical significance scoring
MATCH (d1:Disease)-[r]->(d2:Disease)
WITH type(r) as relationship_type, 
     count(r) as total_relationships,
     avg(r.strength) as avg_strength,
     stdev(r.strength) as strength_std_dev,
     collect({
         from: d1.name, 
         to: d2.name, 
         strength: r.strength,
         from_system: [(d1)-[:AFFECTS_SYSTEM]->(s1) | s1.name][0],
         to_system: [(d2)-[:AFFECTS_SYSTEM]->(s2) | s2.name][0]
     }) as all_relationships

// Calculate relationship quality metrics
WITH relationship_type, total_relationships, avg_strength, strength_std_dev, all_relationships,
     size([rel IN all_relationships WHERE rel.strength >= 0.8]) as very_strong_relationships,
     size([rel IN all_relationships WHERE rel.strength >= 0.6]) as strong_relationships,
     size([rel IN all_relationships WHERE rel.from_system <> rel.to_system]) as cross_system_relationships

// Discovery significance scoring
WITH relationship_type, total_relationships, avg_strength, strength_std_dev, all_relationships,
     very_strong_relationships, strong_relationships, cross_system_relationships,
     // Clinical significance score
     (avg_strength * 2) + 
     (very_strong_relationships * 1.0 / total_relationships) + 
     (cross_system_relationships * 1.0 / total_relationships) as clinical_significance_score

RETURN relationship_type as discovery_type,
       total_relationships as total_discoveries,
       round(avg_strength * 100, 1) + "%" as average_correlation_strength,
       round(strength_std_dev * 100, 1) + "%" as correlation_variability,
       very_strong_relationships as very_high_confidence_discoveries,
       strong_relationships as high_confidence_discoveries,
       cross_system_relationships as cross_system_discoveries,
       round(clinical_significance_score * 100, 1) as clinical_significance_score,
       [rel IN all_relationships WHERE rel.strength >= 0.8 | 
        rel.from + " → " + rel.to + " (" + round(rel.strength * 100) + "%)"][0..5] as top_discoveries,
       CASE 
           WHEN clinical_significance_score >= 2.5 THEN "BREAKTHROUGH_DISCOVERY"
           WHEN clinical_significance_score >= 1.8 THEN "SIGNIFICANT_DISCOVERY"
           WHEN clinical_significance_score >= 1.2 THEN "MODERATE_DISCOVERY"
           ELSE "PRELIMINARY_FINDING"
       END as discovery_significance_level,
       round(total_relationships * 100.0 / 500) as percentage_of_total_database_relationships
ORDER BY clinical_significance_score DESC;

// 🎯 10. NETWORK TOPOLOGY ANALYSIS - Graph structure insights
// New query for understanding the overall network properties
MATCH (d:Disease)
OPTIONAL MATCH (d)-[r]-(connected:Disease)
WITH d, count(DISTINCT connected) as degree_centrality, 
     collect(DISTINCT type(r)) as relationship_types,
     avg(r.strength) as avg_connection_strength

// Calculate network statistics
WITH collect({
    disease: d.name,
    degree: degree_centrality,
    avg_strength: avg_connection_strength,
    relationship_diversity: size(relationship_types)
}) as network_nodes,
avg(degree_centrality) as network_avg_degree,
stdev(degree_centrality) as network_degree_std,
max(degree_centrality) as max_degree,
min(degree_centrality) as min_degree

RETURN "NETWORK_TOPOLOGY_SUMMARY" as analysis_type,
       size(network_nodes) as total_diseases_in_network,
       round(network_avg_degree, 2) as average_disease_connections,
       round(network_degree_std, 2) as connection_variability,
       max_degree as most_connected_disease_connections,
       min_degree as least_connected_disease_connections,
       [node IN network_nodes WHERE node.degree = max_degree | node.disease][0] as most_connected_disease,
       round((network_degree_std / network_avg_degree) * 100, 1) + "%" as network_heterogeneity_index,
       CASE 
           WHEN network_degree_std / network_avg_degree > 1.0 THEN "SCALE_FREE_NETWORK"
           WHEN network_degree_std / network_avg_degree > 0.5 THEN "HETEROGENEOUS_NETWORK"
           ELSE "HOMOGENEOUS_NETWORK"
       END as network_type_classification,
       size([node IN network_nodes WHERE node.degree >= network_avg_degree * 2]) as hub_disease_count;