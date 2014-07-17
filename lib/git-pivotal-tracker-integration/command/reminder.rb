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
require 'pivotal-tracker'

# The class that encapsulates displaying the current story details / notes
class GitPivotalTrackerIntegration::Command::Reminder < GitPivotalTrackerIntegration::Command::Base

  def run(filter)
    branch_name = GitPivotalTrackerIntegration::Util::Git.branch_name
    piv_story = a.match(/([\d]+)\-/)[1]
    if (piv_story)
      story = GitPivotalTrackerIntegration::Util::Story.select_story @project, piv_story
      GitPivotalTrackerIntegration::Util::Story.pretty_print story
    end
  end
end
