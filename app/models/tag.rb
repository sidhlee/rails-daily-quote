class Tag < ApplicationRecord
  has_and_belongs_to_many :quotes

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "name", "updated_at"]
  end
end
