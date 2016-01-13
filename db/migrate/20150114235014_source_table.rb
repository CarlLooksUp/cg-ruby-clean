class SourceTable < ActiveRecord::Migration
  def up
  	Source.create id: 2, source: 'User Submitted; proof of use'
  	Source.create id: 3, source: 'User Submitted; not currently in use'
  	Source.create id: 4, source: 'User Submitted; no proof of use'
  	Source.create id: 5, source: 'State Corporation'
  	Source.create id: 6, source: 'State Trademark'
  	Source.create id: 7, source: 'Federal Trademark'
  end
end
