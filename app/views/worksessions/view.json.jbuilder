if @team_user.nil?
		all_worksessions = @users.collect{|user| user.worksessions}.flatten
		json.array!(all_worksessions) do |worksession|
			json.extract! worksession, :id
			json.start worksession.begin_at
			json.title "Worksession"
			json.end worksession.end_at
		end
else
	json.array!(@team_user.worksessions) do |worksession|
		json.extract! worksession, :id
		json.start worksession.begin_at
		json.title "Worksession"
		json.end worksession.end_at
	end
end