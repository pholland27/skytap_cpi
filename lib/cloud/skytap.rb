# Copyright (c) 2012 Skytap, Inc.

module Bosh
  module SkytapCloud; end
end

# requires go here

module Bosh
  module Clouds
    Skytap = Bosh::SkytapCloud::Cloud
  end
end
