GraphRAG Medical Analysis System specialising in multimorbidity patterns and clinical case studies
•	A research-grade graph-based Retrieval-Augmented Generation (RAG) system for complex medical document analysis, specialising in multimorbidity patterns and clinical case studies. Enhanced with validated clinical data from peer-reviewed multimorbidity research.
•	The aim is to combine knowledge graphs and large language models to analyse medical documents, extract clinical relationships, and provide intelligent querying for healthcare research and clinical decision support.

Context  
The open-source GitHub repository shares the code lists for our analysis of trends in multimorbidity between 2004 - 2019 in England, using CPRD Aurum data. The results of our analysis are published in The Lancet Healthy Longevity as Inequalities in incident and prevalent multimorbidity in England, 2004–19: a population-based, descriptive study - https://github.com/annalhead/CPRD_multimorbidity_codelists  
•	Publication: "Inequalities in incident and prevalent multimorbidity in England, 2004–19: a population-based, descriptive study"  
•	Journal: The Lancet Healthy Longevity ([DOI: 10.1016/S2666-7568(21)00146-X](https://doi.org/10.1016/S2666-7568(21)00146-X))  
•	Lead Researcher: Anna Head, University of Liverpool/SPHR PhD Student  
•	Dataset: 211 chronic conditions across 15 body systems with rigorous clinical validation

Definition  
The study uses the following multimorbidity definitions:  
•	Basic multimorbidity - two or more chronic diseases.  
•	Complex multimorbidity - “three or more chronic conditions affecting three or more different body systems” (Harrison, C. et al. 2014. ‘Examining different measures of multimorbidity, using a large prospective cross-sectional study in Australian general practice’, BMJ Open)

The definition of multimorbidity by the research team included sequalae of certain conditions, e.g. diabetes and diabetic neuropathy, and did not allow ‘recovery’ from a condition. We chose to include these because of the differing impact on health outcomes associated with coexistence of sequalae, and of the likely impact of these conditions on future health, to healthcare usage, or to future risk of ill health.

Datasets in the CPRD Aurum data  
1.	DiseaseSummary.csv - this is a list of chronic conditions of interest for the study, narrowed down from the 308 diseases phenotypes by CALIBER. 'Disease' is condition the name in the CALIBER list, 'Disease_mod' is our amended name. The variables 'disease_num' & 'system_num' are arbitrary variables for ease of coding. 'type' refers to whether a single code ever recorded is sufficient, or whether a multivisit criteria (at least 3 visits within 1 year) is required; conditions with an empty type are from test values only. 'testvalues' (yes/no) is for whether test values are used for this condition.
2.	codelists - .csv files for each disease - codes for test results are in the 'tests' subfolder. the 'mapping' column is how the Aurum code was derived from the CALIBER GOLD lists: a. cleansedreadcode - GOLD Read code matched Aurum 'cleansedreadcode' b. originalreadcode - GOLD Read code matched Aurum 'originalreadcode' c. description - GOLD description matched Aurum 'term' d. termsearch - codes identified by searching Aurum for similar terms to original CALIBER GOLD list
3.	DiseaseDocumentation - this shows the codelists along with notes on implementation. The .md file is too large to be rendered
4.	Summary: CPRD Multimorbidity Dataset:
  - 216 validated chronic conditions from Lancet-published research
  - 211 detailed CSV codelists with SNOMED CT codes
  - 15 body systems comprehensively mapped
  - Research-grade data from English primary care (2004-2019)

Value Proposition of study:  
  1. Population-level multimorbidity analysis using validated research data  
  2. Cross-system relationship discovery across 15 body systems  
  3. Evidence-based insights from Lancet-published methodology  
  4. SNOMED CT standardization for clinical terminology

The CPRD multimorbidity analysis:  
  This will test (python test_hypothesis.py):  
  - Cardiovascular-diabetes clustering (using real CPRD conditions)  
  - Complex multimorbidity patterns (across multiple body systems)  
  - Code mapping effectiveness (SNOMED CT validation)  
  - System burden analysis (condition distribution)

Key Findings  
  1. Cardiovascular-Diabetes Clustering  
  - 48 conditions (22.2%) in combined cardio-endocrine systems  
  - Strong clustering evidence: 3 diabetes variants + 3 heart conditions  
  - Clinical significance: Validates known multimorbidity patterns

  2. Complex Multimorbidity Cross-System Patterns  
  - 15 body systems with 20x burden ratio (highly uneven)  
  - 5 major multimorbidity patterns identified:  
    - Cardiovascular (5 conditions)  
    - Metabolic (5 conditions)  
    - Respiratory (4 conditions)  
    - Mental Health (4 conditions)  
    - Renal (3 conditions)

  3. SNOMED CT Code Mapping Effectiveness  
  - 100% SNOMED CT coverage across sample conditions  
  - 488 validated medical codes analysed  
  - Multiple mapping methods ensuring comprehensive coverage

  4. System Burden Distribution  
  - Cancers leads with 40 conditions (18.5%)  
  - Circulatory system follows with 36 conditions (16.7%)  
  - 20x variation between the highest and lowest
