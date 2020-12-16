# pull official base image

FROM python:3.8.3-alpine

# Set work directory
WORKDIR /usr/src/app

# Set environment variables
## Prevents Python from writing pyc files to disk
ENV PYTHONDONTWRITEBYTECODE 1
## Prevents Python from buffering stdout and stderr 
ENV PYTHONUNBUFFERED 1

# Install dependencies
RUN pip install --upgrade pip
## Install psycopg2 dependencies
RUN apk update
RUN apk add postgresql-dev gcc python3-dev musl-dev
COPY ./requirements.txt .
RUN pip install -r requirements.txt

# Copy entrypoint.sh
COPY ./entrypoint.sh .

# Copy project
COPY . .

# Run entrypoint.sh
ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
