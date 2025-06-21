#!/usr/bin/env python3
"""
Basic testing without external dependencies
Tests file structure, data loading, and basic functionality
"""

import os
import glob
import csv
from pathlib import Path

def test_file_structure():
    """Test that all required files are present"""
    print("🔍 Testing File Structure")
    print("-" * 30)
    
    required_files = [
        "graph.py",
        "processing_pipeline.py", 
        "requirements.txt",
        ".env.template",
        "README.md",
        "tests/test_connection.py",
        "tests/test_rag.py",
        "test_hypothesis.py"
    ]
    
    missing_files = []
    present_files = []
    
    for file_path in required_files:
        if os.path.exists(file_path):
            present_files.append(file_path)
            print(f"✅ {file_path}")
        else:
            missing_files.append(file_path)
            print(f"❌ {file_path}")
    
    print(f"\n📊 File Structure Summary:")
    print(f"   • Present: {len(present_files)}/{len(required_files)}")
    print(f"   • Missing: {len(missing_files)}")
    
    return len(missing_files) == 0

def test_cprd_data_structure():
    """Test CPRD data files are present and readable"""
    print("\n🔍 Testing CPRD Data Structure")
    print("-" * 35)
    
    cprd_base = "./documents/CPRD_multimorbidity_codelists-main"
    
    # Check main directory
    if not os.path.exists(cprd_base):
        print(f"❌ CPRD base directory not found: {cprd_base}")
        return False
    
    print(f"✅ CPRD base directory exists: {cprd_base}")
    
    # Check key files
    key_files = [
        "DiseaseSummary.csv",
        "README.md", 
        "DiseaseDocumentation.md"
    ]
    
    for file_name in key_files:
        file_path = os.path.join(cprd_base, file_name)
        if os.path.exists(file_path):
            print(f"✅ {file_name}")
        else:
            print(f"❌ {file_name}")
    
    # Check codelists directory
    codelists_dir = os.path.join(cprd_base, "codelists")
    if os.path.exists(codelists_dir):
        csv_files = glob.glob(os.path.join(codelists_dir, "*.csv"))
        print(f"✅ Codelists directory: {len(csv_files)} CSV files")
        
        # Sample a few files
        print(f"   Sample files:")
        for file_path in csv_files[:5]:
            file_name = os.path.basename(file_path)
            print(f"     • {file_name}")
    else:
        print(f"❌ Codelists directory not found")
        return False
    
    # Check tests directory
    tests_dir = os.path.join(cprd_base, "tests")
    if os.path.exists(tests_dir):
        test_files = glob.glob(os.path.join(tests_dir, "*.csv"))
        print(f"✅ Tests directory: {len(test_files)} CSV files")
    else:
        print(f"❌ Tests directory not found")
    
    return True

def test_disease_summary_parsing():
    """Test parsing of the DiseaseSummary.csv file"""
    print("\n🔍 Testing Disease Summary Parsing")
    print("-" * 38)
    
    summary_path = "./documents/CPRD_multimorbidity_codelists-main/DiseaseSummary.csv"
    
    if not os.path.exists(summary_path):
        print(f"❌ DiseaseSummary.csv not found at {summary_path}")
        return False
    
    try:
        with open(summary_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            
            conditions = list(reader)
            print(f"✅ Successfully parsed {len(conditions)} conditions")
            
            # Analyze by system
            systems = {}
            for condition in conditions:
                system = condition.get('system', 'Unknown')
                if system not in systems:
                    systems[system] = 0
                systems[system] += 1
            
            print(f"✅ Found {len(systems)} body systems:")
            for system, count in sorted(systems.items(), key=lambda x: x[1], reverse=True)[:10]:
                print(f"     • {system}: {count} conditions")
            
            # Check for key conditions
            condition_names = [c.get('Disease', '') for c in conditions]
            key_conditions = [
                'Type 2 Diabetes Mellitus',
                'Hypertension', 
                'Heart failure',
                'COPD',
                'Depression'
            ]
            
            print(f"\n✅ Key multimorbidity conditions found:")
            for key_condition in key_conditions:
                if key_condition in condition_names:
                    print(f"     ✅ {key_condition}")
                else:
                    print(f"     ❓ {key_condition} (may have different name)")
            
            return True
            
    except Exception as e:
        print(f"❌ Error parsing DiseaseSummary.csv: {e}")
        return False

def test_sample_condition_files():
    """Test parsing of sample condition CSV files"""
    print("\n🔍 Testing Sample Condition Files")
    print("-" * 36)
    
    codelists_dir = "./documents/CPRD_multimorbidity_codelists-main/codelists"
    
    # Test a few key condition files
    test_conditions = [
        "Type 2 Diabetes Mellitus.csv",
        "Hypertension.csv",
        "Heart failure.csv",
        "COPD.csv"
    ]
    
    successful_parses = 0
    
    for condition_file in test_conditions:
        file_path = os.path.join(codelists_dir, condition_file)
        
        if os.path.exists(file_path):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    reader = csv.DictReader(f)
                    codes = list(reader)
                    
                print(f"✅ {condition_file}: {len(codes)} medical codes")
                
                # Check for SNOMED CT codes
                snomed_codes = [c for c in codes if c.get('snomedctconceptid')]
                print(f"     • SNOMED CT codes: {len(snomed_codes)}")
                
                successful_parses += 1
                
            except Exception as e:
                print(f"❌ Error parsing {condition_file}: {e}")
        else:
            print(f"❓ {condition_file} not found")
    
    print(f"\n📊 Condition File Parsing Summary:")
    print(f"   • Successfully parsed: {successful_parses}/{len(test_conditions)}")
    
    return successful_parses > 0

def test_documents_directory():
    """Test documents directory structure"""
    print("\n🔍 Testing Documents Directory")
    print("-" * 32)
    
    docs_dir = "./documents"
    
    if not os.path.exists(docs_dir):
        print(f"❌ Documents directory not found: {docs_dir}")
        return False
    
    # List all files in documents
    all_files = []
    for root, dirs, files in os.walk(docs_dir):
        for file in files:
            rel_path = os.path.relpath(os.path.join(root, file), docs_dir)
            all_files.append(rel_path)
    
    print(f"✅ Documents directory contains {len(all_files)} files")
    
    # Categorize files
    docx_files = [f for f in all_files if f.endswith('.docx')]
    csv_files = [f for f in all_files if f.endswith('.csv')]
    pdf_files = [f for f in all_files if f.endswith('.pdf')]
    
    print(f"   • DOCX files: {len(docx_files)}")
    print(f"   • CSV files: {len(csv_files)}")
    print(f"   • PDF files: {len(pdf_files)}")
    
    # Show some examples
    if docx_files:
        print(f"   • Sample DOCX: {docx_files[0]}")
    if csv_files:
        print(f"   • Sample CSV: {csv_files[0]}")
    
    return True

def run_all_tests():
    """Run all basic tests"""
    print("🚀 Starting Basic System Tests (No Dependencies)")
    print("=" * 60)
    
    tests = [
        ("File Structure", test_file_structure),
        ("CPRD Data Structure", test_cprd_data_structure), 
        ("Disease Summary Parsing", test_disease_summary_parsing),
        ("Sample Condition Files", test_sample_condition_files),
        ("Documents Directory", test_documents_directory)
    ]
    
    results = {}
    passed_tests = 0
    
    for test_name, test_func in tests:
        try:
            result = test_func()
            results[test_name] = result
            if result:
                passed_tests += 1
        except Exception as e:
            print(f"❌ {test_name} failed with error: {e}")
            results[test_name] = False
    
    # Final summary
    print("\n" + "=" * 60)
    print("📊 BASIC TESTING SUMMARY")
    print("=" * 60)
    
    print(f"\n🎯 OVERALL RESULTS:")
    print(f"   • Tests passed: {passed_tests}/{len(tests)}")
    print(f"   • Success rate: {passed_tests/len(tests)*100:.1f}%")
    
    print(f"\n📋 DETAILED RESULTS:")
    for test_name, result in results.items():
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"   {status} {test_name}")
    
    if passed_tests == len(tests):
        print(f"\n🎉 ALL BASIC TESTS PASSED!")
        print(f"📝 Next steps:")
        print(f"   1. Install dependencies: pip install -r requirements.txt")
        print(f"   2. Setup .env file with API keys and Neo4j credentials")
        print(f"   3. Start Neo4j database")
        print(f"   4. Run: python test_hypothesis.py")
    else:
        print(f"\n⚠️  Some tests failed. Please check the issues above.")
    
    return results

if __name__ == "__main__":
    results = run_all_tests()