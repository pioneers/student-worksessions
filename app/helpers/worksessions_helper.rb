module WorksessionsHelper
	def divide_worksessions
		begin_time = params[:begin_at]
		end_time = params[:end_at]
		new_start = begin_time.beginning_of_hour()
		new_end = new_start + 60
		while new_end < end_time
			Worksession.create(date: date, begin_at: new_start, end_at: new_end)
			new_start = begin_time.beginning_of_hour()
			new_end = new_start + 60
		end
	end
end
