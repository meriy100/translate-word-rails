json.array!(@words) do |word|
  json.extract! word, :id, :en, :ja, :count, :hide, :text_id
  json.url word_url(word, format: :json)
end
