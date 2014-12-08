# People Against Security

## About

This was a final exam project for CSCI-5460 - Network and Information Security.
The assignment was to design a lab suitable for Undergraduate security students to complete in 4-6 hours that demonstrated something important in the area of security.
The goal of this lab is to give students a basic understanding of how seemingly minor vulnerabilities in web applications can come together to cause major problems.
The vulnerabilities covered in this lab are:

* A well-intentioned, yet insecure download feature that allows users to gain access to files on the server (the source code itself)
* A misplaced check for authentication instead of authorization, allowing access to user management (allowing privilege escalation)
* A database backup function that is available to anyone with the "Administrator" privilege that does nothing else to protect the database (e.g. No encryption or limiting to specific users).
* And an outdated password hashing scheme (MD5 with no salt)

My goal was to give a practical overview of how these concepts could be applied, rather than going into the complexities that are more common in real life.

Please note: This application is the total opposite of a good example of secure web development practices. It should only be used for it's intended purpose. That is, to teach others about the importance of security throughout a web application.

## Instructions

### Setup

1. Provide a wordlist or use the sample provided.
    * e.g. `mv wordlist.txt.example wordlist.txt`
1. Test it before distributing to students
    1. Make sure you have the proper dependencies installed
        * Ruby 2.1
        * Sqlite3
    1. In a terminal, `cd` to the project directory.
        1. `bundle install` - Installs project dependencies
        1. `bundle exec rake test` - Runs the test suite
            * If there are no errors, you should be good to go.
            * If there are errors, they need to be resolved or your students may have problems.
1. Distribute the application to students using your preferred medium.
    1. "zip, 7z, tar.gz, etc." the entire PAS directory.
    1. Send it to them along with a copy of `doc/lab-instructions.docx`. This includes instructions to setup PAS as well as the requirements for the lab.
