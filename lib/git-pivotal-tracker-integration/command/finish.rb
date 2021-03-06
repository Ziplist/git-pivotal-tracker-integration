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

require 'git-pivotal-tracker-integration/command/base'
require 'git-pivotal-tracker-integration/command/command'
require 'git-pivotal-tracker-integration/util/git'
require 'git-pivotal-tracker-integration/util/story'

# The class that encapsulates finishing a Pivotal Tracker Story
class GitPivotalTrackerIntegration::Command::Finish < GitPivotalTrackerIntegration::Command::Base

  # Finishes a Pivotal Tracker story by doing the following steps:
  # * CHeck tha
  # * Merge the development branch into the root branch
  # * Delete the development branch
  # * Push changes to remote
  #
  # @return [void]
  def run(argument)
    no_complete = argument =~ /--no-complete/
    config = GitPivotalTrackerIntegration::Command::Configuration.new
    branch_name = GitPivotalTrackerIntegration::Util::Git.branch_name

    GitPivotalTrackerIntegration::Util::Git.verify_uncommitted_changes!

    GitPivotalTrackerIntegration::Util::Git.update_from_master
    GitPivotalTrackerIntegration::Util::Git.push branch_name

    piv_story = branch_name.match(/([\d]+)\-/)[1]
    story = GitPivotalTrackerIntegration::Util::Story.select_story @project, piv_story

    github = config.github

    pr = github.pull_requests.create(
      user: github.user,
      repo: github.repo,
      base: config.base_branch,
      head: "#{config.github_username}:#{branch_name}",
      title: "Fixing #{branch_name}",
      body: "# #{story.name}\n\n#{story.description}\n\n\n## Pivotal Task: #{story.url}"
    )

    GitPivotalTrackerIntegration::Util::Shell.exec "git checkout #{config.base_branch}"
    GitPivotalTrackerIntegration::Util::Shell.exec "git pull #{config.base_remote} #{config.base_branch}"
  end
end
