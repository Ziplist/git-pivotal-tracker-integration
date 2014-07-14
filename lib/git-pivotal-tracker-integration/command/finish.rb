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

    GitPivotalTrackerIntegration::Util::Git.update_from_master
    GitPivotalTrackerIntegration::Util::Git.push GitPivotalTrackerIntegration::Util::Git.branch_name

    github = config.github
require 'pry'
    binding.pry
    abort("Create the PR now?")
  end

end
