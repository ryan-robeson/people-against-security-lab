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

Please note: This application is the total opposite of a good example of secure web development practices.
It should only be used for it's intended purpose.
That is, to teach others about the importance of security throughout a web application.

## Instructions

### Setup

1. Provide a wordlist or use the sample provided.
    * e.g. `cp wordlist.txt.example wordlist.txt`
    * Random passwords are chosen from `wordlist.txt` when the application starts to seed the database.
      `wordlist.txt` is then used by the student to crack the hashes they recover.
      This avoids overcomplicating the password cracking phase of the lab.
      If you wish you make it more difficult, provide a complex `wordlist.txt` here and distribute a simplified version to students.
      Then inform them to use something more complex such as a rule-based attack to attempt to recover the passwords.
1. Test it before distributing to students
    1. Make sure you have the proper dependencies installed
        * Ruby 2.1
            * bundler - `gem install bundler`
        * Sqlite3
    1. In a terminal, `cd` to the project directory.
        1. `bundle install` - Installs project dependencies
        1. `bundle exec rake test` - Runs the test suite
            * If there are no errors, you should be good to go.
                * Unless you chose to enhance the difficulty of password cracking.
                  Then, you should run the application `rackup`, retrieve the generated passwords from `pas.db` that was just created,
                  and determine that these hashes can be cracked with the information you have chosen to provide.
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

### Customizing

These files have the most impact on the non-technical aspects of this lab.
They should be updated to reflect your situation and use case.
Most modifications to these files are specific to your needs, and therefore would not benefit the project as a whole.
If you have general improvements that would benefit other users of this project, see [Contributing](#contributing).

#### wordlist.txt

This is the file that passwords are pulled from.
The original lab format keeps things simple and uses this when assigning passwords to fake users and when the students are "cracking" the password hashes.
This is simply a newline-separted file of potential passwords.
If you have 20 or 30 students, you should probably include several hundred fake passwords in this file to keep everyone from getting the same list of passwords.
To add more focus on password cracking to this lab, you could fill this list with complex passwords and give students a more basic list.
They could then use that list with some of the different "attack modes" of hashcat to recover the passwords, rather than a simple lookup.
You should test this list and determine how reasonable it is before expecting students to complete the challenge.

#### doc/lab-instructions.md

This file contains the instructions for the lab that you should distribute to students.
You should review these instructions and update them if they do not meet your needs.
If you choose to change the lab, such as making the passwords more difficult, you should update the instructions to include what is required to complete it.
To generate the docx version of the instructions, run `bundle exec rake instructions`.

#### doc/solution.md

This is an example solution based on the given instructions.
It gives an idea of what students will be submitting upon completion of this lab.
This document is for your benefit.
It is not intended to be shared with students.
However, that is up to you.
It is recommended that you update this if you change the instructions so that you will have an example of what you are expecting.
To generate the docx version of the solution, run `bundle exec rake instructions`.

### Preventing Cheating

#### You posted this all online. Can't my students just find it and copy the answers?

Of course. However, this app randomly picks passwords from wordlist.txt when it starts.
As long as you create a sufficiently long wordlist, each list of passwords submitted should be unique.
This goes for email addresses as well.
They are generated when the program starts, and while not guaranteed to be completely unique among students, are sufficiently random that a duplicate submission would be obvious.

#### Can't they just access the database that gets created?

Currently the database is hidden when students run the program.
I have some ideas to make it more difficult for them to access, but I'm not going to spend time implementing them if nobody shows interest in this project.
With that said, feel free to create an [issue](https://github.com/ryan-robeson/people-against-security-lab/issues) if you are interested.

#### Is there anything else I can do?

Requiring screenshots of each step in the process will make cheating much easier to detect.
There should be unique data on most of the screens, and multiple students should not have the same exact screenshots.

## Have questions?

Feel free to create an [issue](https://github.com/ryan-robeson/people-against-security-lab/issues) and I will do my best to answer them.

## License

See the [LICENSE](LICENSE.txt) file.

## Developing

### Requirements

* Ruby 2.1
    * bundler
* Sqlite3

### Example Workflow

1. Fork / Clone this repo.
1. `bundle install`
1. Make a feature branch - `git checkout -b some-awesome-new-feature`
1. Create a wordlist or `cp wordlist.txt.example wordlist.txt`
1. Make sure the tests pass - `bundle exec rake test`
1. `bundle exec guard`
    * Starts a development server that reloads when code changes.
    * Starts a livereload server that refreshes the browser when views change.
    * Runs tests when code changes.
1. Add the new feature and tests that cover it.
1. Get all tests passing.
1. [Share](CONTRIBUTING.md) your work.


## Contributing

Improvements and fixes are much appreciated. Check out [CONTRIBUTING.md](CONTRIBUTING.md) to see how to share your work.
