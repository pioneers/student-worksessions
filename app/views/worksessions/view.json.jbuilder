
		json.array!(Worksession.all) do |worksession|
			json.extract! worksession, :id
			json.start worksession.begin_at
			json.title "Worksession"
			json.end worksession.end_at
		end

