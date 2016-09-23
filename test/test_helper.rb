# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

TEST_EXAMPLES_FOLDER = File.join(File.dirname(__FILE__), "examples")
TEST_OUTPUT_FOLDER = File.join(File.dirname(__FILE__), "..", "tmp")

if ENV['TEST_ENV'] != 'guard'
  require 'simplecov'
  SimpleCov.start do
    add_filter "/test/"
    coverage_dir "tmp/coverage"
  end
  puts "required simplecov"
end

require 'minitest/autorun'
require 'minitest/color'
require 'faker'
require 'pp'
require 'archimate'

module Minitest
  class Test
    def build_bounds(options = {})
      x = options.fetch(:x, Faker::Number.positive)
      y = options.fetch(:y, Faker::Number.positive)
      width = options.fetch(:width, Faker::Number.positive)
      height = options.fetch(:height, Faker::Number.positive)
      Archimate::Model::Bounds.new(x: x, y: y, width: width, height: height)
    end

    def build_element(options = {})
      id = options.fetch(:id, Faker::Number.hexadecimal(8))
      type = options.fetch(:type, random_element_type)
      label = options.fetch(:label, Faker::Company.buzzword)
      documentation = options.fetch(:documentation, [])
      properties = options.fetch(:properties, [])
      Archimate::Model::Element.new(id: id, label: label, type: type, documentation: documentation, properties: properties)
    end

    def build_element_list(count)
      Archimate.array_to_id_hash((0..count).map { build_element })
    end

    def build_model(options = {})
      id = options.fetch(:id, Faker::Number.hexadecimal(8))
      name = options.fetch(:name, Faker::Company.name)
      documentation = options.fetch(:documentation, [])
      properties = options.fetch(:properties, [])
      organization = options.fetch(:organization, Archimate::Model::Organization.create)
      relationships = options.fetch(:relationships, {})
      elements = build_element_list(options.fetch(:with_elements, 0))
      elements = options.fetch(:elements, elements)
      diagrams = options.fetch(:diagrams, {})
      Archimate::Model::Model.new(
        id: id,
        name: name,
        documentation: documentation,
        properties: properties,
        elements: elements,
        organization: organization,
        relationships: relationships,
        diagrams: diagrams
      )
    end

    def build_relationship(options = {})
      id = options.fetch(:id, Faker::Number.hexadecimal(8))
      type = options.fetch(:type, random_relationship_type)
      source = options.fetch(:source, Faker::Number.hexadecimal(8))
      target = options.fetch(:target, Faker::Number.hexadecimal(8))
      name = options.fetch(:name, {})
      documentation = options.fetch(:documentation, [])
      properties = options.fetch(:properties, [])
      Archimate::Model::Relationship.new(id, type, source, target, name) do |rel|
        rel.documentation = documentation
        rel.properties = properties
      end
    end

    def build_folder(options = {})
      id = options.fetch(:id, Faker::Number.hexadecimal(8))
      type = options.fetch(:type, random_relationship_type)
      name = options.fetch(:name, Faker::Commerce.department)
      documentation = options.fetch(:documentation, [])
      properties = options.fetch(:properties, [])
      items = options.fetch(:items, [])
      folders = options.fetch(:folders, {})
      Archimate::Model::Folder.new(
        id: id,
        name: name,
        type: type,
        documentation: documentation,
        properties: properties,
        items: items,
        folders: folders
      )
    end

    def build_folders(count, min_items: 1, max_items: 10)
      return {} if count.zero?
      (0..count - 1).each_with_object({}) do |_i, a|
        folder = build_folder(
          items: (0..random(min_items, max_items)).each_with_object([]) { |_i2, a2| a2 << Faker::Number.hexadecimal(8) }
        )
        a[folder.id] = folder
      end
    end

    def build_organization(options = {})
      folders = options.fetch(:folders, build_folders(options.fetch(:with_folders, 0)))
      Archimate::Model::Organization.new(folders: folders)
    end

    def build_bendpoint(options = {})
      Archimate::Model::Bendpoint.new(
        start_x: options.fetch(:start_x, random(0, 1000)),
        start_y: options.fetch(:start_y, random(0, 1000)),
        end_x: options.fetch(:end_x, random(0, 1000)),
        end_y: options.fetch(:end_y, random(0, 1000))
      )
    end

    def random_relationship_type
      @random ||= Random.new(Random.new_seed)
      Archimate::Constants::ELEMENTS[@random.rand(Archimate::Constants::ELEMENTS.size)]
    end

    def random_element_type
      @random ||= Random.new(Random.new_seed)
      Archimate::Constants::ELEMENTS[@random.rand(Archimate::Constants::ELEMENTS.size)]
    end

    def random(min, max)
      @random ||= Random.new(Random.new_seed)
      @random.rand(max - min) + min
    end
  end
end
