# Worksession is specific timeslot that is created.
#
# A user creates a booking to say they will
# attend that worksession.

class Worksession < ActiveRecord::Base
	validates :begin_at, uniqueness: true
	# A worksession may be booked multiple times
	has_many :bookings
	has_many :users, :through => :bookings,
                                  foreign_key: "user_id",
                                  dependent:   :destroy

end
