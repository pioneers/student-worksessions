if @user.nil?
		all_worksessions = Worksession.joins(:users).group("worksessions.id").having("count(users.id) > ?",0)

		json.array!(all_worksessions) do |worksession|
			json.extract! worksession, :id
			json.start worksession.begin_at
			json.title "Worksession"
			json.end worksession.end_at
		end
else
	json.array!(@user.worksessions) do |worksession|
		json.extract! worksession, :id
		json.start worksession.begin_at
		json.title "Worksession"
		json.end worksession.end_at
	end
end