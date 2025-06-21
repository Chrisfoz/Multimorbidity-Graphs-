# GraphRAG Medical Analysis System specialising in multimorbidity patterns and clinical case studies

A research-grade graph-based Retrieval-Augmented Generation (RAG) system for complex medical document analysis, specializing in multimorbidity patterns and clinical case studies. Enhanced with validated clinical data from peer-reviewed multimorbidity research.

## 🏆 Research Foundation

This system integrates the **CPRD Multimorbidity Codelists**—a validated dataset from research published in **The Lancet Healthy Longevity**.

**Key Research Integration**:
- **Publication**: "Inequalities in incident and prevalent multimorbidity in England, 2004–19: a population-based, descriptive study"
- **Journal**: The Lancet Healthy Longevity ([DOI: 10.1016/S2666-7568(21)00146-X](https://doi.org/10.1016/S2666-7568(21)00146-X))
- **Lead Researcher**: Anna Head, University of Liverpool/SPHR PhD Student
- **Dataset**: 211 chronic conditions across 15 body systems with rigorous clinical validation

## 🎯 Project Overview

Combines knowledge graphs and large language models to analyse medical documents, extract clinical relationships, and provide intelligent querying for healthcare research and clinical decision support.

### Primary Use Cases

1. **Multimorbidity Pattern Analysis** – Understand complex interactions between chronic conditions using validated codelists
2. **Clinical Case Studies** – Extract insights from detailed patient scenarios
3. **Medical Knowledge Discovery** – Identify patterns and relationships in clinical literature
4. **Healthcare Research** – Analyze multimorbidity trends and outcomes at the population level

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
   cd Graph_updarte
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

### Sample Queries Enhanced by CPRD Data

#### Population-Level Multimorbidity Analysis
- "What are the most common three-condition clusters in cardiovascular diseases?"
- "How do endocrine system conditions interact with circulatory system diseases?"
- "What monitoring requirements exist for patients with diabetes and heart failure?"

#### Clinical Decision Support
- "For a patient with Type 2 diabetes, COPD, and depression, what are the key interaction considerations?"
- "What are the progression pathways from basic to complex multimorbidity?"
- "How should care coordination be managed across multiple body systems?"

#### Research and Policy Questions
- "What are the differences between single-visit and multi-visit diagnostic criteria?"
- "How do condition sequelae affect multimorbidity complexity scoring?"
- "What test values are integrated into chronic disease monitoring?"

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

## 📈 Roadmap

- [ ] **CPRD Data Integration**: Full integration of all 211 conditions into knowledge graph
- [ ] **Advanced Analytics**: Multimorbidity complexity scoring algorithms
- [ ] **Interactive Visualization**: Graph visualization of condition relationships
- [ ] **FHIR Integration**: Healthcare interoperability standard support
- [ ] **Clinical Terminology**: Enhanced SNOMED CT hierarchy integration
- [ ] **Multi-language Support**: International medical literature processing

## 📚 Key References

1. Head, A. et al. (2021). Inequalities in incident and prevalent multimorbidity in England, 2004–19: a population-based, descriptive study. *The Lancet Healthy Longevity*, 2(8), e489-e497.
2. Kuan, V. et al. (2019). A chronological map of 308 physical and mental health conditions from 4 million individuals in the English National Health Service. *The Lancet Digital Health*, 1(2), e63-e77.
3. The Academy of Medical Sciences. (2018). Multimorbidity: a priority for global health research.

## 📄 License

This project is licensed under the MIT License – see the LICENSE file for details.

---

**Note**: This system integrates peer-reviewed research data for educational and research purposes. Any clinical applications should undergo appropriate validation and regulatory review. The CPRD codelists are used in accordance with the original research publication's data sharing provisions.
