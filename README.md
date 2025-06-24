# Multimorbidity Knowledge Graph System

An advanced graph-based analytics platform for discovering complex relationships between chronic medical conditions using validated clinical data. This system combines knowledge graphs with AI-powered analysis to uncover multimorbidity patterns, predict disease interactions, and support evidence-based clinical decision making.

## 🏆 Research Foundation

This system integrates the **CPRD Multimorbidity Codelists**—a validated dataset from research published in **The Lancet Healthy Longevity**.

**Key Research Integration**:
- **Publication**: "Inequalities in incident and prevalent multimorbidity in England, 2004–19: a population-based, descriptive study"
- **Journal**: The Lancet Healthy Longevity ([DOI: 10.1016/S2666-7568(21)00146-X](https://doi.org/10.1016/S2666-7568(21)00146-X))
- **Lead Researcher**: Anna Head, University of Liverpool/SPHR PhD Student
- **Dataset**: 211 chronic conditions across 15 body systems with rigorous clinical validation

## 🎯 Core Mission

This platform transforms how we understand and analyze multimorbidity by leveraging graph-based algorithms to reveal hidden relationships between chronic conditions. By processing validated clinical datasets through advanced knowledge graphs, we enable researchers and clinicians to discover patterns that traditional analysis methods cannot detect.

### Key Capabilities

1. **Relationship Discovery** – Map complex interactions between 211 validated chronic conditions across 15 body systems
2. **Pattern Recognition** – Identify multimorbidity clusters and progression pathways using graph algorithms  
3. **Predictive Analytics** – Forecast disease interactions and complications through network analysis
4. **Clinical Intelligence** – Generate evidence-based insights for personalized care planning
5. **Population Health** – Analyze multimorbidity trends at scale for healthcare policy development

## 🏗️ Architecture

The system uses a modular architecture separating data processing from graph operations:

```
├── graph.py                     # Core GraphRAG implementation
├── processing_pipeline.py       # Document processing utilities
├── documents/                   # Medical documents and datasets
│   ├── cardiac_case_study.docx                        # Clinical case study - fictitious 
│   ├── Multimorbidity detailed analysis.docx           # Research documents
│   ├── CHERP96_multimorbidity_utilisation_costs_health_social care.docx  # Health and social care cost analysis
│   └── CPRD_multimorbidity_codelists-main/             # Research-grade dataset
│       ├── DiseaseSummary.csv                          # 211 chronic conditions
│       ├── codelists/                                  # Individual condition codes
│       └── tests/                                      # Laboratory test values
└── tests/                       # Test suites
    ├── run_tests.py            # Test runner script
    ├── test_basic.py           # Basic functionality tests
    ├── test_connection.py      # Database connectivity tests
    ├── test_cprd_core.py       # CPRD data core tests
    ├── test_hypothesis.py      # Hypothesis testing
    └── test_rag.py            # RAG system functionality tests
```

## 🔬 Enhanced Capabilities with CPRD Data

### Standardized Medical Terminology
- **211 validated chronic conditions** with SNOMED CT codes
- **15 body system classifications** for systematic analysis
- **Evidence-based multimorbidity definitions** from population health research
- **Clinical code mappings** validated by medical professionals

### Advanced Multimorbidity Analysis
- **Basic Multimorbidity**: Two or more chronic diseases
- **Complex Multimorbidity**: Three or more chronic conditions affecting three or more body systems
- **Population-level patterns** from English primary care data (2004–2019)
- **Cross-system interactions** between medical domains

## 🔧 Technology Stack

- **LLM Integration**: Google Gemini 2.5 Flash for text processing and embeddings
- **Graph Database**: Neo4j for knowledge graph storage and querying
- **Vector Store**: In-memory vector storage for semantic search
- **Document Processing**: LangChain ecosystem for document loading and chunking
- **Medical Standards**: SNOMED CT codes and CALIBER phenotype algorithms
- **Embedding Model**: Google Generative AI Embeddings (gemini-embedding-exp-03-07)

## 📋 Prerequisites

- Python 3.10+
- Neo4j Database (local or cloud instance)
- Google Cloud API access with Gemini API enabled

## 🚀 Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Multimorbidity_Graphs
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Environment setup**
   ```bash
   cp .env.template .env
   # Edit .env with your API keys and database credentials
   ```

4. **Required environment variables**
   ```env
   GOOGLE_API_KEY=your_google_api_key_here
   NEO4J_URI=bolt://localhost:7687
   NEO4J_USERNAME=neo4j
   NEO4J_PASSWORD=your_neo4j_password_here
   ```

## 🏃‍♂️ Usage

### Basic Operation

1. **Prepare documents**: Place your medical documents (`.docx` format) in the `documents/` directory

2. **Run the system**:
   ```bash
   python graph.py
   ```

3. **Query the system**: Once initialized, you can query the knowledge graph with medical questions

### Advanced Query Examples

#### Graph-Based Relationship Discovery
```
# Find unexpected condition clusters
"What conditions frequently co-occur but are from different body systems?"

# Identify central hub conditions
"Which conditions have the highest number of connections to other diseases?"

# Trace disease progression pathways
"What are the most common paths from diabetes to cardiovascular complications?"
```

#### Network Analysis Queries
```
# Community detection
"Identify distinct disease communities and their characteristics"

# Centrality measures
"Rank conditions by their influence on overall multimorbidity complexity"

# Path analysis
"Find the shortest paths between seemingly unrelated conditions"
```

#### Predictive Analytics
```
# Risk prediction
"Given a patient with condition X, what other conditions are they likely to develop?"

# Intervention impact
"If we prevent condition Y, what downstream effects would we see?"

# Population modeling
"How would reducing diabetes prevalence affect the entire disease network?"
```

## 🧪 Testing

Run the test suite to verify system functionality:

```bash
# Test database connectivity
python -m pytest tests/test_connection.py

# Test RAG system functionality
python -m pytest tests/test_rag.py

# Run all tests
python -m pytest tests/
```

## 📊 Features

### Document Processing
- **Semantic chunking** for meaningful text segmentation
- **Multi-format support** (DOCX, PDF planned)
- **Metadata preservation** for document traceability

### Knowledge Graph Construction
- **Automated entity extraction** from medical texts
- **CPRD-validated condition mapping** with SNOMED CT codes
- **Research-grade relationship modeling** based on clinical evidence
- **Multi-level hierarchy support** (conditions → systems → complications)

### RAG Capabilities
- **Hybrid retrieval** combining vector search and graph traversal
- **Clinical terminology standardization** using validated codelists
- **Evidence-based responses** grounded in population health data
- **Multimorbidity complexity awareness** for nuanced clinical insights

## 🎯 Advanced Medical Use Cases

### 1. Evidence-Based Multimorbidity Research
Leverage validated clinical data for sophisticated analysis:
- **Population health patterns** from English primary care (2004–2019)
- **Validated condition definitions** from Lancet-published research
- **Cross-system interaction modeling** for complex patients
- **Healthcare utilization prediction** based on condition clusters

### 2. Clinical Decision Support with Validated Data
Provide evidence-based insights using research-grade codelists:
- **Standardized condition recognition** using SNOMED CT codes
- **Multi-visit diagnostic criteria** for chronic conditions
- **Condition sequelae tracking** for comprehensive care planning
- **Body system interaction analysis** for complex cases

### 3. Health Policy and Economics Research
Support healthcare policy development with validated datasets:
- **Multimorbidity complexity scoring** for resource allocation
- **Care pathway optimization** across multiple conditions
- **Population risk stratification** for preventive care planning
- **Healthcare system burden analysis** for policy development

## 🔒 Data Privacy & Security

- All processing occurs locally or in your controlled environment
- CPRD data used complies with research publication standards
- No patient-identifiable information included in codelists
- Graph database provides secure, local storage of extracted knowledge
- Compliance with healthcare data protection requirements

## 🙏 Acknowledgments

We extend our profound gratitude to:

**Anna Head** and the research team at the University of Liverpool/SPHR for making the CPRD multimorbidity codelists available to the research community. Their rigorous methodology and transparent sharing of validated clinical data enables advanced multimorbidity research.

**The CALIBER Research Program** for providing the foundational phenotype algorithms that underpin this clinical classification system.

**The Lancet Healthy Longevity** for publishing this important research on multimorbidity inequalities, making evidence-based clinical data accessible for further research.

This integration demonstrates the power of open science and collaborative research in advancing our understanding of complex medical conditions.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🚀 Next Steps: Unlocking Hidden Relationships

Our roadmap focuses on sophisticated graph-based approaches to reveal previously unknown connections in multimorbidity data:

### Phase 1: Foundation Building (Current)
- [x] **CPRD Dataset Integration**: 211 validated conditions with SNOMED CT codes
- [x] **Neo4j Knowledge Graph**: Core infrastructure for relationship mapping
- [x] **RAG Pipeline**: Document processing and intelligent querying
- [ ] **Graph Algorithm Implementation**: Centrality measures, community detection, path analysis

### Phase 2: Relationship Discovery (Next 3 months)
- [ ] **Network Analysis Algorithms**
  - Implement PageRank to identify influential conditions
  - Deploy community detection to find disease clusters
  - Apply shortest path algorithms to trace condition progressions
- [ ] **Temporal Pattern Mining**
  - Analyze condition onset sequences across body systems
  - Identify early warning indicators for complex multimorbidity
  - Map disease progression trajectories using graph walks
- [ ] **Co-occurrence Network Building**
  - Statistical significance testing for condition pairs
  - Weighted edge creation based on clinical evidence strength
  - Multi-layer network construction for different patient populations

### Phase 3: Advanced Analytics (3-6 months)
- [ ] **Predictive Relationship Modeling**
  - Graph neural networks for condition interaction prediction
  - Link prediction algorithms for identifying future comorbidities
  - Anomaly detection for unusual multimorbidity patterns
- [ ] **Risk Stratification Networks**
  - Patient similarity graphs based on condition profiles
  - Graph-based clustering for personalized risk assessment
  - Dynamic network analysis for condition evolution tracking

### Phase 4: Clinical Intelligence (6-12 months)
- [ ] **Interactive Graph Visualization**
  - Real-time exploration of condition relationships
  - Customizable network views for different clinical scenarios
  - Integration with clinical decision support systems
- [ ] **FHIR-Compliant Graph APIs**
  - Standardized healthcare data exchange
  - Integration with electronic health record systems
  - Graph-based clinical pathway recommendations

### Breakthrough Opportunities
Our graph-based approach will reveal:
- **Hidden Condition Clusters**: Unexpected groupings of seemingly unrelated conditions
- **Cascade Effect Pathways**: How single conditions trigger multiple system failures
- **Protective Relationships**: Conditions that may prevent others from developing
- **System Vulnerability Points**: Critical nodes where interventions could prevent complex multimorbidity

## 📚 Key References

1. Head, A. et al. (2021). Inequalities in incident and prevalent multimorbidity in England, 2004–19: a population-based, descriptive study. *The Lancet Healthy Longevity*, 2(8), e489-e497.
2. Kuan, V. et al. (2019). A chronological map of 308 physical and mental health conditions from 4 million individuals in the English National Health Service. *The Lancet Digital Health*, 1(2), e63-e77.
3. The Academy of Medical Sciences. (2018). Multimorbidity: a priority for global health research.

## 📄 License

This project is licensed under the MIT License – see the LICENSE file for details.

---

**Note**: This system integrates peer-reviewed research data for educational and research purposes. Any clinical applications should undergo appropriate validation and regulatory review. The CPRD codelists are used in accordance with the original research publication's data sharing provisions.
