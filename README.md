README CARMEN API PROJECT, CSE 3901, 10/14/2024

A project utilizing Carmen Canva’s REST API to fetch data of a user and display a page of other users taking the same courses as them in the current semester.

AUTHORS - Jonathan Abel, Nelson Adjomo, Aidan Alexander, Nebyu Mekuanet

INSTRUCTIONS

To run the project for a specific user, you first must obtain an API access token for the user you want to check similar courses for. To do this, go to Carmen, click on Settings, and click “Generate Token”. Copy and paste that token into the .env file that is equal to the parameter inside. After doing this, save the file and close it. Open the Main.rb file, and now you can run the program by typing $ Ruby Main.rb in the terminal. The output will produce an index HTML page that you can open locally on your browser that properly displays all users that take the same courses with you, the similar courses, and the user’s names and avatars. Each author worked on one individual method to gain user information, and utilized them to format and print the information to a HTML page.
