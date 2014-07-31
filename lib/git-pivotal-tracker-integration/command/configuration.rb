# Git Pivotal Tracker Integration
# Copyright (c) 2013 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'git-pivotal-tracker-integration/command/command'
require 'git-pivotal-tracker-integration/util/git'
require 'highline/import'
require 'pivotal-tracker'
require "github_api"

# A class that exposes configuration that commands can use
class GitPivotalTrackerIntegration::Command::Configuration

  def base_remote
    branch = GitPivotalTrackerIntegration::Util::Git.get_config "pivotal.main-remote"

    if (branch.empty?)
      branch = ask("What remote should I pull from to start a new branch? ")
      GitPivotalTrackerIntegration::Util::Git.set_config("pivotal.main-remote", branch, :local)
    end
    branch
  end

  def base_branch
    branch = GitPivotalTrackerIntegration::Util::Git.get_config "pivotal.main-branch"

    if (branch.empty?)
      branch = ask("What branch should I base the new branches off of? ")
      GitPivotalTrackerIntegration::Util::Git.set_config("pivotal.main-branch", branch, :local)
    end
    branch
  end

  def personal_remote
    remote = GitPivotalTrackerIntegration::Util::Git.get_config "pivotal.personal-remote"

    if (remote.empty?)
      remote = ask("What remote should I push your topic branches to? ")
      GitPivotalTrackerIntegration::Util::Git.set_config("pivotal.personal-remote", remote, :local)
    end
    remote
  end

  def github
    token = GitPivotalTrackerIntegration::Util::Git.get_config GITHUB_API_OAUTH_TOKEN

    if (token.empty?)
      token = ask("Github OAuth Token (help.github.com/articles/creating-an-access-token-for-command-line-use): ").strip
      GitPivotalTrackerIntegration::Util::Git.set_config(GITHUB_API_OAUTH_TOKEN, token, :local)
    end

    organization = GitPivotalTrackerIntegration::Util::Git.get_config GITHUB_API_ORG_TOKEN
    if (organization.empty?)
      organization = ask("Github organization? (should be ziplist): ").strip
      GitPivotalTrackerIntegration::Util::Git.set_config(GITHUB_API_ORG_TOKEN, organization, :local)
    end

    repo = GitPivotalTrackerIntegration::Util::Git.get_config GITHUB_API_REPO_TOKEN
    if (repo.empty?)
      repo = ask("Github repo? (should be ziplist): ").strip
      GitPivotalTrackerIntegration::Util::Git.set_config(GITHUB_API_REPO_TOKEN, repo, :local)
    end

    user = GitPivotalTrackerIntegration::Util::Git.get_config GITHUB_API_USER_TOKEN
    if (user.empty?)
      user = ask("Github user? (should be ziplist): ").strip
      GitPivotalTrackerIntegration::Util::Git.set_config(GITHUB_API_USER_TOKEN, user, :local)
    end

    ::Github.new(:oauth_token => token, :org => organization, :repo => repo, :user => user)
  end

  def github_username
    uname = GitPivotalTrackerIntegration::Util::Git.get_config GITHUB_API_USERNAME_TOKEN

    if (uname.empty?)
      uname = ask("Your Github username (same remote as origin): ").strip
      GitPivotalTrackerIntegration::Util::Git.set_config(GITHUB_API_USERNAME_TOKEN, uname, :local)
    end
    uname
  end

  # Returns the user's Pivotal Tracker API token.  If this token has not been
  # configured, prompts the user for the value.  The value is checked for in
  # the _inherited_ Git configuration, but is stored in the _local_ Git
  # configuration so that it can be used across multiple repositories.
  #
  # @return [String] The user's Pivotal Tracker API token
  def api_token
    api_token = GitPivotalTrackerIntegration::Util::Git.get_config KEY_API_TOKEN, :inherited

    if api_token.empty?
      api_token = ask('Pivotal API Token (found at https://www.pivotaltracker.com/profile): ').strip
      GitPivotalTrackerIntegration::Util::Git.set_config KEY_API_TOKEN, api_token, :local
      puts
    end

    api_token
  end

  # Returns the Pivotal Tracker project id for this repository.  If this id
  # has not been configuration, prompts the user for the value.  The value is
  # checked for in the _inherited_ Git configuration, but is stored in the
  # _local_ Git configuration so that it is specific to this repository.
  #
  # @return [String] The repository's Pivotal Tracker project id
  def project_id
    project_id = GitPivotalTrackerIntegration::Util::Git.get_config KEY_PROJECT_ID, :inherited

    if project_id.empty?
      project_id = choose do |menu|
        menu.prompt = 'Choose project associated with this repository: '

        PivotalTracker::Project.all.sort_by { |project| project.name }.each do |project|
          menu.choice(project.name) { project.id }
        end
      end

      GitPivotalTrackerIntegration::Util::Git.set_config KEY_PROJECT_ID, project_id, :local
      puts
    end

    project_id
  end

  def pivotal_full_name
    full_name = GitPivotalTrackerIntegration::Util::Git.get_config KEY_PIVOTAL_NAME

    if full_name.empty?
      api_token = ask('Pivotal Full Name (found at https://www.pivotaltracker.com/profile): ').strip
      GitPivotalTrackerIntegration::Util::Git.set_config KEY_PIVOTAL_NAME, full_name, :local
      puts
    end

    full_name
  end

  # Returns the story associated with the current development branch
  #
  # @param [PivotalTracker::Project] project the project the story belongs to
  # @return [PivotalTracker::Story] the story associated with the current development branch
  def story(project)
    story_id = GitPivotalTrackerIntegration::Util::Git.get_config KEY_STORY_ID, :branch
    project.stories.find story_id.to_i
  end

  # Stores the story associated with the current development branch
  #
  # @param [PivotalTracker::Story] story the story associated with the current development branch
  # @return [void]
  def story=(story)
    GitPivotalTrackerIntegration::Util::Git.set_config KEY_STORY_ID, story.id, :branch
  end

  private

  KEY_API_TOKEN = 'workflow.pivotal.api-token'.freeze

  KEY_PROJECT_ID = 'workflow.pivotal.project-id'.freeze
  KEY_PIVOTAL_NAME = 'workflow.pivotal.full-namel'.freeze

  KEY_STORY_ID = 'workflow.pivotal-story-id'.freeze

  GITHUB_API_OAUTH_TOKEN = 'workflow.github.oauth'.freeze
  GITHUB_API_REPO_TOKEN = 'workflow.github.repo'.freeze
  GITHUB_API_ORG_TOKEN = 'workflow.github.org'.freeze
  GITHUB_API_USER_TOKEN = 'workflow.github.user'.freeze
  GITHUB_API_USERNAME_TOKEN = 'workflow.github.username'.freeze

end
