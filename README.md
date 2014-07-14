# Git Pivotal Tracker Integration
[![Build Status](https://travis-ci.org/nebhale/git-pivotal-tracker-integration.svg?branch=master)](https://travis-ci.org/nebhale/git-pivotal-tracker-integration)
[![Gem Version](https://badge.fury.io/rb/git-pivotal-tracker-integration.png)](http://badge.fury.io/rb/git-pivotal-tracker-integration)
[![Dependency Status](https://gemnasium.com/nebhale/git-pivotal-tracker-integration.svg)](https://gemnasium.com/nebhale/git-pivotal-tracker-integration)
[![Code Climate](https://codeclimate.com/github/nebhale/git-pivotal-tracker-integration.svg)](https://codeclimate.com/github/nebhale/git-pivotal-tracker-integration)


`git-pivotal-tracker-integration` provides a set of additional Git commands to help developers when working with [Pivotal Tracker][pivotal-tracker].

[pivotal-tracker]: http://www.pivotaltracker.com


## Installation
`git-pivotal-tracker-integration` requires at least **Ruby 1.8.7** and **Git 1.8.2.1** in order to run.  It is tested against Rubies _1.8.7_, _1.9.3_, and _2.0.0_.  In order to install it, do the following:

```plain
$ gem install git-pivotal-tracker-integration
```


## Usage
`git-pivotal-tracker-integration` is intended to be a very lightweight tool, meaning that it won't affect your day to day workflow very much.  To be more specific, it is intended to automate branch creation and destruction as well as story state changes, but will not affect when you commit, when development branches are pushed to origin, etc.  The typical workflow looks something like the following:

```plain
$ git start       # Creates branch and starts story
$ git commit ...
$ git commit ...  # Your existing development process
$ git commit ...
$ git finish      # Pushes branch, finishes pivotal story, creates PR.
```


## Configuration

### Git Client
In order to use `git-pivotal-tracker-integration`, two Git client configuration properties must be set.  If these properties have not been set, you will be prompted for them and your Git configuration will be updated.

| Name | Description
| ---- | -----------
| `pivotal.api-token` | Your Pivotal Tracker API Token.  This can be found in [your profile][profile] and should be set globally.
| `pivotal.project-id` | The Pivotal Tracker project id for the repository your are working in.  This can be found in the project's URL and should be set.

[profile]: https://www.pivotaltracker.com/profile


### Git Server
In order to take advantage of automatic issue completion, the [Pivotal Tracker Source Code Integration][integration] must be enabled.  If you are using GitHub, this integration is easy to enable by navgating to your project's 'Service Hooks' settings and configuring it with the proper credentials.

[integration]: https://www.pivotaltracker.com/help/integrations?version=v3#scm


## Commands

### `git start [ type | story-id ]`
This command starts a story by creating a Git branch and changing the story's state to `started`.  This command can be run in three ways.  First it can be run specifying the id of the story that you want to start.

```plain
$ git start 12345678
```

The second way to run the command is by specyifying the type of story that you would like to start.  In this case it will then offer you the first five stories (based on the backlog's order) of that type to choose from.

```plain
$ git start feature

1. Lorem ipsum dolor sit amet, consectetur adipiscing elit
2. Pellentesque sit amet ante eu tortor rutrum pharetra
3. Ut at purus dolor, vel ultricies metus
4. Duis egestas elit et leo ultrices non fringilla ante facilisis
5. Ut ut nunc neque, quis auctor mauris
Choose story to start:
```

Finally the command can be run without specifying anything.  In this case, it will then offer the first five stories (based on the backlog's order) of any type to choose from.

```plain
$ git start

1. FEATURE Donec convallis leo mi, dictum ornare sem
2. CHORE   Sed et magna lectus, sed auctor purus
3. FEATURE In a nunc et enim tincidunt interdum vitae et risus
4. FEATURE Fusce facilisis varius lorem, at tristique sem faucibus in
5. BUG     Donec iaculis ante neque, ut tempus augue
Choose story to start:
```

Once a story has been selected by one of the three methods, the command then prompts for the name of the branch to create.

```plain
$ git start 12345678
        Title: Lorem ipsum dolor sit amet, consectetur adipiscing elitattributes
  Description: Ut consequat sapien ut erat volutpat egestas. Integer venenatis lacinia facilisis.

Enter branch name (12345678-<branch-name>):
```

The value entered here will be prepended with the story id such that the branch name is `<story-id>-<branch-name>`.  This branch is then created and checked out.

If it doesn't exist already, a `prepare-commit-msg` commit hook is added to your repository.  This commit hook augments the existing commit messsage pattern by appending the story id to the message automatically.

```plain

[#12345678]
# Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
# On branch 12345678-lorem-ipsum
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#	new file:   dolor.txt
#
```

### `git finish`
This command finishes a story pushing it up to origin.
Then it sets up a PR to ziplist/ziplist.
And finishes the Pivotal tracker issue.
