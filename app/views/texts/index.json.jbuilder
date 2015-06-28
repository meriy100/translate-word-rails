json.array!(@texts) do |text|
  json.extract! text, :id, :entext
  json.url text_url(text, format: :json)
end
