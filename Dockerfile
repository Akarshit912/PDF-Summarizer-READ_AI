# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /app

# Install system dependencies:
# git and git-lfs for cloning the model from Hugging Face
# build-essential for compiling some Python packages
# poppler-utils for pdfplumber to process PDF files
RUN apt-get update && apt-get install -y \
    git \
    git-lfs \
    build-essential \
    poppler-utils \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Initialize Git LFS
RUN git lfs install

# Clone the model repository from Hugging Face Hub into the image
# This pre-downloads the model so it's ready on startup
RUN git clone https://huggingface.co/AR2706/read-ai-document-analysis-model ./model

# Copy the requirements file into the container
COPY requirements.txt .

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your application code into the container
COPY . .

# Expose the port the app runs on (Flask's default is 5000)
EXPOSE 5000

# Define the command to run your application using Gunicorn, a production web server
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
