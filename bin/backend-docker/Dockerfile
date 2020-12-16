# pull official base image

FROM python:3.0-alpine

# Set work directory
WORKDIR /usr/src/app

# Set environment variables
## Prevents Python from writing pyc files to disk
ENV PYTHONDONTWRITEBYTECODE 1
## Prevents Python from buffering stdout and stderr 
ENV PYTHONUNBUFFERED 1

# Install dependencies
RUN pip install --upgrade pip
COPY ./requirements.txt .
RUN pip install -r requirements.txt

# Copy project
COPY . .
