# Use an official Python runtime as a parent image
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container at /app
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Add gunicorn for production WSGI server
RUN pip install gunicorn

# Copy the rest of the application code into the container at /app
COPY . .

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Define environment variable for Flask (optional, can be set during deployment)
# ENV FLASK_APP=app.py
# ENV FLASK_ENV=production

# Run app.py when the container launches using Gunicorn
# Use 0.0.0.0 to ensure it's accessible from outside the container
# The number of workers is often set based on CPU cores, 4 is a common starting point
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "4", "app:app"] 