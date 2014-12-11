# People Against Security

## About

This was a final exam project for CSCI-5460 - Network and Information Security.
The assignment was to design a lab suitable for Undergraduate Computer Science students to complete in 4-6 hours that demonstrated something important in the area of security.
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
    * e.g. `cp wordlist.txt.example wordlist.txt`
    * Random passwords are chosen from `wordlist.txt` when the application starts to seed the database. `wordlist.txt` is then used by the student to crack the hashes they recover. This avoids overcomplicating the password cracking phase of the lab. If you wish you make it more difficult, provide a complex `wordlist.txt` here and distribute a simplified version to students. Then inform them to use something more complex such as a rule-based attack to attempt to recover the passwords.
1. Test it before distributing to students
    1. Make sure you have the proper dependencies installed
        * Ruby 2.1
            * bundler - `gem install bundler`
        * Sqlite3
    1. In a terminal, `cd` to the project directory.
        1. `bundle install` - Installs project dependencies
        1. `bundle exec rake test` - Runs the test suite
            * If there are no errors, you should be good to go.
                * Unless you chose to enhance the difficulty of password cracking. Then, you should run the application `rackup`, retrieve the generated passwords from `pas.db` that was just created, and determine that these hashes can be cracked with the information you have chosen to provide.
            * If there are errors, they need to be resolved or your students may have problems.
1. Distribute the application to students using your preferred medium.
    1. `bundle exec rake build`
        * Automatically includes wordlist.txt into the gem
            * Required to generate passwords for the fake users
        * Creates a self-contained gem in pkg/ that should be distributed to students
    1. "zip, 7z, tar.gz, etc." 
        * `pkg/people_against_security.x.y.z.gem` 
        * `wordlist.txt`
            * If you want to make password cracking more difficult, this would be the simplified version of `wordlist.txt`
        * `setup.sh` This configures a fresh Kali Linux installation (likely in a VM) to run PAS.
        * Example: `zip -r pas-lab.zip pkg/people_against_security.x.y.z.gem wordlist.txt setup.sh`
    1. Send it to students along with a copy of `doc/lab-instructions.docx`.
This includes instructions to setup PAS as well as the requirements for the lab.
