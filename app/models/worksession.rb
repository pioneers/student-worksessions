class Worksession < ActiveRecord::Base
	validates :begin_at, uniqueness: true
	# belongs_to :user, foreign_key: "user_id", class_name: "Team"
	has_many :bookings
	has_many :users, :through => :bookings,
                                  foreign_key: "user_id",
                                  dependent:   :destroy

end
