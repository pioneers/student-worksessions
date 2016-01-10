json.array!(@worksessions) do |worksession|
  json.extract! worksession, :id
  json.start worksession.begin_at
  json.end worksession.end_at
  json.url worksession_url(worksession, format: :json)
end
