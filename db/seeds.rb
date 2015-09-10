require './db/small_seed'
require './db/massive_seed'

if Rails.env.production?
  MassiveSeed::Seed.new.run
else
	SmallSeed::Seed.new.run
end

