# frozen_string_literal: true

class AddUnitedWayLAllianceOperator < ActiveRecord::Migration[5.2]
  def up
    Operator.create(name: 'United Way L’Alliance')
  end
end
