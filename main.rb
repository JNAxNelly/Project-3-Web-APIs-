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

# Method to get roster for each course with pagination handling
def getRoster(course_ids)
  course_rosters = {}

  course_ids.each do |course_id|
    puts "Fetching roster for Course ID: #{course_id}"
    endpoint = "#{BASE_URL}/courses/#{course_id}/users"
    course_rosters[course_id] = []

    loop do
      response = HTTParty.get(endpoint,
                              headers: HEADERS,
                              query: { enrollment_type: 'student', include: ['avatar_url'] })

      if response.code == 200
        roster = JSON.parse(response.body)
        course_rosters[course_id].concat(roster.map { |student| { name: student['name'], avatar_url: student['avatar_url'], id: student['id'] } })

        # Check for pagination
        next_link = response.headers['link']&.match(/<([^>]+)>; rel="next"/)
        if next_link
          endpoint = next_link[1]
        else
          break
        end
      else
        puts "Failed to retrieve roster for Course ID #{course_id}: #{response.code} #{response.message}"
        break
      end
    end

    puts "Roster for Course ID #{course_id}: #{course_rosters[course_id].map { |student| student[:name] }}"
  end

  course_rosters
end

# Call the method to test if it retrieves the courses successfully
courses = getCurrentCourses
# Print the retrieved courses, formatted for inspection
puts "Retrieved courses: #{courses.inspect}"

# Extract course IDs
course_ids = courses.keys

# Call the method to retrieve the roster for each course
rosters = getRoster(course_ids)

# Method to find overlapping students across courses, excluding the current user
def findOverlap(rosters, current_user_id)
  student_courses = Hash.new { |hash, key| hash[key] = [] }

  # Populate the student_courses hash with courses each student is in, including avatars
  rosters.each do |course_id, students|
    students.each do |student|
      next if student[:id] == current_user_id  # Exclude the current user by ID
      student_courses[student[:name]] << { course_id: course_id, avatar_url: student[:avatar_url] }
    end
  end

  # Filter students who are enrolled in more than one course
  overlapping_students = student_courses.select { |student, courses| courses.size > 1 }

  # Output overlapping students and the courses they’re enrolled in
  overlapping_students.each do |student, courses|
    course_list = courses.map { |entry| entry[:course_id] }.join(", ")
    puts "#{student} is enrolled in multiple courses: #{course_list}"
  end

  overlapping_students
end