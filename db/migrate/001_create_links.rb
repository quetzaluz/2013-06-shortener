# Put your database migration here!
#
# Each one needs to be named correctly:
# timestamp_[action]_[class]
#
# and once a migration is run, a new one must
# be created with a later timestamp.

class CreateLinks < ActiveRecord::Migration
  def change
    create_table(:links) do |t|
      t.column :token, :text
      t.column :url, :text
    end
  end
end