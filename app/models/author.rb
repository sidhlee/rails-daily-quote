class Author < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "image_url", "name", "updated_at"]
  end
end
