# Use official Python runtime as base image
FROM python:3.9-slim

# Set working directory in container
WORKDIR /app

# Copy the Python script to container
COPY test.py .

# Run the script when container launches
CMD ["python", "test.py"]