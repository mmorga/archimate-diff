# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class Conflicts
      class DeletedItemsReferencedConflictTest < Minitest::Test
        def test_element_deleted_referenced_in_relationship
          model = build_model(with_elements: 1, with_relationships: 1)
          thing = model.lookup(model.relationships.first.source)
          diff1 = Diff::Delete.new(ArchimateArrayReference.new(thing.parent, thing.parent_attribute_name))
          diff2 = Diff::Insert.new(ArchimateArrayReference.new(model.relationships, 0))
          subject = DeletedItemsReferencedConflict.new([diff1], [diff2])

          assert subject.diff_conflicts(diff1, diff2)
        end

        def test_diagram_attr_update_conflicts_with_deleted_child_element
          base = build_model(with_elements: 1)
          deleted_element_id = base.elements.first.id
          local = base.with(elements: [])
          remote = base.with(
            diagrams: [
              build_diagram(
                nodes:
                  [build_view_node(archimate_element: deleted_element_id)]
              )
            ]
          )

          diffs2 = base.diff(remote)
          non_organization_diffs2 = diffs2.reject { |diff| diff.target.path =~ /^organizations/ }
          assert_equal 1, non_organization_diffs2.size
          diffs1 = base.diff(local)
          non_organization_diffs1 = diffs1.reject { |diff| diff.target.path =~ /^organizations/ }
          assert_equal 1, non_organization_diffs1.size

          subject = DeletedItemsReferencedConflict.new(diffs1, diffs2)

          assert subject.diff_conflicts(non_organization_diffs1[0], non_organization_diffs2[0])
        end
      end
    end
  end
end
