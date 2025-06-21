#!/usr/bin/env python3
"""
Test Runner for GraphRAG Multimorbidity System
Organizes and runs all test suites in proper order
"""

import os
import sys
import subprocess
from pathlib import Path

# Add project root to path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

class TestRunner:
    """Orchestrates running all tests in the correct order"""
    
    def __init__(self):
        self.tests_dir = Path(__file__).parent
        self.project_root = self.tests_dir.parent
        self.results = {}
        
    def print_header(self, title):
        """Print formatted test section header"""
        print("\n" + "=" * 80)
        print(f"🧪 {title}")
        print("=" * 80)
    
    def print_section(self, title):
        """Print formatted subsection header"""
        print(f"\n🔍 {title}")
        print("-" * 60)
    
    def run_python_test(self, test_file, description):
        """Run a Python test file and capture results"""
        print(f"\n▶️  Running {description}...")
        test_path = self.tests_dir / test_file
        
        if not test_path.exists():
            print(f"❌ Test file not found: {test_file}")
            return False
        
        try:
            # Change to project root for relative imports
            os.chdir(self.project_root)
            
            # Run the test
            result = subprocess.run(
                [sys.executable, str(test_path)],
                capture_output=True,
                text=True,
                timeout=300  # 5 minute timeout
            )
            
            if result.returncode == 0:
                print(f"✅ {description} - PASSED")
                print("📋 Output:")
                # Show last few lines of output
                output_lines = result.stdout.strip().split('\n')
                for line in output_lines[-10:]:  # Last 10 lines
                    print(f"   {line}")
                return True
            else:
                print(f"❌ {description} - FAILED")
                print("📋 Error Output:")
                print(result.stderr)
                return False
                
        except subprocess.TimeoutExpired:
            print(f"⏱️  {description} - TIMEOUT")
            return False
        except Exception as e:
            print(f"❌ {description} - ERROR: {e}")
            return False
    
    def test_basic_functionality(self):
        """Test 1: Basic functionality without dependencies"""
        self.print_section("Basic Functionality Tests")
        
        result = self.run_python_test("test_basic.py", "Project Structure & File Validation")
        self.results["basic_functionality"] = result
        return result
    
    def test_cprd_core_analysis(self):
        """Test 2: CPRD core analysis"""
        self.print_section("CPRD Core Analysis")
        
        result = self.run_python_test("test_cprd_core.py", "CPRD Multimorbidity Analysis & Hypothesis Testing")
        self.results["cprd_core_analysis"] = result
        return result
    
    def test_database_connection(self):
        """Test 3: Database connection (may fail without setup)"""
        self.print_section("Database Connection Test")
        
        print("⚠️  Note: This test requires Neo4j database and environment setup")
        result = self.run_python_test("test_connection.py", "Neo4j Database Connection")
        self.results["database_connection"] = result
        return result
    
    def test_full_system(self):
        """Test 4: Full system test (may fail without dependencies)"""
        self.print_section("Full System Tests")
        
        print("⚠️  Note: These tests require all dependencies and environment setup")
        
        # Test RAG system
        rag_result = self.run_python_test("test_rag.py", "GraphRAG System Integration")
        
        # Test hypothesis system (advanced)
        hyp_result = self.run_python_test("test_hypothesis.py", "Advanced Hypothesis Testing")
        
        full_result = rag_result and hyp_result
        self.results["full_system"] = full_result
        return full_result
    
    def generate_summary_report(self):
        """Generate final test summary report"""
        self.print_header("TEST SUMMARY REPORT")
        
        total_tests = len(self.results)
        passed_tests = sum(1 for result in self.results.values() if result)
        success_rate = (passed_tests / total_tests * 100) if total_tests > 0 else 0
        
        print(f"\n🎯 OVERALL RESULTS:")
        print(f"   • Test suites run: {total_tests}")
        print(f"   • Test suites passed: {passed_tests}")
        print(f"   • Success rate: {success_rate:.1f}%")
        
        print(f"\n📋 DETAILED RESULTS:")
        test_descriptions = {
            "basic_functionality": "Basic Functionality & File Structure",
            "cprd_core_analysis": "CPRD Core Analysis & Hypothesis Testing", 
            "database_connection": "Database Connection",
            "full_system": "Full System Integration"
        }
        
        for test_key, result in self.results.items():
            status = "✅ PASSED" if result else "❌ FAILED"
            description = test_descriptions.get(test_key, test_key)
            print(f"   {status} {description}")
        
        print(f"\n💡 RECOMMENDATIONS:")
        
        if self.results.get("basic_functionality") and self.results.get("cprd_core_analysis"):
            print(f"   ✅ Core system validated - CPRD dataset ready for use")
            
            if not self.results.get("database_connection"):
                print(f"   🔧 Setup Neo4j database to enable full GraphRAG functionality")
                print(f"      1. Install Neo4j Desktop or use Neo4j AuraDB")
                print(f"      2. Create .env file with database credentials")
                print(f"      3. Install Python dependencies: pip install -r requirements.txt")
            
            if not self.results.get("full_system"):
                print(f"   🔧 Install dependencies for full system functionality")
                print(f"      1. pip install -r requirements.txt")
                print(f"      2. Setup Google Gemini API keys in .env")
                print(f"      3. Start Neo4j database")
        else:
            print(f"   ❌ Core system issues detected - check file structure and data")
        
        print(f"\n🚀 NEXT STEPS:")
        if passed_tests >= 2:  # Basic + CPRD tests
            print(f"   • Your GraphRAG multimorbidity system is validated!")
            print(f"   • CPRD dataset with 216 conditions is ready for analysis")
            print(f"   • Complete environment setup for full functionality")
            print(f"   • Run specific hypothesis tests for research questions")
        else:
            print(f"   • Review failed tests and fix underlying issues")
            print(f"   • Ensure CPRD data is properly downloaded and extracted")
            print(f"   • Check file permissions and project structure")
        
        return self.results
    
    def run_all_tests(self):
        """Run all test suites in order"""
        self.print_header("GraphRAG Multimorbidity System - Test Suite")
        
        print("🎯 Test Execution Plan:")
        print("   1. Basic Functionality Tests (no dependencies)")
        print("   2. CPRD Core Analysis (data validation)")
        print("   3. Database Connection (requires Neo4j)")
        print("   4. Full System Integration (requires all dependencies)")
        
        # Run tests in order of complexity
        try:
            # Test 1: Basic functionality (should always pass)
            basic_success = self.test_basic_functionality()
            
            # Test 2: CPRD analysis (should pass if data is available)
            if basic_success:
                self.test_cprd_core_analysis()
            else:
                print("⚠️  Skipping CPRD analysis due to basic test failures")
                self.results["cprd_core_analysis"] = False
            
            # Test 3: Database connection (may fail without setup)
            self.test_database_connection()
            
            # Test 4: Full system (may fail without dependencies)
            self.test_full_system()
            
        except KeyboardInterrupt:
            print("\n⚠️  Testing interrupted by user")
        except Exception as e:
            print(f"\n❌ Unexpected error during testing: {e}")
        
        # Generate final report
        results = self.generate_summary_report()
        
        return results

def main():
    """Main test runner entry point"""
    runner = TestRunner()
    results = runner.run_all_tests()
    
    # Return appropriate exit code
    if results.get("basic_functionality") and results.get("cprd_core_analysis"):
        print(f"\n🎉 Core system validation successful!")
        return 0
    else:
        print(f"\n❌ Core system validation failed!")
        return 1

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)