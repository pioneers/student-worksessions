json.array!(@worksessions) do |worksession|
  json.extract! worksession, :id
  json.start worksession.begin_at
  json.end worksession.end_at
  json.signup_url signUp_path(worksession)
  json.cancel_url cancel_path(worksession)

  json.user_id worksession.user_id
  if worksession.free
  	json.title "Available"
  else 
  	json.title "Taken"
  	json.color '#993333'
  end
  json.current_user_id current_user.id
end
