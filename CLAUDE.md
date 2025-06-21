# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a graph-based processing system with RAG (Retrieval-Augmented Generation) capabilities. The project appears to be in early development with the following intended architecture:

- `graph.py`: Core graph data structure and operations
- `processing_pipeline.py`: Data processing pipeline functionality
- `tests/test_connection.py`: Connection testing functionality
- `tests/test_rag.py`: RAG system testing

## Development Commands

Since this is a Python project with a requirements.txt file:

- Install dependencies: `pip install -r requirements.txt`
- Run tests: `python -m pytest tests/`
- Run specific test: `python -m pytest tests/test_connection.py` or `python -m pytest tests/test_rag.py`

## Architecture Notes

The project follows a modular design separating graph operations from processing pipeline logic. The test structure suggests the system will handle both connection management and RAG-based operations.