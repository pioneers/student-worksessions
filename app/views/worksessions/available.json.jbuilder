json.array!(@worksessions) do |worksession|
  if worksession.begin_at >= @today - 1.day
    json.extract! worksession, :id
    json.start worksession.begin_at
    json.end worksession.end_at
    json.signup_url signUp_path(worksession)
    json.cancel_url cancel_path(worksession)

    json.user_id worksession.user_id
    
    if worksession.users.include?(current_user)
      note = Booking.where(worksession_id: worksession.id, user_id: current_user.id).take.notes
      json.title "Signed Up"
      json.notes note
      json.color '#009900'
    elsif worksession.past
      json.title "Unavailable"
      json.color '#A6A39F'

    elsif worksession.free
      json.title "Available"
    else 
    	json.title "Taken"
    	json.color '#993333'
    end
    json.current_user_id current_user.id
  end
end
