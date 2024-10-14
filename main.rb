require 'httparty'        # HTTParty library for making HTTP requests
require 'json'            # JSON library for parsing JSON responses
require 'dotenv/load'     # Loads environment variables from the .env file

# Base URL for Canvas API and setup for headers
BASE_URL = 'https://osu.instructure.com/api/v1'
ACCESS_TOKEN = ENV['CANVAS_API_TOKEN']    # Canvas API access token loaded from environment variables
HEADERS = { "Authorization" => "Bearer #{ACCESS_TOKEN}" }  # Authorization header for API requests

# Method to get a list of currently active courses
def getCurrentCourses
  # Endpoint for retrieving courses data
  endpoint = "#{BASE_URL}/courses"
  
  # Make an HTTP GET request to retrieve active courses, including term information
  response = HTTParty.get(endpoint,
                          headers: HEADERS,
                          query: { enrollment_state: 'active', include: ['term'] })

  # Check if the response was successful (HTTP status code 200)
  if response.code == 200
    # Parse the JSON response body
    courses = JSON.parse(response.body)
    
    # Process each course and store relevant data in a hash
    courses.each_with_object({}) do |course, course_data|
      # Get the term name or default to "Other" if term information is missing
      term_name = course['term'] ? course['term']['name'] : "Other"

      # Skip courses that do not belong to a specific term (labeled as "Other")
      next if term_name == "Other"

      # Store course ID, name, and term in the hash
      course_data[course['id']] = { name: course['name'], term: term_name }
    end
  else
    # Print an error message if the API request fails
    puts "Failed to retrieve current courses: #{response.code} #{response.message}"
    {}
  end
end

# Call the method to test if it retrieves the courses successfully
courses = getCurrentCourses
# Print the retrieved courses, formatted for inspection
puts "Retrieved courses: #{courses.inspect}"
