# User is the representative of a robotics team.
#
# A user will create a booking for a worksession their
# team will attend. 
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  validates :team_name, presence: true
  validates :team_name, uniqueness: true
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :bookings
  has_many :worksessions, :through => :bookings,
                                  foreign_key: "worksession_id",
                                  dependent: :destroy

end
