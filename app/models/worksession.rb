class Worksession < ActiveRecord::Base
	validates :date, uniqueness: true
	belongs_to :user, foreign_key: "user_id", class_name: "Team"
end
