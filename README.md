# NearbyQ Backend API

## Overview
Backend API for NearbyQ, a location-based Q&A platform that enables users to post questions relevant to specific locations and get answers from people nearby. The API manages user authentication, questions, answers, favorites, and location-based queries.

## Features
- **User Authentication**: JWT-based authentication with Devise
- **Questions Management**: Create, read, update and delete questions
- **Answers Management**: Post and manage answers to questions
- **Location-based Queries**: Find questions based on geographic proximity
- **Favorites System**: Save and manage favorite questions

## Technology Stack
- **Ruby on Rails**: Version 8.0.2 - API only mode
- **MongoDB**: NoSQL database using Mongoid ODM
- **Authentication**: Devise with JWT for token-based authentication
- **Geolocation**: Geocoder gem for location-based queries
- **CORS**: Rack-CORS for cross-origin resource sharing

## Prerequisites
- Ruby 3.3.7
- MongoDB 5.0 or higher
- Bundler gem

## Installation and Setup

1. Clone the repository
    git clone https://github.com/ENNEDDI-Omar/dabadoc-nearby-questions-api.git
    cd dabadoc-nearby-questions-api

2. Install dependencies
    bundle install

3. Set up environment variables
    Create a `.env` file in the root directory with the following variables:
    SECRET_KEY_BASE=your_secret_key_base
    MONGODB_URI=mongodb://localhost:27017/nearbyq_development

You can generate a secure key using:
   rails secret

4. Start the server
   rails server -p 3000

## API Documentation

### Authentication Endpoints
- `POST /api/v1/signup` - Register a new user
- `POST /api/v1/login` - Sign in a user
- `DELETE /api/v1/logout` - Sign out a user

#### Registration Example
```json
    POST /api/v1/signup
    Content-Type: application/json
    
    {
    "name": "Example User",
    "email": "user@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "location": {
     "latitude": 33.5731,
     "longitude": -7.5898
    }
    }
```

#### Login Example
```json
    POST /api/v1/login
    Content-Type: application/json
    
    {
      "email": "user@example.com",
      "password": "password123"
    }
```
## Project Structure

app/controllers/api/v1 - API controllers for the application
app/models - MongoDB models for the application
config/routes.rb - API route definitions
config/initializers - Configuration files for Devise, JWT, Mongoid, etc.

## Questions Endpoints

GET /api/v1/questions - List all questions (with optional location parameters)
GET /api/v1/questions/:id - Show a specific question
POST /api/v1/questions - Create a new question
PUT /api/v1/questions/:id - Update a question
DELETE /api/v1/questions/:id - Delete a question


## Answers Endpoints

GET /api/v1/questions/:question_id/answers - List answers for a question
POST /api/v1/questions/:question_id/answers - Create a new answer
PUT /api/v1/questions/:question_id/answers/:id - Update an answer
DELETE /api/v1/questions/:question_id/answers/:id - Delete an answer

## Favorites Endpoints

GET /api/v1/favorites - List user's favorite questions
POST /api/v1/questions/:question_id/favorites - Add a question to favorites
DELETE /api/v1/questions/:question_id/favorites - Remove a question from favorites


      