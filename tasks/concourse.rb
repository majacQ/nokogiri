require "concourse"

Concourse.new("nokogiri", fly_target: "ci", format: true, fly_args_validate_pipeline: "--enable-across-step") do |c|
  c.add_pipeline "nokogiri", "nokogiri.yml"
  c.add_pipeline "nokogiri-next", "nokogiri-next.yml"
  c.add_pipeline "nokogiri-pr", "nokogiri-pr.yml"
end
