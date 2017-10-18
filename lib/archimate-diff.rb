# frozen_string_literal: true

require "archimate"
require 'archimate/diff/difference'
require 'archimate/diff/archimate_node_reference'
require 'archimate/diff/archimate_identified_node_reference'
require 'archimate/diff/archimate_array_reference'
require 'archimate/diff/archimate_node_attribute_reference'
require 'archimate/diff/change'
require 'archimate/diff/conflict'
require 'archimate/diff/conflicts'
require 'archimate/diff/delete'
require 'archimate/diff/insert'
require 'archimate/diff/merge'
require 'archimate/diff/move'
require "archimate/diff/version"

module Archimate
  module Diff
    module Cli
      autoload :ConflictResolver, 'archimate/diff/cli/conflict_resolver'
      autoload :Diff, 'archimate/diff/cli/diff'
      autoload :DiffSummary, 'archimate/diff/cli/diff_summary'
      autoload :Merge, 'archimate/diff/cli/merge'
      autoload :Merger, 'archimate/diff/cli/merger'
    end
  end

  # Computes the set of differences between base and remote models
  def self.diff(base, remote)
    base.diff(remote)
  end
end
