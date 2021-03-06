# encoding: utf-8
require "logstash/json"

module LogStash::Api::AppHelpers

  def respond_with(data, options={})
    as     = options.fetch(:as, :json)
    filter = options.fetch(:filter, "")
    pretty = params.has_key?("pretty")

    if as == :json
      selected_fields = extract_fields(filter.to_s.strip)
      data.select! { |k,v| selected_fields.include?(k) } unless selected_fields.empty?
      unless options.include?(:exclude_default_metadata)
        data = default_metadata.merge(data)
      end
      content_type "application/json"
      LogStash::Json.dump(data, {:pretty => pretty})
    else
      content_type "text/plain"
      data.to_s
    end
  end

  def extract_fields(filter_string)
    (filter_string.empty? ? [] : filter_string.split(",").map { |s| s.strip.to_sym })
  end

  def as_boolean(string)
    return true   if string == true   || string =~ (/(true|t|yes|y|1)$/i)
    return false  if string == false  || string.blank? || string =~ (/(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{string}\"")
  end

  def default_metadata
    @factory.build(:default_metadata).all
  end
end
