# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
password = "12345678"
new_hashed_password = User.new(:password => password).encrypted_password
@user = User.create!(team_name: 'Oski', email: 'oski@berkeley.edu', admin: true, password: password, encrypted_password: new_hashed_password, sign_in_count: 0, created_at: DateTime.now, updated_at: DateTime.now)
begin_time = DateTime.new(2017, 1, 1, 9, 0,0).in_time_zone("Pacific Time (US & Canada)")
end_time = DateTime.new(2017, 1, 1, 10, 0,0).in_time_zone("Pacific Time (US & Canada)")
@worksession = Worksession.create!(begin_at: begin_time, end_at: end_time, date: DateTime.new(2016, 1, 1, 0, 0, 0).in_time_zone("Pacific Time (US & Canada)"), notes: "Testing",  free: true, created_by: @user.id, user_id: nil)
User.create!([
  {team_name: 'team1', email: "testteam@email.com", password: "12345678", password_confirmation: "12345678", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 1, current_sign_in_at: "2015-02-06 14:02:10", last_sign_in_at: "2015-02-06 14:02:10", current_sign_in_ip: "127.0.0.1", last_sign_in_ip: "127.0.0.1", admin: false},
  {team_name: 'team2', email: "testteam2@email.com", password: "12345678", password_confirmation: "12345678", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 1, current_sign_in_at: "2015-02-06 14:03:01", last_sign_in_at: "2015-02-06 14:03:01", current_sign_in_ip: "127.0.0.1", last_sign_in_ip: "127.0.0.1", admin: false},
  {email: "testadmin@email.com", password: "12345678", password_confirmation: "12345678", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 1, current_sign_in_at: "2015-02-06 14:03:44", last_sign_in_at: "2015-02-06 14:03:44", current_sign_in_ip: "127.0.0.1", last_sign_in_ip: "127.0.0.1", admin: true}
])
