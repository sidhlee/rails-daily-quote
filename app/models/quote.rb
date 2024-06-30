class Quote < ApplicationRecord
  belongs_to :author
  has_and_belongs_to_many :tags

  def self.ransackable_associations(_auth_object = nil)
    %w[author tags]
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[author_id text]
  end
end
