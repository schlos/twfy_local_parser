# attributes: url wikipedia_url location website_generator

class Council < ActiveRecord::Base
  # has_one :member_scraper
  # has_one :committee_scrapers
  has_many :members
  has_many :committees
  has_many :scrapers
  validates_presence_of :name
  validates_uniqueness_of :name
  
end