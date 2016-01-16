json.array!(@worksessions) do |worksession|
	if current_user.id == worksession.user_id
		json.extract! worksession, :id
		json.start worksession.begin_at
		json.end worksession.end_at
		json.cancel_url cancel_path(worksession)
		json.user_id worksession.user_id
	end
end
