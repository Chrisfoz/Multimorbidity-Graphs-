import os
import glob
import pandas as pd
from typing import List, Dict, Any
from langchain_core.documents import Document

def load_cprd_codelists() -> List[Document]:
    """Load CPRD multimorbidity codelists from CSV files and convert to documents"""
    documents = []
    
    # Load disease summary first
    summary_path = "./documents/CPRD_multimorbidity_codelists-main/DiseaseSummary.csv"
    if os.path.exists(summary_path):
        print("Loading CPRD Disease Summary...")
        summary_df = pd.read_csv(summary_path)
        
        # Create summary document
        summary_content = f"""
        CPRD Multimorbidity Disease Summary
        
        Total Conditions: {len(summary_df)}
        Body Systems: {summary_df['system'].nunique()}
        
        Conditions by System:
        {summary_df.groupby('system').size().to_string()}
        
        Condition Types:
        {summary_df['type'].value_counts().to_string()}
        """
        
        summary_doc = Document(
            page_content=summary_content,
            metadata={
                "source": "CPRD_DiseaseSummary",
                "type": "summary",
                "conditions_count": len(summary_df),
                "systems_count": summary_df['system'].nunique()
            }
        )
        documents.append(summary_doc)
    
    # Load individual condition codelists
    codelists_path = "./documents/CPRD_multimorbidity_codelists-main/codelists/*.csv"
    csv_files = glob.glob(codelists_path)
    
    print(f"Found {len(csv_files)} CPRD codelist files")
    
    for csv_file in csv_files:
        condition_name = os.path.basename(csv_file).replace('.csv', '')
        print(f"Processing {condition_name}...")
        
        try:
            df = pd.read_csv(csv_file)
            
            # Create content from CSV data
            content = f"""
            Condition: {condition_name}
            
            Total Medical Codes: {len(df)}
            
            Code Mappings:
            {df['mapping'].value_counts().to_string() if 'mapping' in df.columns else 'No mapping data'}
            
            Sample Descriptions:
            {df['descr'].head(10).to_string() if 'descr' in df.columns else 'No descriptions'}
            
            SNOMED CT Concepts:
            {df['snomedctconceptid'].nunique() if 'snomedctconceptid' in df.columns else 0} unique concepts
            """
            
            # Extract metadata
            metadata = {
                "source": f"CPRD_{condition_name}",
                "type": "condition_codelist",
                "condition": condition_name,
                "codes_count": len(df),
                "file_path": csv_file
            }
            
            # Add additional metadata if available
            if 'disease_num' in df.columns and not df['disease_num'].isna().all():
                metadata["disease_num"] = df['disease_num'].iloc[0]
            if 'system' in df.columns and not df['system'].isna().all():
                metadata["system"] = df['system'].iloc[0]
            if 'system_num' in df.columns and not df['system_num'].isna().all():
                metadata["system_num"] = df['system_num'].iloc[0]
            
            doc = Document(page_content=content, metadata=metadata)
            documents.append(doc)
            
        except Exception as e:
            print(f"Error processing {csv_file}: {e}")
            continue
    
    print(f"Loaded {len(documents)} CPRD documents")
    return documents

def load_cprd_tests() -> List[Document]:
    """Load CPRD test value codelists"""
    documents = []
    tests_path = "./documents/CPRD_multimorbidity_codelists-main/tests/*.csv"
    test_files = glob.glob(tests_path)
    
    print(f"Found {len(test_files)} CPRD test files")
    
    for test_file in test_files:
        test_name = os.path.basename(test_file).replace('.csv', '')
        print(f"Processing test: {test_name}...")
        
        try:
            df = pd.read_csv(test_file)
            
            content = f"""
            Test Type: {test_name}
            
            Total Test Codes: {len(df)}
            
            Test Definitions:
            {df.to_string(max_rows=20) if len(df) <= 20 else df.head(10).to_string()}
            """
            
            metadata = {
                "source": f"CPRD_test_{test_name}",
                "type": "test_values",
                "test_name": test_name,
                "codes_count": len(df),
                "file_path": test_file
            }
            
            doc = Document(page_content=content, metadata=metadata)
            documents.append(doc)
            
        except Exception as e:
            print(f"Error processing test file {test_file}: {e}")
            continue
    
    print(f"Loaded {len(documents)} CPRD test documents")
    return documents

def create_multimorbidity_relationships(documents: List[Document]) -> List[Dict[str, Any]]:
    """Create multimorbidity relationship data from CPRD documents"""
    relationships = []
    
    # Extract conditions by body system
    conditions_by_system = {}
    
    for doc in documents:
        if doc.metadata.get("type") == "condition_codelist":
            system = doc.metadata.get("system")
            condition = doc.metadata.get("condition")
            
            if system and condition:
                if system not in conditions_by_system:
                    conditions_by_system[system] = []
                conditions_by_system[system].append(condition)
    
    # Create system-level relationships
    for system, conditions in conditions_by_system.items():
        for i, condition1 in enumerate(conditions):
            for condition2 in conditions[i+1:]:
                relationships.append({
                    "source": condition1,
                    "target": condition2,
                    "relationship": "SAME_SYSTEM",
                    "system": system,
                    "type": "system_cooccurrence"
                })
    
    # Create cross-system relationships for common multimorbidity patterns
    common_patterns = [
        (["Type 2 Diabetes Mellitus", "Hypertension"], "CARDIOVASCULAR_METABOLIC"),
        (["COPD", "Heart failure"], "CARDIOPULMONARY"),
        (["Depression", "Chronic Kidney Disease"], "PSYCHONEPHRIC"),
        (["Obesity", "Type 2 Diabetes Mellitus"], "METABOLIC_SYNDROME")
    ]
    
    for pattern_conditions, pattern_type in common_patterns:
        for i, condition1 in enumerate(pattern_conditions):
            for condition2 in pattern_conditions[i+1:]:
                relationships.append({
                    "source": condition1,
                    "target": condition2,
                    "relationship": "MULTIMORBIDITY_PATTERN",
                    "pattern_type": pattern_type,
                    "type": "clinical_association"
                })
    
    print(f"Created {len(relationships)} multimorbidity relationships")
    return relationships

def analyze_condition_complexity(documents: List[Document]) -> Dict[str, Any]:
    """Analyze multimorbidity complexity from CPRD data"""
    analysis = {
        "total_conditions": 0,
        "systems": set(),
        "condition_distribution": {},
        "complexity_metrics": {}
    }
    
    for doc in documents:
        if doc.metadata.get("type") == "condition_codelist":
            analysis["total_conditions"] += 1
            system = doc.metadata.get("system")
            if system:
                analysis["systems"].add(system)
                
                if system not in analysis["condition_distribution"]:
                    analysis["condition_distribution"][system] = 0
                analysis["condition_distribution"][system] += 1
    
    # Convert set to list for JSON serialization
    analysis["systems"] = list(analysis["systems"])
    analysis["systems_count"] = len(analysis["systems"])
    
    # Calculate complexity metrics
    analysis["complexity_metrics"] = {
        "avg_conditions_per_system": analysis["total_conditions"] / len(analysis["systems"]) if analysis["systems"] else 0,
        "system_diversity": len(analysis["systems"]) / 15,  # 15 is max systems in CPRD
        "largest_system": max(analysis["condition_distribution"].values()) if analysis["condition_distribution"] else 0
    }
    
    return analysis