json.array!(@worksessions) do |worksession|
  json.extract! worksession, :id
  json.url worksession_url(worksession, format: :json)
end
