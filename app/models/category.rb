class Category < ActiveRecord::Base
  validates :title, :description, presence: true
  validates :title, uniqueness: true
  has_many :loan_requests_categories
  has_many :loan_requests, through: :loan_requests_categories
  
  def self.all_categories
    Rails.cache.fetch("all_categories-#{Category.last.id}", expires_in: 1.day) do
       self.all
    end
  end
end
