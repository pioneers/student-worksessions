class Booking < ActiveRecord::Base
	belongs_to :user
 	belongs_to :worksession
 	validates :user_id, presence: true
  	validates :worksession_id, presence: true
end
