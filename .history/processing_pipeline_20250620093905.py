def load_and_chunk_documents() -> List[Document]:
    """Load and chunk .docx files using semantic chunking"""
    documents = []
    docx_files = glob.glob("./documents/*.docx")  # Adjust path as needed
    
    if not docx_files:
        print("No .docx files found")
        return documents
    
    # Initialize semantic chunker
    text_splitter = SemanticChunker(embeddings)
    
    for docx_file in docx_files:
        print(f"Processing {docx_file}...")
        
        # Load document
        loader = Docx2txtLoader(docx_file)
        raw_docs = loader.load()
        
        # Apply semantic chunking
        chunks = text_splitter.split_documents(raw_docs)
        
        # Add metadata
        for chunk in chunks:
            chunk.metadata["source"] = os.path.basename(docx_file)
        
        documents.extend(chunks)
    
    print(f"pyLoaded {len(documents)} document chunks")
    return documents