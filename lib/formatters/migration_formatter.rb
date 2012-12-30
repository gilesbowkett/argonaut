module Argonaut
  class MigrationFormatter < Formatter

    def format
      @output ||= ""

      @output += header

      @stuff_to_create.each do |table_name, schema|
        @output += create_table(table_name, schema)
      end

      @output += middle

      @stuff_to_create.keys.each do |table_name|
        @output += drop_table table_name
      end

      @output += footer

      @complain ||= ''
      @output = @complain + @output

      @output
    end

    def header
      output =<<HEADER
class Create#{@class_name.pluralize.camelize} < ActiveRecord::Migration
  def self.up
HEADER
    end

    def footer
      output =<<FOOTER
  end
end
FOOTER
    end

    def create_table(table_name, schema)
      output =<<HEADER
    create_table :#{table_name.to_s.pluralize} do |table|
HEADER

      schema.attributes.sort.each do |attribute, value|
        stupid_robot_is_confused_by(attribute) if value.to_migration_label(attribute).include?("FIXME")
        output +=<<ATTRIBUTE
      table.#{value.to_migration_label(attribute)}
ATTRIBUTE
      end

      output +=<<FOOTER
    end

FOOTER

      output
    end

    def middle
      output =<<MIDDLE
  end

  def self.down
MIDDLE
    end

    def drop_table(table_name)
      output =<<DROP
    drop_table :#{table_name.to_s.pluralize}

DROP
    end

    def stupid_robot_is_confused_by(attribute)
      @complain ||= ''
      @complain += "raise 'human must adapt migration file because :#{attribute} " +
                   "attribute confuses stupid robot'\n"
    end

  end
end

