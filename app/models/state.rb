class State < ActiveRecord::Base
  has_many :businesses

  def to_s
    self.state
  end
end
