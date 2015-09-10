require './db/test'
require './db/massive_seed'

if Rails.env.production?
  MassiveSeed::Seed.new.run
else
	Test::Seed.new.run
end

